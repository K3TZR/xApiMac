//
//  TopButtonsView.swift
//  xApiMac
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI
import xClient6001

struct TopButtonsView: View {
    @EnvironmentObject var tester: Tester
    @EnvironmentObject var radioManager: RadioManager

    var body: some View {

        HStack(spacing: 30) {
            Button(radioManager.isConnected ? "Stop" : "Start") {
                radioManager.startStopConnection()
            }
            .keyboardShortcut(radioManager.isConnected ? .cancelAction : .defaultAction)
            .help("Using the Default connection type")

            HStack(spacing: 20) {
                Toggle("Gui", isOn: tester.$guiIsEnabled)
                Toggle("Times", isOn: tester.$showTimestamps)
                Toggle("Pings", isOn: tester.$showPings)
                Toggle("Replies", isOn: tester.$showReplies)
                Toggle("Buttons", isOn: tester.$showButtons)
            }

            Spacer()
            HStack(spacing: 10) {
                Text("SmartLink")
                Button(action: {
                    radioManager.smartlinkLoginLogout()
                }) {
                    Text(radioManager.smartlinkIsLoggedIn ? "Logout" : "Login").frame(width: 50)
                }
                .disabled(!tester.smartlinkIsEnabled)

                Button("Status") { radioManager.showView(.smartlinkStatus) }
            }.disabled(radioManager.isConnected)

            Spacer()
            Button("Default") { radioManager.defaultChoose() }
        }
    }
}

struct TopButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        TopButtonsView()
            .environmentObject(Tester())
            .environmentObject(RadioManager(delegate: Tester() as RadioManagerDelegate))

            .previewLayout(.fixed(width: 2160 / 2.0, height: 1620 / 2.0))
    }
}
