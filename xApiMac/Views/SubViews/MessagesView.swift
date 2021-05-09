//
//  MessagesView.swift
//  xApiMac
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI

struct MessagesView: View {
    let messages: [Message]
    let fontSize: Int

    @AppStorage("showTimestamps") var showTimestamps: Bool = false

    func timestamps(text: String) -> String {
        if showTimestamps {
            return text
        } else {
            return String(text.dropFirst(9))
        }
    }

    var body: some View {

        ScrollView([.horizontal, .vertical]) {
            LazyVStack(alignment: .leading) {
                ForEach(messages) { message in
                    Text(timestamps(text: message.text))
                        .padding(.leading, 5)
                        .font(.system(size: CGFloat(fontSize), weight: .regular, design: .monospaced))
                        .foregroundColor( message.color )
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minWidth: 3000, maxWidth: .infinity, alignment: .leading)
            }
            .frame(alignment: .leading)
        }
    }
}

struct MessagesView_Previews: PreviewProvider {

    static var previews: some View {
        let commandColor = Color(.systemGreen)
        let replyColor = Color(.systemGray)
        let replyWithErrorColor = Color(.systemRed)
        let defaultColor = Color(.textColor)
        let status0Color = Color(.systemOrange)

        let mockMessages = [
            Message(id: 0, text: "11:40:04 C  A Command message", color: commandColor),
            Message(id: 1, text: "11:40:05 R  A Reply message", color: replyColor),
            Message(id: 2, text: "11:40:05 R  A Reply message w/error", color: replyWithErrorColor),
            Message(id: 3, text: "11:40:06 S0 An S0 message", color: status0Color),
            Message(id: 4, text: "11:40:06    Other messages", color: defaultColor)
        ]
        MessagesView(messages: mockMessages, fontSize: 20)
    }
}
