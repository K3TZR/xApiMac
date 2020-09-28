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

  var body: some View {
    HStack {
      Toggle("Clear at Connect", isOn: $tester.clearAtConnect)
        .padding(.leading, 20)
        .frame(width: 200)
      Toggle("Clear at Disconnect", isOn: $tester.clearAtDisconnect)
        .frame(width: 200)
      Spacer()
      Button(action: {self.tester.clear()}) {Text("Clear")}
        .padding(.trailing, 20)
    }
//    .padding(.bottom, 10)
    .padding(.top, 10)
  }
}

struct BottomButtonsView_Previews: PreviewProvider {
    static var previews: some View {
      BottomButtonsView()
        .environmentObject(Tester())
    }
}
