/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Wraps the command status.
*/

import UIKit
import WatchConnectivity

// Constants to identify the Watch Connectivity methods, also for user-visible strings in UI.
//
enum Command: String {
    case updateAppContext = "UpdateAppContext"
    case sendMessage = "SendMessage"
    case sendMessageData = "SendMessageData"
    case transferUserInfo = "TransferUserInfo"
    case transferFile = "TransferFile"
    case transferCurrentComplicationUserInfo = "TransferComplicationUserInfo"
}

// Constants to identify the phrases of Watch Connectivity communication.
//
enum Phrase: String {
    case updated = "Updated"
    case sent = "Sent"
    case received = "Received"
    case replied = "Replied"
    case transferring = "Transferring"
    case canceled = "Canceled"
    case finished = "Finished"
    case failed = "Failed"
}

// Wrap a timed color payload dictionary with a stronger type.
//
struct BuzzWatchSettings {
    
    var monitoredSounds : [String]
    var threshold: Double = 0.9
    
    init(_ buzzWatchSettings: [String: Any]) {
        self.monitoredSounds = buzzWatchSettings["monitored_sounds"] as! [String]
        let thresholdString = buzzWatchSettings["threshold"] as? String
        if thresholdString != nil {
            self.threshold = Double(thresholdString!) ?? 0.9
        }
        print(self.threshold)
    }

}

// Wrap the command's status to bridge the commands status and UI.
//
struct CommandStatus {
    var command: Command
    var phrase: Phrase
    var buzzWatchSettings: BuzzWatchSettings?
    var fileTransfer: WCSessionFileTransfer?
    var file: WCSessionFile?
    var userInfoTranser: WCSessionUserInfoTransfer?
    var errorMessage: String?
    
    init(command: Command, phrase: Phrase) {
        self.command = command
        self.phrase = phrase
    }
}
