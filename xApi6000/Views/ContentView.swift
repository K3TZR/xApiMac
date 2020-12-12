//
//  ContentView.swift
//  xApi6000
//
//  Created by Douglas Adams on 8/9/20.
//

import SwiftUI
import xClientMac

struct ContentView: View {
  @EnvironmentObject var tester: Tester
  @EnvironmentObject var appDelegate: AppDelegate

  var body: some View {
    VStack(alignment: .leading) {
      TopButtonsView()
      SendView()
      FiltersView()
      Divider().frame(height: 2).background(Color(.disabledControlTextColor))
      ObjectsView(objects: tester.filteredObjects, fontSize: tester.fontSize)
      Divider().frame(height: 2).background(Color(.disabledControlTextColor))
      MessagesView(messages: tester.filteredMessages, showTimestamps: tester.showTimestamps, fontSize: tester.fontSize)
      Divider().frame(height: 2).background(Color(.disabledControlTextColor))
      BottomButtonsView().environmentObject(appDelegate)
      StubView(radioManager: tester.radioManager)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(Tester())
  }
}
