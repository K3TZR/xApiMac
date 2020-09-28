//
//  PickerView.swift
//  xApi6000
//
//  Created by Douglas Adams on 8/15/20.
//

import SwiftUI

struct PickerView: View {

  var body: some View {
      VStack {
        SmartLinkView()
        RadioListView()
        PickerButtonsView()
      }.frame(width: 600)
    }
}

struct PickerView_Previews: PreviewProvider {
    static var previews: some View {
        PickerView()
    }
}
