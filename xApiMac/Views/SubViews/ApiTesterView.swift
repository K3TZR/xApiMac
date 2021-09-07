//
//  ApiTester.swift
//  xApiMac
//
//  Created by Douglas Adams on 3/29/21.
//

import SwiftUI
import xClient6001

struct ApiTesterView: View {
    @EnvironmentObject var tester: Tester
    @EnvironmentObject var radioManager: RadioManager

    var body: some View {
        VStack(alignment: .leading) {
            TopButtonsView()
                .environmentObject(tester)
                .environmentObject(radioManager)
            SendView(tester: tester, radioManager: radioManager)
            FiltersView(tester: tester)

            Divider().background(Color(.red))

            VSplitView {
                if radioManager.activeRadio == nil {
                    EmptyView()
                } else {
                    ObjectsView(tester: tester, radio: radioManager.activeRadio!)
                }
                MessagesView()
                    .environmentObject(tester)
            }

            Divider().background(Color(.red))
//            BottomButtonsView(tester: tester, radioManager: radioManager)
            BottomButtonsView(tester: tester)
        }
        .padding()
    }
}

struct ApiTester_Previews: PreviewProvider {
    static var previews: some View {
        ApiTesterView()
            .environmentObject(Tester())
            .environmentObject(RadioManager(delegate: Tester() as RadioManagerDelegate))
    }
}
