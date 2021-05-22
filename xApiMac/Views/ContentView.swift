//
//  ContentView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/9/20.
//

import SwiftUI
import xClient6001

struct ContentView: View {
    @EnvironmentObject var tester: Tester
    @EnvironmentObject var radioManager: RadioManager
    @State var selectedView: Views

    var body: some View {
        Group {
            if selectedView == .apiTester {
                ApiTesterView()
                    .environmentObject(tester)
                    .environmentObject(radioManager)
                    .padding(.horizontal)

            } else {
                LogView()
                    .environmentObject(LogManager.sharedInstance)
                    .environmentObject(radioManager)
                    .padding(.horizontal)
            }
        }
        .frame(minWidth: 920, minHeight: 400)
        .toolbar {
            ToolbarItemGroup {
                Button(Views.apiTester.rawValue) { selectedView = .apiTester }
                Button(Views.logViewer.rawValue) { selectedView = .logViewer }
            }
        }
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
        ContentView(selectedView: .apiTester)
            .environmentObject(Tester())
            .environmentObject(RadioManager(delegate: Tester() as RadioManagerDelegate))
        ContentView(selectedView: .logViewer)
            .environmentObject(Tester())
            .environmentObject(RadioManager(delegate: Tester() as RadioManagerDelegate))
    }
}
