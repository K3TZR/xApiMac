//
//  SendView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/9/20.
//

import SwiftUI
import xClient6001

struct SendView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radioManager: RadioManager

    @AppStorage("clearOnSend") var clearOnSend: Bool = false

    var body: some View {

        HStack(spacing: 30) {
            Button("Send") {
                    radioManager.send(command: tester.cmdToSend)
                    tester.sent(command: tester.cmdToSend)
            }
            .disabled(!radioManager.isConnected)
            .keyboardShortcut(.defaultAction)

            TextField("Command to send", text: $tester.cmdToSend)
                .modifier(ClearButton(boundText: $tester.cmdToSend))

            Spacer()
            Toggle("Clear on Send", isOn: $clearOnSend)
        }
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate))
    }
}
