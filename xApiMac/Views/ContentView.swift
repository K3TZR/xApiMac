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
            
            BottomButtonsView(tester: tester)
        }
        .frame(minWidth: 920, minHeight: 400)
        .padding()
        
        // Sheet presentation
        .sheet(item: $radioManager.activeSheet) { sheetType in
            switch sheetType {
            case .alert:    AlertView()
                .environmentObject(radioManager)
//                .onDisappear(perform: {print("TODO: On dismiss AlertView")})
            case .auth0:    Auth0View()
                .environmentObject(radioManager)
//                .onDisappear(perform: {print("TODO: On dismiss Auth0View")})
            case .picker:   PickerView()
                .environmentObject(radioManager)
                .onDisappear(perform: {radioManager.connect(to: radioManager.pickerSelection)})
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate) )
    }
}
