//
//  PickerView.swift
//  xLibClient package
//
//  Created by Douglas Adams on 8/15/20.
//

import SwiftUI

struct PickerView: View {
  @EnvironmentObject var radioManager: RadioManager
  
  var body: some View {
      VStack {
        if radioManager.delegate.smartLinkEnabled { SmartLinkView() }
        RadioListView()
        PickerButtonsView()
      }.frame(width: 600)
    }
}

struct PickerView_Previews: PreviewProvider {
    static var previews: some View {
      PickerView().environmentObject(RadioManager(delegate: Tester()))
    }
}
