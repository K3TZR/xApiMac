//
//  TopButtonsView.swift
//  xApi6000
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI

struct TopButtonsView: View {
  @EnvironmentObject var tester : Tester
  
  func insertChoice(_ item: String, into stations: [Station]) -> [Station] {
    var choices = [Station]()

    choices.append( Station(id: 0, name: item, clientId: nil))
    for station in stations {
      choices.append( Station(id: station.id + 1, name: station.name, clientId: station.clientId) )
    }
    return choices
  }

  var body: some View {
    
    VStack {
      
      let stationChoices = insertChoice("All", into: tester.radioManager.stations)

      HStack {
        // Top row
        Button(action: {
          tester.startStopTester()
        })
        {Text(tester.isConnected ? "Disconnect" : "Connect")
          .frame(width: 70, alignment: .center)
        }
        .sheet(isPresented: $tester.radioManager.showPickerSheet) {
          PickerView().environmentObject(tester.radioManager)
        }
        .padding(.leading, 10)
        .padding(.trailing, 20)
        Toggle("Connect as Gui", isOn: $tester.connectAsGui)
          .frame(width: 150, alignment: .leading)
        Toggle("Enable pinging", isOn: $tester.enablePinging)
          .frame(width: 150, alignment: .leading)
        Toggle("Show ALL replies", isOn: $tester.showAllReplies)
          .frame(width: 150, alignment: .leading)
        Spacer()
        Picker(selection: $tester.radioManager.stationSelection, label: Text("Show Station")) {
          ForEach(stationChoices, id: \.id) {
            Text($0.name)
          }
        }
        .frame(width: 300, height: 18, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .padding(.trailing, 10)
      }
      
      // Bottom row
      .padding(.top, 10)
      HStack {
        Toggle("Show timestamps", isOn: $tester.showTimestamps)
          .frame(width: 150, alignment: .leading)
          .padding(.leading, 133)
        Toggle("Show pings", isOn: $tester.showPings)
          .frame(width: 150, alignment: .leading)
        Toggle("SmartLink enabled", isOn: $tester.smartLinkEnabled)
          .frame(width: 150, alignment: .leading)
        Spacer()
      }
    }
  }
}

struct TopButtonsView_Previews: PreviewProvider {
  static var previews: some View {
    TopButtonsView()
      .environmentObject(Tester())
  }
}
