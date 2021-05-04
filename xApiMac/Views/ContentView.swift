//
//  ContentView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/9/20.
//

import SwiftUI
import xClient6001

struct ContentView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radioManager: RadioManager
    @State var selectedTab: Int

    var body: some View {

        TabView(selection: $selectedTab) {
            ApiTesterView()
                .environmentObject(tester)
                .environmentObject(radioManager)
                .tabItem {Text("Api Tester")}
                .padding(.horizontal)
                .tag(1)

            LogView()
                .environmentObject(LogManager.sharedInstance)
                .environmentObject(radioManager)
                .tabItem {Text("Log View")}
                .padding(.horizontal)
                .tag(2)
        }
//        .onAppear {
//            if tester.smartlinkIsEnabled && tester.smartlinkWasLoggedIn {
//                radioManager.smartlinkLogin(showPicker: false)
//            }
//        }
        .frame(minWidth: 920, minHeight: 400)

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
        ContentView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate), selectedTab: 1)
        ContentView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate), selectedTab: 2)
    }
}
