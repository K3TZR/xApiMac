//
//  SendView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/9/20.
//

import SwiftUI
import xClient

struct SendView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radioManager: RadioManager

    var body: some View {

        HStack(spacing: 40) {
            Button("Send") {
                    radioManager.send(command: tester.cmdToSend)
                    tester.sent(command: tester.cmdToSend)
            }
            .frame(width: 40, alignment: .leading)
            .disabled(!radioManager.isConnected)

            TextField("Command to send", text: $tester.cmdToSend)
                .modifier(ClearButton(boundText: $tester.cmdToSend))

            Spacer()
            Toggle("Clear on Send", isOn: $tester.clearOnSend).frame(width: 170)
        }
    }
}

//public struct ClearButton: ViewModifier {
//    var text: Binding<String>
//
//    public init(boundText: Binding<String>) {
//        self.text = boundText
//    }
//
//    public func body(content: Content) -> some View {
//        ZStack(alignment: .trailing) {
//            content
//
//            if !text.wrappedValue.isEmpty {
//                Image(systemName: "x.circle")
//                    .resizable()
//                    .frame(width: 17, height: 17)
//                    .onTapGesture {
//                        text.wrappedValue = ""
//                    }
//            }
//        }
//    }
//}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView(tester: Tester(), radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate))
    }
}
