//
//  ViewController.swift
//  BuzzWatch2
//
//  Created by Billy Lo on 2022-10-04.
//

import UIKit
import SafariServices
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
    
    @IBOutlet var versionLabel: UILabel!
    @IBAction func updateAction(_ sender: Any) {
        
         self.tabBarController?.selectedIndex = 1
        
    }
    
    /* this is a development use only code. To retrieve the full list of identifiable sound and put them into the plist file
       A better solution would be to load it dynamically at runtime, but it will not be a priority for now. Better to get the
       tool out sooner to evolve it.
     
     */
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

    override func viewDidLoad() {
        versionLabel.text = "v\( Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)"
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

