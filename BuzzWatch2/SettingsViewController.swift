//
//  SettingsViewController.swift
//  BuzzWatch2
//
//  Created by Billy Lo on 2022-10-16.
//

import Foundation
import InAppSettingsKit

class SettingsViewController: IASKAppSettingsViewController, IASKSettingsDelegate {
    
    func settingsViewControllerDidEnd(_ settingsViewController: IASKAppSettingsViewController) {
        print("settingsViewControllerDidEnd")
    }
    
    var soundLabels: [String] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        do {
            let soundIdentifiers = try SystemAudioClassifier.getAllPossibleLabels()
            for soundIdentifier in soundIdentifiers {
                soundLabels.append(soundIdentifier)
            }
            
        } catch {
            print(error)
        }
    }
    
    func settingsViewController(_ settingsViewController: IASKAppSettingsViewController,
                                buttonTappedFor specifier: IASKSpecifier) {
     
        let key = specifier.key!
        if (key == "suggest_button") {
            // Helpers.invokeDoorbell(self)
        } else {
            // logger.error("unknown key \(key)")
        }
        return
    }

    func settingsViewController(_ settingsViewController: IASKAppSettingsViewController, valuesFor specifier: IASKSpecifier) -> [Any] {
        return specifier.key == "monitored_sounds" ? soundLabels : []
    }
    
    func settingsViewController(_ settingsViewController: IASKAppSettingsViewController, titlesFor specifier: IASKSpecifier) -> [Any] {
        return specifier.key == "monitored_sounds" ? soundLabels : []
    }
    
}
