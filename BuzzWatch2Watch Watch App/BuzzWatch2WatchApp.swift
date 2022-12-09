//
//  BuzzWatch2WatchApp.swift
//  BuzzWatch2Watch Watch App
//
//  Created by Billy Lo on 2022-10-04.
//

//
//  BuzzWatchApp.swift
//  BuzzWatch Watch App
//
//  Created by Billy Lo on 2022-09-27.
//

import SwiftUI
import Combine
import SoundAnalysis
import UserNotifications
import WatchConnectivity
import HealthKit

/// Contains customizable settings that control app behavior.
struct AppConfiguration {
    /// Indicates the amount of audio, in seconds, that informs a prediction.
    var inferenceWindowSize = Double(1.5)

    /// The amount of overlap between consecutive analysis windows.
    ///
    /// The system performs sound classification on a window-by-window basis. The system divides an
    /// audio stream into windows, and assigns labels and confidence values. This value determines how
    /// much two consecutive windows overlap. For example, 0.9 means that each window shares 90% of
    /// the audio that the previous window uses.
    var overlapFactor = Double(0.9)

    /// A list of sounds to identify from system audio input.
    var monitoredSounds = [SoundIdentifier]()

    /// Retrieves a list of the sounds the system can identify.
    ///
    /// - Returns: A set of identifiable sounds, including the associated labels that sound
    ///   classification emits, and names suitable for displaying to the user.
//    static func listAllValidSoundIdentifiers() throws -> Set<SoundIdentifier> {
//        var labels = try SystemAudioClassifier.getAllPossibleLabels()
//        return Set<SoundIdentifier>(labels.map {
//            SoundIdentifier(labelName: $0)
//        })
//    }
}

/// The runtime state of the app after setup.
///
/// Sound classification begins after completing the setup process. The `DetectSoundsView` displays
/// the results of the classification. Instances of this class contain the detection information that
/// `DetectSoundsView` renders. It incorporates new classification results as the app produces them into
/// the cumulative understanding of what sounds are currently present. It tracks interruptions, and allows for
/// restarting an analysis by providing a new configuration.
class AppState: ObservableObject, SessionCommands {
    
    /// A cancellable object for the lifetime of the sound classification.
    ///
    /// While the app retains this cancellable object, a sound classification task continues to run until it
    /// terminates due to an error.
    private var detectionCancellable: AnyCancellable? = nil

    /// The configuration that governs sound classification.
    @Published var appConfig = AppConfiguration()

    /// A list of mappings between sounds and current detection states.
    ///
    /// The app sorts this list to reflect the order in which the app displays them.
    @Published var detectionStates: [(SoundIdentifier, DetectionState)] = []

    /// Indicates whether a sound classification is active.
    ///
    /// When `false,` the sound classification has ended for some reason. This could be due to an error
    /// emitted from Sound Analysis, or due to an interruption in the recorded audio. The app needs to prompt
    /// the user to restart classification when `false.`
    @Published var soundDetectionIsRunning: Bool = false
    @Published var buttonTitle: String = "Start Listening"

    private var command: Command!
    private lazy var sessionDelegator: SessionDelegator = {
        return SessionDelegator()
    }()



