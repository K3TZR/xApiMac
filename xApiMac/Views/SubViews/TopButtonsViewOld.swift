//
//  TopButtonsView.swift
//  xApiMac
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI
import xClientMac

struct TopButtonsViewOld: View {
  @EnvironmentObject var tester : Tester
  
  var body: some View {
    
    VStack(alignment: .leading) {
      HStack {
        // Top row
        Button(action: {tester.startStop()}) {
          Text(tester.isConnected ? "Start" : "Stop" ).frame(width: 70, alignment: .center)
        }.padding(.horizontal)
        .sheet(isPresented: $tester.radioManager.showPickerSheet) {
          PickerView().environmentObject(tester.radioManager)
        }
        HStack (spacing: 20){
          Text("Enable -->").frame(width: 80, alignment: .leading)
          Toggle("Gui", isOn: $tester.enableGui).frame(width: 80, alignment: .leading)
          Toggle("Pinging", isOn: $tester.enablePinging).frame(width: 80, alignment: .leading)
          Toggle("SmartLink", isOn: $tester.enableSmartLink).frame(width: 80, alignment: .leading)
          
          Spacer()
          
          Button(action: {tester.radioManager.showPicker()}) {
            Text("Picker").frame(width: 70, alignment: .center)
          }.padding(.trailing, 10)
          .disabled(tester.isConnected)
          .sheet(isPresented: $tester.radioManager.showPickerSheet) {
            PickerView().environmentObject(tester.radioManager)
          }
        }
        .padding(5)
//        .border(Color(.textColor))
      }
      
      // Bottom row
      HStack(spacing: 20) {
        Text("Show -->").frame(width: 80, alignment: .leading).padding(.leading, 130)
          Toggle("Times", isOn: $tester.showTimestamps).frame(width: 80, alignment: .leading)
          Toggle("Pings", isOn: $tester.showPings).frame(width: 80, alignment: .leading)
          Toggle("Replies", isOn: $tester.showAllReplies).frame(width: 80, alignment: .leading)
//        .border(Color(.textColor))
      }
    }
  }
}

struct TopButtonsViewOld_Previews: PreviewProvider {
  static var previews: some View {
    TopButtonsViewOld()
      .environmentObject(Tester())
  }
}
