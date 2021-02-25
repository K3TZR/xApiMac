//
//  TopButtonsView.swift
//  xApiMac
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI
import xClientMac

struct TopButtonsView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radioManager: RadioManager

    var body: some View {

        HStack(spacing: 30) {
            Button(radioManager.isConnected ? "Stop" : "Start") {
                if radioManager.isConnected {
                    radioManager.stop()
                } else {
                    radioManager.start()
                }
            }
            .help("Using the Default connection type")
            
            Toggle("As Gui", isOn: $tester.enableGui)
            Toggle("Show Times", isOn: $tester.showTimestamps)
            Toggle("Show Pings", isOn: $tester.showPings)
            Toggle("Show Replies", isOn: $tester.showReplies)
            
            Spacer()
            HStack(spacing: 10){
                Text("SmartLink").frame(width: 75)
                Button(action: {
                    if radioManager.smartLinkIsLoggedIn {
                        radioManager.smartLinkLogout()
                    } else {
                        radioManager.smartLinkLogin()
                    }
                }) {
                    Text(radioManager.smartLinkIsLoggedIn ? "Logout" : "Login").frame(width: 50)
                }
                Button("Status") { radioManager.showSheet(.status) }
            }.disabled(radioManager.delegate.smartLinkEnabled == false || radioManager.isConnected)
            
            Spacer()
            Button("Defaults") { radioManager.chooseDefaults() }.disabled(radioManager.isConnected)
        }
    }
}

struct TopButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate) )
    }
}
