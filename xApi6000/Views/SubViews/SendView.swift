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
      Button(action: {self.tester.sendCommand(tester.cmdToSend)}) {
        Text("Send").frame(width: 70, alignment: .center)
      }.padding(.horizontal)
      .disabled(tester.isConnected == false)
      HStack {
        TextField("Command to send", text: $tester.cmdToSend).frame(width: 550, alignment: .leading)
        Toggle("Clear on Send", isOn: $tester.clearOnSend).frame(width: 110, alignment: .leading)
      }
//      .border(Color.black)
    }
    .padding(.trailing, 10)
  }
}

struct SendView_Previews: PreviewProvider {
  static var previews: some View {
    SendView()
      .environmentObject(Tester())
  }
}
