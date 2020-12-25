//
//  TopButtonsView.swift
//  xApiIos
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI
import xClientMac

struct TopButtonsView: View {
    @EnvironmentObject var tester : Tester
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack (spacing: 40){
                // Top row
                Button(action: {tester.startStop()} ) {
                    Text(tester.isConnected ? "Stop" : "Start" )
                }
                .help("Using the Default connection type")
                .padding(.bottom, 30)
                
                VStack (alignment: .leading) {
                    Toggle(isOn: $tester.enableGui) {
                        Text("Connect as Gui")}
                    Toggle(isOn: $tester.showTimestamps) {
                        Text("Show Times")}.padding(.bottom, 10)
                }
                
                VStack (alignment: .leading) {
                    Toggle(isOn: $tester.connectToFirstRadio) {
                        Text("Connect to First Radio")}
                    Toggle(isOn: $tester.showPings) {
                        Text("Show Pings")}.padding(.bottom, 10)
                }
                
                VStack (alignment: .leading) {
                    Toggle(isOn: $tester.enablePinging) {
                        Text("Enable pinging")}
                    Toggle(isOn: $tester.showReplies) {
                        Text("Show Replies")}.padding(.bottom, 10)
                }
                
                Toggle(isOn: $tester.enableSmartLink) {
                    Text("Enable SmartLink")}.padding(.bottom, 30)
                
                Spacer()
                
                Button(action: {tester.resetDefault()}) {
                    Text("Reset Default")                    
                }
                .help("Clear all default(s)")
                .padding(.bottom, 30)
            }
        }
        .padding(.top, 10)
    }
}

struct TopButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        TopButtonsView()
            .environmentObject(Tester())
            .previewLayout(.fixed(width: 2160 / 2.0, height: 1620 / 2.0))
    }
}
