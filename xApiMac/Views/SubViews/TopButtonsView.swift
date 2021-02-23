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

    var smartLinkButtonText: String {
        if radioManager.delegate.smartLinkEnabled == false {
            return "Disabled"
        } else {
            return radioManager.smartLinkIsLoggedIn ? "Logout" : "Login"
        }
    }

    var body: some View {
        
    
        HStack(spacing: 30) {
            Button(radioManager.isConnected ? "Stop" : "Start") {
                if radioManager.isConnected {
                    radioManager.stop()
                } else {
                    radioManager.start()
                }
            }
            .frame(width: 50, alignment: .leading)
            .help("Using the Default connection type")
            
            Toggle("As Gui", isOn: $tester.enableGui)
            Toggle("Show Times", isOn: $tester.showTimestamps)
            Toggle("Show Pings", isOn: $tester.showPings)
            Toggle("Show Replies", isOn: $tester.showReplies)
            
            Spacer()
            
            HStack {
                Text("SmartLink")
                Button(smartLinkButtonText) {
                    if radioManager.smartLinkIsLoggedIn {
                        radioManager.smartLinkLogout()
                    } else {
                        radioManager.smartLinkLogin()
                    }
                }
            }
            .frame(width: 250)
            .disabled(radioManager.delegate.smartLinkEnabled == false || radioManager.isConnected)
            
            Spacer()
            
            Button("Defaults") {
                radioManager.chooseDefaults()
            }
            .disabled(radioManager.isConnected)
        }
    }
}

struct TopButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate) )
    }
}
