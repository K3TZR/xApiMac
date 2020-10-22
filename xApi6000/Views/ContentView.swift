//
//  ContentView.swift
//  xApi6000
//
//  Created by Douglas Adams on 8/9/20.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var appDelegate: AppDelegate
  @EnvironmentObject var tester: Tester
  
  let width : CGFloat = 975
  
  var body: some View {
    VStack(alignment: .leading) {
      TopButtonsView()
        .frame(minWidth: width, idealWidth: width, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .leading)
      SendView()
        .frame(minWidth: width, idealWidth: width, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 20, idealHeight: 20, maxHeight: 20, alignment: .leading)
      FiltersView()
        .frame(minWidth: width, idealWidth: width, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .leading)
      ObjectsView()
        .frame(minWidth: width, idealWidth: width, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 250, idealHeight: 500, maxHeight: .infinity, alignment: .leading)
      MessagesView()
        .frame(minWidth: width, idealWidth: width, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 250, idealHeight: 500, maxHeight: .infinity, alignment: .leading)
      BottomButtonsView()
        .frame(minWidth: width, idealWidth: width, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 25, idealHeight: 25, maxHeight: 25, alignment: .leading)
      StubView(radioManager: tester.radioManager)
    }
    .padding(.top, 10)
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        ContentView()
          .environmentObject(Tester())
          .environmentObject(AppDelegate())
      }
    }
}
