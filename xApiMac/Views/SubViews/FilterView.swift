//
//  FilterView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/10/20.
//

import SwiftUI
import xClient6001

struct FilterView: View {
    @Binding var selection: String
    @Binding var text: String
    let choices: [String]
    let message: String
    let showText: Bool

    var body: some View {

        HStack {
            Picker(message, selection: $selection) {
                ForEach(choices, id: \.self) {
                    Text($0)
                }
            }
            .frame(width: 350)

            if showText {
                TextField("Filter text", text: $text)
                .modifier(ClearButton(boundText: $text))
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

// struct FilterView_Previews: PreviewProvider {
//
//    @State var filterBy: String = "none"
//    @State var filterText: String = "sample filter text"
//    @State var selection: String = "none"
//
//    static var previews: some View {
//        FilterView(selection: $filterBy,
//                    text: $filterText,
//                    choices: FilterObjects.allCases.map {$0.rawValue},
//                    message: "Filter Objects by")
//    }
// }
