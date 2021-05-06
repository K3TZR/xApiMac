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

    @AppStorage("fontSize") var fontSize: Int = 10

    var body: some View {
        VStack(alignment: .leading) {
            TopButtonsView()
                .environmentObject(tester)
                .environmentObject(radioManager)
            SendView(tester: tester, radioManager: radioManager)
            FiltersView(tester: tester)

            Divider()
            if radioManager.activeRadio == nil {
                EmptyView()
            } else {
                ObjectsView(radio: radioManager.activeRadio!, filter: tester.objectsFilterBy, fontSize: fontSize)
            }

            Divider().background(Color(.systemBlue))
            MessagesView(messages: tester.filteredMessages, fontSize: fontSize)

            Divider()
            BottomButtonsView(tester: tester, radioManager: radioManager)
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
