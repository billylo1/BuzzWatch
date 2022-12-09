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
    // @State var appConfig = AppConfiguration()

    /// The runtime state that contains information about the strength of the detected sounds.
    ///
    
    @StateObject var appState = AppState()
    @State var buttonTint: Color = .blue
    @State var title = "Ready"
    @State var updater: Bool = false

    var body: some View {
        VStack {
//            Text(title)
            Button(appState.buttonTitle) {
                
                if (appState.soundDetectionIsRunning) {
                    appState.stopDetection()
                    buttonTint = .blue
                    title = "Ready"
                } else {
                    appState.restartDetection(config: appState.appConfig)
                    buttonTint = .green
                    title = "Listening for"

                }

            }.tint(buttonTint)

            Divider()
            ForEach(appState.appConfig.monitoredSounds, id: \.labelName) { sound in
                Text("\(sound.displayName)")
            }

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
