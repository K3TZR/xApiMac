//
//  ObjectsView.swift
//  xApiMac
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI

struct ObjectsView: View {
    let objects: [Object]
    let fontSize: Int

    var body: some View {

        ScrollView([.horizontal, .vertical]) {
            ForEach(objects) { object in
                Text(object.line.text)
                    .padding(.leading, 5)
                    .font(.system(size: CGFloat(fontSize), weight: .regular, design: .monospaced))
                    .frame(minWidth: 400, maxWidth: .infinity, maxHeight: 18, alignment: .leading)
                    .foregroundColor(object.line.color)
            }
            .frame( alignment: .leading)
        }
        .frame( alignment: .leading)

    }
}

struct ObjectsView_Previews: PreviewProvider {

    static var previews: some View {
        let mockObjects = [
            Object(id: 0, line: (Color.red, "A RED object")),
            Object(id: 1, line: (Color.green, "A GREEN object")),
            Object(id: 2, line: (Color.blue, "A BLUE object"))
        ]
        ObjectsView(objects: mockObjects, fontSize: 20)
            .environmentObject(Tester())
    }
}
