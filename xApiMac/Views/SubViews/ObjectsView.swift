//
//  ObjectsView.swift
//  xApiMac
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI

struct ObjectsView: View {
  let objects   : [Object]
  let fontSize  : Int
  
  var body: some View {

    ScrollView {
      VStack(alignment: .leading, spacing: 2, content: {
        ForEach(objects) { object in
          Text(object.line.text)
            .padding(.leading, 5)
            .font(.system(size: CGFloat(fontSize), weight: .regular, design: .monospaced))
            .frame(minWidth: 400, maxWidth: .infinity, maxHeight: 18, alignment: .leading)
            .foregroundColor(Color(object.line.color))
        }
      })
    }
  }
}

struct ObjectsView_Previews: PreviewProvider {
  static var previews: some View {
    let mockObjects = [
      Object(id: 0, line: (NSColor.systemRed, "A RED object")),
      Object(id: 1, line: (NSColor.systemGreen, "A GREEN object")),
      Object(id: 2, line: (NSColor.systemBlue, "A BLUE object"))
    ]
    ObjectsView(objects: mockObjects, fontSize: 12)
      .environmentObject(Tester())
  }
}
