//
//  BottomButtonsView.swift
//  xApi6000
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI

struct BottomButtonsView: View {
  @EnvironmentObject var tester : Tester
  @EnvironmentObject var appDelegate : AppDelegate
  
  var body: some View {
    
    VStack(alignment: .leading, spacing: 0, content: {
      HStack (spacing: 10){
        Text("Clear on -->").frame(width: 80, alignment: .leading)
        Toggle("Connect", isOn: $tester.clearAtConnect).frame(width: 90, alignment: .leading)
        Toggle("Disconnect", isOn: $tester.clearAtDisconnect).frame(width: 90, alignment: .leading)
        Spacer()
        Toggle("Log Window", isOn: $appDelegate.logWindowIsVisible).frame(width: 100, alignment: .leading)
        Spacer()
        Button(action: {self.tester.clearObjectsAndMessages()}) {Text("Clear")}
      }
    })
    .padding(.horizontal, 20)
//    .border(Color(.textColor))
  }
}

struct BottomButtonsView_Previews: PreviewProvider {
    static var previews: some View {
      BottomButtonsView()
        .environmentObject(Tester())
        .environmentObject(AppDelegate())
    }
}
