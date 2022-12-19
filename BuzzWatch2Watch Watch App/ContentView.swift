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
    @State var updater: Bool = false

    var body: some View {
        VStack {
            Button(appState.buttonTitle) {
                
                if (appState.soundDetectionIsRunning) {
                    appState.stopDetection()
                    appState.title = "Ready"
                } else {
                    appState.restartDetection(config: appState.appConfig)
                    appState.title = "Listening for"
                }

            }.tint(appState.soundDetectionIsRunning ? .orange : .blue).buttonStyle(.borderedProminent)

            Text(appState.title).bold()
            Divider()
            ForEach(appState.appConfig.monitoredSounds, id: \.labelName) { sound in
                Text("\(sound.displayName)").foregroundColor(appState.detectedSound == (sound.labelName) ? .orange : .primary)
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
