//
//  SendView.swift
//  xApi6000
//
//  Created by Douglas Adams on 8/9/20.
//

import SwiftUI

struct SendView: View {
  @EnvironmentObject var tester : Tester

  var body: some View {
    HStack {
      Button(action: {self.tester.send()})
      {Text("Send")
        .frame(width: 70, alignment: .center)
      }
      .disabled(tester.isConnected == false)
      .padding(.leading, 10)
      .padding(.trailing, 20)
      TextField("Command to send", text: $tester.cmdToSend)
        .frame(width: 650, alignment: .leading)
        .padding(.trailing, 20)
      Spacer()
      Toggle("Clear on Send", isOn: $tester.clearOnSend)
        .frame(width: 110, alignment: .leading)
        .padding(.trailing, 10)
    }
    .padding(.top, 10)
  }
}

struct SendView_Previews: PreviewProvider {
  static var previews: some View {
    SendView()
      .environmentObject(Tester())
  }
}
