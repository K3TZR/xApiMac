//
//  ContentView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/9/20.
//

import SwiftUI
import xClient

struct ContentView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radioManager: RadioManager

    var body: some View {

        VStack(alignment: .leading) {
            TopButtonsView(tester: tester, radioManager: radioManager)
            SendView(tester: tester, radioManager: radioManager)
            FiltersView(tester: tester)

            Divider()
            ObjectsView(objects: tester.filteredObjects, fontSize: tester.fontSize)

            Divider().background(Color(.systemBlue))
            MessagesView(messages: tester.filteredMessages, showTimestamps: tester.showTimestamps, fontSize: tester.fontSize)

            Divider()
            BottomButtonsView(tester: tester)
        }
        .frame(minWidth: 920, minHeight: 400)
        .padding()

        // Sheet presentation
        .sheet(item: $radioManager.activeView) { viewType in
            switch viewType {

            case .genericAlert:             GenericAlertView().environmentObject(radioManager)
            case .radioPicker:              RadioPickerView().environmentObject(radioManager)
            case .smartlinkAuthentication:  smartlinkAuthenticationView().environmentObject(radioManager)
            case .smartlinkStatus:          SmartlinkStatusView().environmentObject(radioManager)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate) )
    }
}
