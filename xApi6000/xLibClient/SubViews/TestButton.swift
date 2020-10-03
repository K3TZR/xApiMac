//
//  TestButton.swift
//  xLibClient package
//
//  Created by Douglas Adams on 8/15/20.
//

import SwiftUI

struct TestButton: View {
  @EnvironmentObject var radioManager :RadioManager

  var body: some View {
    

    HStack {
      // only enable Test if a SmartLink connection is selected
      let testEnabled = radioManager.pickerSelection.count > 0 && radioManager.packets[radioManager.pickerSelection.first!].isWan

      Button(action: { radioManager.testSmartLink() }) {Text("Test")}.disabled(testEnabled)
        .padding(.horizontal, 20)
      Circle()
        .fill(radioManager.smartLinkTestStatus ? Color.green : Color.red)
        .frame(width: 20, height: 20)
        .padding(.trailing, 20)
    }
  }
}
  
  struct TestButton_Previews: PreviewProvider {
    static var previews: some View {
      TestButton()
        .environmentObject(RadioManager(delegate: MockRadioManagerDelegate()))
    }
  }
