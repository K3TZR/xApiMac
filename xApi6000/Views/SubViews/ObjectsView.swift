//
//  ObjectsView.swift
//  xApi6000
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI

struct ObjectsView: View {
  @EnvironmentObject var tester: Tester
  
  var body: some View {
    ScrollableView(scrollTo: $tester.objectsScrollTo) {
      ForEach(self.tester.filteredObjects) { object in
        Text(object.line.text)
          .padding(.leading, 5)
          .font(.system(.subheadline, design: .monospaced))
          .frame(minWidth: 400, maxWidth: .infinity, maxHeight: 18, alignment: .leading)
          .foregroundColor(Color(object.line.color))
      }
    }
    .background(Color(.textBackgroundColor))
  }
}

struct ObjectsView_Previews: PreviewProvider {
  static var previews: some View {
    ObjectsView()
      .environmentObject(Tester())
  }
}
