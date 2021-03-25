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

    @State var selectedTab = 1

    var body: some View {

        TabView {
            ApiTab()
                .environmentObject(tester)
                .environmentObject(radioManager)
                .tabItem {
                    Text("Api Tester")
                }

            LogView()
                .environmentObject(LogManager.sharedInstance)
                .environmentObject(radioManager)
                .tabItem {
                    Text("Log View")
                }
        }
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

struct ApiTab: View {
    @EnvironmentObject var tester: Tester
    @EnvironmentObject var radioManager: RadioManager

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
            BottomButtonsView(tester: tester, radioManager: radioManager)
        }
        .frame(minWidth: 920, minHeight: 400)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate) )
    }
}
