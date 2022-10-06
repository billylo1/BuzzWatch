//
//  ContentView.swift
//  BuzzWatch Watch App
//
//  Created by Billy Lo on 2022-09-27.
//

import SwiftUI
import UserNotifications
import Foundation
struct ContentView: View {
    
    /// A configuration for managing the characteristics of a sound classification task.
    @State var appConfig = AppConfiguration()

    /// The runtime state that contains information about the strength of the detected sounds.
    @StateObject var appState = AppState()
    @State var buttonTitle: String = "Start"
    @State var buttonTint: Color = .blue
    @State var title = "Ready"

    
    var body: some View {
        VStack {
            Text(title)
            Divider()
            Text("🚨 Sirens")
            Text("📢 Car Horn")
            Text("🗣 Screaming")
            Text("🔥 Smoke Detector")
            Text("🫰 Finger-snapping")
            Button(buttonTitle) {
                
                if (appState.soundDetectionIsRunning) {
                    appState.stopDetection()
                    buttonTitle = "Start"
                    buttonTint = .blue
                    title = "Ready"
                } else {
                    appState.restartDetection(config: appConfig)
                    buttonTitle = "Stop"
                    buttonTint = .green
                    title = "Listening for"

                }

            }.tint(buttonTint)

//
//            Button("Send") {
//                appState.sendNotification("Test", 0.5)
//            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
