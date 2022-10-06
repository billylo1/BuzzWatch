//
//   NotificationView.swift
//  BuzzWatch Watch App
//
//  Created by Billy Lo on 2022-09-27.
//

import WatchKit
import SwiftUI
import UserNotifications

class NotificationController: WKUserNotificationHostingController<NotificationView>  {
    var emoji: String?
    var soundTypeAndConfidence: String?
    var eventDate: Date?

    override var body: NotificationView {
        NotificationView(emoji: emoji,
                         soundTypeAndConfidence: soundTypeAndConfidence,
                         eventDate: eventDate)    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func didReceive(_ notification: UNNotification) {
        // This method is called when a notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.

//        let notificationData =
//            notification.request.content.userInfo as? [String: Any]

//        let aps = notificationData?["aps"] as? [String: Any]
//        let alert = aps?["alert"] as? [String: Any]

        // title is the emoji
        // message is the  sound type (confidence level)
        
        print("didReceive")
        let title = notification.request.content.title
        let fromIndex = title.index(title.startIndex, offsetBy: 2)
                                                  
        emoji = String(notification.request.content.title.prefix(1))
        soundTypeAndConfidence = "\(String(title.suffix(from: fromIndex))) \(notification.request.content.subtitle)%"
        eventDate = .now

    }
    
}
