//
//  BottomButtonsView.swift
//  xApiMac
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI
import xClient6001

struct BottomButtonsView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radioManager: RadioManager
    @Environment(\.openURL) var openURL

    @AppStorage("clearAtConnect") var clearAtConnect: Bool = false
    @AppStorage("clearAtDisconnect") var clearAtDisconnect: Bool = false
    @AppStorage("fontSize") var fontSize: Int = 10

    var body: some View {

        HStack(spacing: 40) {
            Stepper("Font Size", value: $fontSize, in: 8...16)
            Text("\(fontSize)").frame(alignment: .leading)
            Spacer()
            Toggle("Clear on Connect", isOn: $clearAtConnect)
            Toggle("Clear on Disconnect", isOn: $clearAtDisconnect)
            Button("Clear Now") { tester.clearMessages() }
        }
    }
}

struct BottomButtonsView_Previews: PreviewProvider {

    static var previews: some View {
        BottomButtonsView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate) )
    }
}
