//
//  NotificationView.swift
//  BuzzWatch Watch App
//
//  Created by Billy Lo on 2022-09-27.
//

import SwiftUI

struct NotificationView: View {
    var title: String?
    var message: String?

    var body: some View {
        VStack {
//            if landmark != nil {
//                CircleImage(image: landmark!.image.resizable())
//                    .scaledToFit()
//            }

            Text(title ?? "Sound")
                .font(.headline)

            Divider()

            Text(message ?? "10:00 ago")
                .font(.caption)
        }
        .lineLimit(0)
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NotificationView()
            NotificationView(title: "Turtle Rock",
                             message: "\(Date.now)")
        }
    }
}
