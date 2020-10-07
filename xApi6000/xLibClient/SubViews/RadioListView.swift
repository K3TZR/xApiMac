//
//  RadioListView.swift
//  xLibClient package
//
//  Created by Douglas Adams on 8/13/20.
//

import SwiftUI

struct RadioListView : View {
  @EnvironmentObject var radioManager : RadioManager

  var body: some View {
    
    VStack {
      HStack {
        Text("Type")
          .frame(width: 90, alignment: .leading)
        Text("Name")
          .frame(width: 150, alignment: .leading)
        Text("Status")
          .frame(width: 100, alignment: .leading)
        Text("Station(s)")
          .frame(width: 200, alignment: .leading)
      }.padding(.top, 10)
      HStack {
        List(radioManager.pickerPackets, id: \.id, selection: $radioManager.pickerSelection) { packet in
          HStack{
            Text(packet.type == .local ? "LOCAL" : "SMARTLINK")
              .frame(width: 90, alignment: .leading)
            Text(packet.nickname)
              .frame(width: 150, alignment: .leading)
            Text(packet.status.rawValue)
              .frame(width: 100, alignment: .leading)
            Text(packet.stations)
              .frame(width: 200, alignment: .leading)
            Spacer()
          }
        }
      }.frame(width: 600, height: 150)
      .padding(.bottom, 0)
    }
  }
}

struct RadioListView_Previews: PreviewProvider {
  static var previews: some View {
    RadioListView()
      .environmentObject(RadioManager(delegate: MockRadioManagerDelegate()))
  }
}
