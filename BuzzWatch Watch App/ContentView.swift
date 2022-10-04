//
//  ContentView.swift
//  BuzzWatch Watch App
//
//  Created by Billy Lo on 2022-09-27.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    
    /// A configuration for managing the characteristics of a sound classification task.
    @State var appConfig = AppConfiguration()

    /// The runtime state that contains information about the strength of the detected sounds.
    @StateObject var appState = AppState()
    
    var body: some View {
        VStack {
            Button("Send") {
                
                let center = UNUserNotificationCenter.current()

                let options: UNAuthorizationOptions = [.alert, .badge, .sound]
                center.requestAuthorization(options: options) { (granted, error) in
                    if granted {
                        print("granted")
                    } else {
                        print(error?.localizedDescription ?? "not granted")
                    }
                }
                
                let category = UNNotificationCategory(identifier: "myCategory", actions: [], intentIdentifiers: [], options: [])
                UNUserNotificationCenter.current().setNotificationCategories([category])

                let content = UNMutableNotificationContent()
                content.title = "Car horn"
                let formatter1 = DateFormatter()
                formatter1.timeStyle = .medium
                let body = formatter1.string(from: Date.now)
                content.body = "At \(body)"
                content.sound = UNNotificationSound.default
                content.interruptionLevel = .active
                content.subtitle = "Hello"
                content.categoryIdentifier = "myCategory"
                
                let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: timeTrigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("send")
                    }
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
