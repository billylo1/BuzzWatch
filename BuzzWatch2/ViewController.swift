//
//  ViewController.swift
//  BuzzWatch2
//
//  Created by Billy Lo on 2022-10-04.
//

import UIKit
import SafariServices
import HealthKit
import WatchConnectivity


class ViewController: UIViewController,  WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //
    }
    

    @IBAction func githubLink(_ sender: Any) {
        
        if let url = URL(string: "https://github.com/billylo1/BuzzWatch") {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }

    }
    
    @IBAction func updateAction(_ sender: Any) {
        
        startWatchApp()
        // self.tabBarController?.selectedIndex = 1
        
    }
    
    @IBAction func generateAction(_ sender: Any) {
        do {
            let soundIdentifiers = try SystemAudioClassifier.getAllPossibleLabels()
            let sortedArray = soundIdentifiers.sorted()

            for soundIdentifier in sortedArray {
                let displayName = SoundIdentifier(labelName: soundIdentifier).displayName
                let output = """
                <dict>
                    <key>Type</key>
                    <string>PSToggleSwitchSpecifier</string>
                    <key>Title</key>
                    <string>\(displayName)</string>
                    <key>Key</key>
                    <string>sounds_\(soundIdentifier)</string>
                </dict>
                
                """
                print(output)
            }
            
        } catch {
            print(error)
        }
        
    }
    let healthStore = HKHealthStore()
    let configuration = HKWorkoutConfiguration()

    func startWatchApp() {
        print("method called to open app ")

        getActiveWCSession { (wcSession) in
            print(wcSession.isComplicationEnabled, wcSession.isPaired)
            if wcSession.activationState == .activated && wcSession.isWatchAppInstalled {
                print("starting watch app")

                self.healthStore.startWatchApp(with: self.configuration, completion: { (success, error) in
                    // Handle errors
                })
            }

            else{
                print("watch not active or not installed")
            }
        }

    }

     func getActiveWCSession(completion: @escaping (WCSession)->Void) {
        guard WCSession.isSupported() else { return }

        let wcSession = WCSession.default
        wcSession.delegate = self

        if wcSession.activationState == .activated {
            completion(wcSession)
        } else {
            wcSession.activate()
            // wcSessionActivationCompletion = completion
        }
    }

}

