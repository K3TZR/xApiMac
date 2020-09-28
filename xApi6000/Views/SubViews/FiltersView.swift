//
//  FiltersView.swift
//  xApi6000
//
//  Created by Douglas Adams on 8/10/20.
//

import SwiftUI

struct FiltersView: View {
  var body: some View {
    HStack {
      StatusView()
      FilterView(filterType: .objects)
      Spacer()
      FilterView(filterType: .messages)
        .padding(.trailing, 10)
    }
  }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView()
          .environmentObject(Tester())
    }
}
