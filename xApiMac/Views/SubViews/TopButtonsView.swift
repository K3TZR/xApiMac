//
//  TopButtonsView.swift
//  xApiMac
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI
import xClient

struct TopButtonsView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radioManager: RadioManager

    var body: some View {

        HStack(spacing: 30) {
            Button(radioManager.isConnected ? "Stop" : "Start") {
                if radioManager.isConnected {
                    radioManager.disconnect()
                } else {
                    radioManager.connect()
                }
            }
            .keyboardShortcut(.defaultAction)
            .help("Using the Default connection type")

            HStack(spacing: 20) {
                Toggle("Gui", isOn: $tester.guiIsEnabled)
                Toggle("Times", isOn: $tester.showTimestamps)
                Toggle("Pings", isOn: $tester.showPings)
                Toggle("Replies", isOn: $tester.showReplies)
            }

            Spacer()
            HStack(spacing: 10) {
                Text("SmartLink")
                Button(action: {
                    if radioManager.smartlinkIsLoggedIn {
                        radioManager.smartlinkLogout()
                    } else {
                        radioManager.smartlinkLogin()
                    }
                }) {
                    Text(radioManager.smartlinkIsLoggedIn ? "Logout" : "Login").frame(width: 50)
                }
                .disabled(!radioManager.delegate.smartlinkIsEnabled)

                Button("Status") { radioManager.showView(.smartlinkStatus) }
            }.disabled(radioManager.isConnected)

            Spacer()
            Button("Defaults") { radioManager.defaultChoose() }.disabled(radioManager.isConnected)
        }
    }
}

struct TopButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        TopButtonsView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate) )
    }
}
