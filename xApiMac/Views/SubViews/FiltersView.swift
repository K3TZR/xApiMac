//
//  FiltersView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/10/20.
//

import SwiftUI
import xClient6001

struct FiltersView: View {
    @ObservedObject var tester: Tester

    var body: some View {
        HStack(spacing: 100) {
            FilterObjectsView()
            FilterMessagesView(object: tester)
        }
    }
}

struct FilterObjectsView: View {

    @AppStorage("objectsFilterBy") var objectsFilterBy: ObjectFilters = .none

    var body: some View {

        HStack {
            Picker("Hide objects of type", selection: $objectsFilterBy) {
                ForEach(ObjectFilters.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .frame(width: 275)
        }
        .pickerStyle(MenuPickerStyle())
    }
}

struct FilterMessagesView: View {
    @ObservedObject var object: Tester

    @AppStorage("messagesFilterBy") var messagesFilterBy: MessageFilters = .none
    @AppStorage("messagesFilterText") var messagesFilterText: String = ""

    var body: some View {

        HStack {
            Picker("Filter messages by", selection: $messagesFilterBy) {
                ForEach(MessageFilters.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .onChange(of: messagesFilterBy, perform: { value in
                object.filterUpdate(filterBy: value, filterText: messagesFilterText)
            })
            .frame(width: 275)

            TextField("Filter text", text: $messagesFilterText)
                .onChange(of: messagesFilterText, perform: { value in
                    object.filterUpdate(filterBy: messagesFilterBy, filterText: value)
                })
                .modifier(ClearButton(boundText: $messagesFilterText))
        }
        .pickerStyle(MenuPickerStyle())
    }
}

struct FiltersView_Previews: PreviewProvider {

    static var previews: some View {
        FiltersView(tester: Tester())
            .previewLayout(.fixed(width: 2160 / 2.0, height: 1620 / 2.0))
    }
}
