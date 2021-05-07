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

    @AppStorage("guiIsEnabled") var guiIsEnabled: Bool = false
    @AppStorage("showTimestamps") var showTimestamps: Bool = false
    @AppStorage("showPings") var showPings: Bool = false
    @AppStorage("showReplies") var showReplies: Bool = false
    @AppStorage("smartlinkIsEnabled") var smartlinkIsEnabled: Bool = false

    var body: some View {

        HStack(spacing: 30) {
            Button(radioManager.isConnected ? "Stop" : "Start") {
                if radioManager.isConnected {
                    radioManager.disconnect()
                } else {
                    radioManager.connect()
                }
            }
            .keyboardShortcut(radioManager.isConnected ? .cancelAction : .defaultAction)
            .help("Using the Default connection type")

            HStack(spacing: 20) {
                Toggle("Gui", isOn: $guiIsEnabled)
                Toggle("Times", isOn: $showTimestamps)
                Toggle("Pings", isOn: $showPings)
                Toggle("Replies", isOn: $showReplies)
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
                .disabled(!smartlinkIsEnabled)

                Button("Status") { radioManager.showView(.smartlinkStatus) }
            }.disabled(radioManager.isConnected)

            Spacer()
            Button("Defaults") { radioManager.defaultChoose() }.disabled(radioManager.isConnected)
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
