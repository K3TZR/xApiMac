//
//  BottomButtonsView.swift
//  xApiMac
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI
import xClientMac

struct BottomButtonsView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radioManager: RadioManager

    var body: some View {

        VStack(alignment: .leading) {
            HStack {
                Stepper("Font Size", value: $tester.fontSize, in: 8...24).frame(width: 175)
                Spacer()
                HStack {
                    Toggle("Clear on Connect", isOn: $tester.clearAtConnect).frame(width: 190)
                    Toggle("Clear on Disconnect", isOn: $tester.clearAtDisconnect).frame(width: 215)
                }
                Spacer()
                Button("Clear Now") { tester.clearObjectsAndMessages() }

                Spacer()
                Button("Log Window") { tester.toggleLogWindow() }
            }
        }
    }
}

struct BottomButtonsView_Previews: PreviewProvider {

    static var previews: some View {
        BottomButtonsView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate) )
    }
}
