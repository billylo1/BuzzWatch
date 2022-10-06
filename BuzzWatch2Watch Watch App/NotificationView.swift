//
//  NotificationView.swift
//  BuzzWatch Watch App
//
//  Created by Billy Lo on 2022-09-27.
//

import SwiftUI

struct NotificationView: View {
    var emoji: String?
    var soundTypeAndConfidence: String?
    var eventDate: Date?

    var body: some View {
        VStack {

            Text(emoji ?? "📢" )
                .font(.system(size: 72))

            Text(soundTypeAndConfidence ?? "Car Horn (52%)")
                .font(.headline)

            Text(eventDate ?? .now, style: .relative)
                .font(.caption)
        }
        .lineLimit(0)
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NotificationView()
            NotificationView(emoji: "📢",
                             soundTypeAndConfidence: "Car Horn (52%)",
                             eventDate: .now)
        }
    }
}
