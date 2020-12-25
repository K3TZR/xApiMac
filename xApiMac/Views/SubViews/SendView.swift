//
//  SendView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/9/20.
//

import SwiftUI

struct SendView: View {
    @EnvironmentObject var tester : Tester
    
    var body: some View {
        HStack {
            Button(action: {self.tester.sendCommand(tester.cmdToSend)}) {
                Text("Send")
            }
            .disabled(tester.isConnected == false)
            
            TextField("Command to send", text: $tester.cmdToSend)
            
            Spacer()
            Toggle("Clear on Send", isOn: $tester.clearOnSend)
        }
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView()
            .environmentObject(Tester())
    }
}
