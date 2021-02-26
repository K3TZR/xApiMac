//
//  ContentView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/9/20.
//

import SwiftUI
import xClientMac

struct ContentView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radioManager: RadioManager

    var body: some View {
        
        VStack(alignment: .leading) {
            TopButtonsView(tester: tester, radioManager: radioManager)
            SendView(tester: tester, radioManager: radioManager)
            FiltersView(tester: tester)
            
            Divider().frame(height: 2).background(Color(.disabledControlTextColor))
            ObjectsView(objects: tester.filteredObjects, fontSize: tester.fontSize)
            
            Divider().frame(height: 2).background(Color(.disabledControlTextColor))
            MessagesView(messages: tester.filteredMessages, showTimestamps: tester.showTimestamps, fontSize: tester.fontSize)
            
            Divider().frame(height: 2).background(Color(.disabledControlTextColor))            
            BottomButtonsView(tester: tester, radioManager: radioManager)
        }
        .frame(minWidth: 920, minHeight: 400)
        .padding()
        
        // Sheet presentation
        .sheet(item: $radioManager.activeSheet) { sheetType in
            switch sheetType {
            
            case .defaultPicker:            DefaultPickerView().environmentObject(radioManager)
            case .genericAlert:             GenericAlertView().environmentObject(radioManager)
            case .radioPicker:              RadioPickerView().environmentObject(radioManager)
            case .smartlinkAuthorization:   SmartlinkAuthorizationView().environmentObject(radioManager)
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