    let notificationDelegate = NotificationDelegate()
    init() {
         // self.restartDetection(config: appConfig)
        UNUserNotificationCenter.current().delegate = notificationDelegate
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).dataDidFlow(_:)),
            name: .dataDidFlow, object: nil
        )
        assert(WCSession.isSupported(), "This sample requires a platform supporting Watch Connectivity!")

        WCSession.default.delegate = sessionDelegator
        WCSession.default.activate()
        
        loadSettings()
        
        print("< init()")
    }
    
    func loadSettings() {
        
        print("loadSettings")
        
        appConfig.monitoredSounds = []
        
        var sounds = UserDefaults.standard.array(forKey: "monitored_sounds")
        
        if (sounds == nil) {
            sounds =  ["car_horn", "finger_snapping", "siren", "smoke_detector"]  // default
        }
        
        for sound in sounds! {
            appConfig.monitoredSounds.append(SoundIdentifier(labelName: sound as! String))
        }

        print(sounds as! [String])
        
        var threshold = UserDefaults.standard.double(forKey: "threshold")
        if (threshold == 0) {
            threshold = 0.9 // default
        }
        
        print(threshold)

        notificationConfidenceThreshold = threshold
    }
    
    // .dataDidFlow notification handler. Update the UI with the command status.
    //
    @objc
    func dataDidFlow(_ notification: Notification) {
        
        print("dataDidFlow")
        print(notification)
        guard let commandStatus = notification.object as? CommandStatus else { return }
        
        let settings = commandStatus.buzzWatchSettings;

        UserDefaults.standard.set(settings?.monitoredSounds, forKey: "monitored_sounds")
        UserDefaults.standard.set(settings?.threshold, forKey: "threshold")

        loadSettings()
        
    }

    /// Begins detecting sounds according to the configuration you specify.
    ///
    /// If the sound classification is running when calling this method, it stops before starting again.
    ///
    /// - Parameter config: A configuration that provides information for performing sound detection.
    func restartDetection(config: AppConfiguration) {
        
        SystemAudioClassifier.singleton.stopSoundClassification()

        let classificationSubject = PassthroughSubject<SNClassificationResult, Error>()

        detectionCancellable =
          classificationSubject
          .receive(on: DispatchQueue.main)
          .sink(receiveCompletion: { _ in self.soundDetectionIsRunning = false },
                receiveValue: {
              
                      let result : SNClassificationResult = $0
                      self.handleClassification(result)
                    self.detectionStates = AppState.advanceDetectionStates(self.detectionStates, givenClassificationResult: $0)
                })

        self.detectionStates =
          [SoundIdentifier](config.monitoredSounds)
          .sorted(by: { $0.displayName < $1.displayName })
          .map { ($0, DetectionState(presenceThreshold: 0.5,
                                     absenceThreshold: 0.3,
                                     presenceMeasurementsToStartDetection: 2,
                                     absenceMeasurementsToEndDetection: 30))
          }

        appConfig = config
        
        SystemAudioClassifier.singleton.startSoundClassification(
          subject: classificationSubject,
          inferenceWindowSize: config.inferenceWindowSize,
          overlapFactor: config.overlapFactor)
        
        soundDetectionIsRunning = true
        buttonTitle = "Stop Listening"

    }

    var notificationConfidenceThreshold = 0.8
    let waitTimeBetweenNotifications : Double = 1
    var lastNotified = Date.distantPast
    
    func stopDetection() {
        
        print("> stopDetection")
        SystemAudioClassifier.singleton.stopSoundClassification()
        soundDetectionIsRunning = false
        buttonTitle = "Start Listening"

    }
    
    func handleClassification(_ result: SNClassificationResult) {
        
        if -lastNotified.timeIntervalSinceNow > waitTimeBetweenNotifications {
            let carHornConfidence = result.classification(forIdentifier: "car horn")?.confidence ?? 0.0
            let sirenConfidence = result.classification(forIdentifier: "siren")?.confidence ?? 0.0
            let smokeDetectorConfidence = result.classification(forIdentifier: "smoke detector")?.confidence ?? 0.0
            let screamingConfidence = result.classification(forIdentifier: "screaming")?.confidence ?? 0.0
            let fingerSnappingConfidence = result.classification(forIdentifier: "finger_snapping")?.confidence ?? 0.0
            
            if carHornConfidence > notificationConfidenceThreshold {
                sendNotification("📢 Car Horn", carHornConfidence)
            } else if sirenConfidence > notificationConfidenceThreshold {
                sendNotification("🚨 Siren", sirenConfidence)
            } else if smokeDetectorConfidence > notificationConfidenceThreshold {
                sendNotification("🔥 Smoke Detector", smokeDetectorConfidence)
            } else if screamingConfidence > notificationConfidenceThreshold {
                sendNotification("🗣 Screaming", screamingConfidence)
            } else if fingerSnappingConfidence > 0.95 {        // special setting to minimize false positives
                sendNotification("🫰 Finger Snapping", fingerSnappingConfidence)
            } else {
                let confidence = result.classifications.first!.confidence
                if confidence > notificationConfidenceThreshold {
                    let identifier : String = result.classifications.first!.identifier
                    sendNotification("📢 \(identifier)", confidence)
                }
            }
        }

    }
    
    let center = UNUserNotificationCenter.current()

    func requestAuthorization(_ startDetection: Bool) {
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                print("granted")
            } else {
                print(error?.localizedDescription ?? "not granted")
            }
            if startDetection {
                self.restartDetection(config: self.appConfig)
            }
        }

    }
    func sendNotification(_ title: String, _ confidence: Double) {
        
        let category = UNNotificationCategory(identifier: "myCategory", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])

        requestAuthorization(false)
        
        let content = UNMutableNotificationContent()
        content.title = title
        let formatter1 = DateFormatter()
        formatter1.timeStyle = .medium
        let subtitle = String(format: "%.0f", confidence*100)
        content.subtitle = subtitle
        content.sound = .defaultCritical
        content.categoryIdentifier = "myCategory"
        content.interruptionLevel = .timeSensitive
        
        let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: timeTrigger)
        
        let listeningStateBeforeSend = soundDetectionIsRunning
        stopDetection()

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("sent \(title) at \(confidence)")
                self.lastNotified = Date.now
            }
        }
        
        if (listeningStateBeforeSend) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.restartDetection(config: self.appConfig)
            }
        }
    }

    /// Updates the detection states according to the latest classification result.
    ///
    /// - Parameters:
    ///   - oldStates: The previous detection states to update with a new observation from an ongoing
    ///   sound classification.
    ///   - result: The latest observation the app emits from an ongoing sound classification.
    ///
    /// - Returns: A new array of sounds with their updated detection states.
    static func advanceDetectionStates(_ oldStates: [(SoundIdentifier, DetectionState)],
                                       givenClassificationResult result: SNClassificationResult) -> [(SoundIdentifier, DetectionState)] {
        let confidenceForLabel = { (sound: SoundIdentifier) -> Double in
            let confidence: Double
            let label = sound.labelName
            if let classification = result.classification(forIdentifier: label) {
                confidence = classification.confidence
            } else {
                confidence = 0
            }
            return confidence
        }
        return oldStates.map { (key, value) in
            (key, DetectionState(advancedFrom: value, currentConfidence: confidenceForLabel(key)))
        }
    }
    
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        print("handleWorkoutConfiguration")
    }
}

class NotificationDelegate : NSObject, UNUserNotificationCenterDelegate {    // In order to show a notification in banner mode, `completionHandler` must be called with suitable option here
    override init() {
        super.init()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("userNotificationCenter - willPresent")
        completionHandler([.banner, .sound])
    }
}

@main
struct BuzzWatch2Watch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }

}
