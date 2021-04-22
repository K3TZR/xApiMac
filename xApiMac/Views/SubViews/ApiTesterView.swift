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
            TopButtonsView(tester: tester, radioManager: radioManager)
            SendView(tester: tester, radioManager: radioManager)
            FiltersView(tester: tester)

            Divider()
            ObjectsView(radioManager: radioManager, filter: tester.objectsFilterBy, fontSize: tester.fontSize)

            Divider().background(Color(.systemBlue))
            MessagesView(messages: tester.filteredMessages, showTimestamps: tester.showTimestamps, fontSize: tester.fontSize)

            Divider()
            BottomButtonsView(tester: tester, radioManager: radioManager)
        }
//        .frame(minWidth: 920, minHeight: 400)
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
