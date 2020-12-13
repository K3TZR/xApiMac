//
//  FiltersView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/10/20.
//

import SwiftUI

struct FiltersView: View {
  var body: some View {
    HStack {
      FilterView(filterType: .objects)
      Spacer()
      FilterView(filterType: .messages)
    }
    .padding(.horizontal, 10)
  }
}

struct FiltersView_Previews: PreviewProvider {
  static var previews: some View {
    FiltersView()
      .environmentObject(Tester())
  }
}
