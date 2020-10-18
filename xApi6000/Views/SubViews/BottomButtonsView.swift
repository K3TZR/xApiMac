//
//  BottomButtonsView.swift
//  xApi6000
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI

struct BottomButtonsView: View {
  @EnvironmentObject var appDelegate : AppDelegate
  @EnvironmentObject var tester : Tester
  
  var body: some View {
    HStack {
      Toggle("Clear at Connect", isOn: $tester.clearAtConnect)
        .frame(width: 200)
      Toggle("Clear at Disconnect", isOn: $tester.clearAtDisconnect)
        .frame(width: 200)

      Spacer()

      Toggle("LogViewer", isOn: $appDelegate.logWindowIsVisible)
        .frame(width: 150, alignment: .leading)

      Spacer()

      Button(action: {self.tester.clear()}) {Text("Clear")}
    }
    .padding(.horizontal, 20)
    .padding(.top, 10)
  }
}

struct BottomButtonsView_Previews: PreviewProvider {
    static var previews: some View {
      BottomButtonsView()
        .environmentObject(Tester())
    }
}
