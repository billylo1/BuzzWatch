/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Defines an interface to wrap Watch Connectivity APIs and bridge the UI.
*/

import UIKit
import WatchConnectivity

// Define an interface to wrap Watch Connectivity APIs and bridge the UI.
//
protocol SessionCommands {
    func updateAppContext(_ context: [String: Any])
}

// Implement the commands. Every command handles the communication and notifies clients
// when WCSession status changes or data flows.
//
extension SessionCommands {
    
    // Update the app context if the session is activated, and update UI with the command status.
    //
    func updateAppContext(_ context: [String: Any]) {
        
        print("updateAppContext")
        print(context)
        
        var commandStatus = CommandStatus(command: .updateAppContext, phrase: .updated)
        // commandStatus.buzzWatchSettings = BuzzWatchSettings()
        
        guard WCSession.default.activationState == .activated else {
            return handleSessionUnactivated(with: commandStatus)
        }
        do {
            try WCSession.default.updateApplicationContext(context)
        } catch {
            commandStatus.phrase = .failed
            commandStatus.errorMessage = error.localizedDescription
        }
        postNotificationOnMainQueueAsync(name: .dataDidFlow, object: commandStatus)
    }

    
    // Post a notification from the main queue asynchronously.
    //
    private func postNotificationOnMainQueueAsync(name: NSNotification.Name, object: CommandStatus) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: object)
        }
    }

    // Handle unactivated session error. WCSession commands require an activated session.
    //
    private func handleSessionUnactivated(with commandStatus: CommandStatus) {
        var mutableStatus = commandStatus
        mutableStatus.phrase = .failed
        mutableStatus.errorMessage = "WCSession is not activated yet!"
        postNotificationOnMainQueueAsync(name: .dataDidFlow, object: commandStatus)
    }
}
