//
//  ObjectFilterView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/10/20.
//

import SwiftUI
import xClient

struct FilterView: View {
    let filterType: FilterType
    @ObservedObject var tester: Tester

    var body: some View {

        HStack {
            if filterType == .messages {
                Picker("Filter messages by", selection: $tester.messagesFilterBy) {
                    ForEach(FilterMessages.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }.frame(width: 250)

            } else {
                Picker("Filter objects by", selection: $tester.objectsFilterBy) {
                    ForEach(FilterObjects.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }.frame(width: 250)

            }
            TextField("Filter text", text: filterType == .messages ? $tester.messagesFilterText : $tester.objectsFilterText)
                .modifier(ClearButton(boundText: filterType == .messages ? $tester.messagesFilterText : $tester.objectsFilterText))
        }
        .pickerStyle(MenuPickerStyle())
    }
}

struct FilterView_Previews: PreviewProvider {

    static var previews: some View {
        FilterView(filterType: .messages, tester: Tester())
    }
}
