//
//  SettingsViewController.swift
//  BuzzWatch2
//
//  Created by Billy Lo on 2022-10-16.
//

import Foundation
import InAppSettingsKit
import UserNotifications

class SettingsViewController: IASKAppSettingsViewController, IASKSettingsDelegate, SessionCommands {
    
    func settingsViewControllerDidEnd(_ settingsViewController: IASKAppSettingsViewController) {
        print("settingsViewControllerDidEnd")
        sendSettingsToWatch()
        tabBarController?.selectedIndex = 0
    }
    
    var soundLabels: [String] = [];
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.delegate = self
        self.showCreditsFooter = false
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).dataDidFlow(_:)),
            name: .dataDidFlow, object: nil
        )

        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).settingsDidChange(_:)),
            name: .IASKSettingChanged, object: nil
        )

        guard let defaultDict = self.settingsReader?.gatherDefaultsLimited(toEditableFields: true) else { return }
        UserDefaults.standard.register(defaults: defaultDict)

    }
    
    @objc
    func settingsDidChange(_ notification: Notification) {

        print("settingsDidChange")
//        print(notification.userInfo as Any)
        sendSettingsToWatch()

    }
    
    func settingsViewController(_ settingsViewController: IASKAppSettingsViewController,
                                buttonTappedFor specifier: IASKSpecifier) {
     
        let key = specifier.key!
        if (key == "send_to_watch_button") {
            sendSettingsToWatch()
        }
        return
    }
    
    // Generate an app context for updateApplicationContext.

    var appContext: [String: Any] {
        
        let settings = UserDefaults.standard.dictionaryRepresentation()
        soundLabels = []
        
        for k in settings.keys {
            if (k.starts(with: "sounds_")) {
                let enabled = settings[k] as! Bool
                if enabled && !soundLabels.contains(k) {
                    let fromIndex = k.index(k.startIndex, offsetBy: 7)
                    soundLabels.append(String(k.suffix(from: fromIndex)))
                }
            }
        }
        
        print(soundLabels)
        
        let context = [ "monitored_sounds" : soundLabels.sorted(), "threshold" : settings["confidence_threshold"] , "auto_start" : settings["auto_start"]]
        print(context)
        return context as [String : Any]
    }

    var currentCommand: Command = .updateAppContext // Default to .updateAppContext.

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // .dataDidFlow notification handler.
    // Update the UI using the userInfo dictionary of the notification.
    //
    @objc
    func dataDidFlow(_ notification: Notification) {
        
        print("dataDidFlow")
        guard let commandStatus = notification.object as? CommandStatus else { return }
        
        // defer { noteLabel.isHidden = logView.text.isEmpty ? false: true }
        
        // If an error occurs, show the error message and return.
        //
        if let errorMessage = commandStatus.errorMessage {
            print("! \(commandStatus.command.rawValue)...\(errorMessage)")
            return
        }
        
        // guard let buzzWatchSettings = commandStatus.buzzWatchSettings else { return }
        
    }
    
    func requestAuthorizationAndSendCommand() {
        
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                print("granted")
            } else {
                print(error?.localizedDescription ?? "not granted")
            }
        }
    }

        
    func sendSettingsToWatch() {
        
        print("* sendSettingsToWatch")
        
        switch currentCommand {
            case .updateAppContext: updateAppContext(appContext);
            default: print("unknown command")
        }
        

    }

}
