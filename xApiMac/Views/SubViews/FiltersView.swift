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
            FilterObjectsView(object: tester)
            FilterMessagesView(object: tester)
        }
    }
}

struct FilterObjectsView: View {
    @ObservedObject var object: Tester

    var body: some View {

        HStack {
            Picker("Show objects of type", selection: object.$objectsFilterBy) {
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

    var body: some View {

        HStack {
            Picker("Filter messages by", selection: object.$messagesFilterBy) {
                ForEach(MessageFilters.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .onChange(of: object.messagesFilterBy, perform: { value in
                object.filterUpdate(filterBy: value, filterText: object.messagesFilterText)
            })
            .frame(width: 275)

            TextField("Filter text", text: object.$messagesFilterText)
                .onChange(of: object.messagesFilterText, perform: { value in
                    object.filterUpdate(filterBy: object.messagesFilterBy, filterText: value)
                })
                .modifier(ClearButton(boundText: object.$messagesFilterText))
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
