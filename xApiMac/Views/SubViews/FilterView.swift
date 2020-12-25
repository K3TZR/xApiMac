//
//  ObjectFilterView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/10/20.
//

import SwiftUI



struct FilterView: View {
    var filterType : FilterType = .messages
    @EnvironmentObject var tester : Tester
    
    var body: some View {
        HStack {
            if filterType == .messages {
                Picker(selection: $tester.messagesFilterBy, label: Text("Filter " + filterType.rawValue)) {
                    ForEach(FilterMessages.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }.frame(width: 200, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
            } else {
                Picker(selection: $tester.objectsFilterBy, label: Text("Filter " + filterType.rawValue)) {
                    ForEach(FilterObjects.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }.frame(width: 200, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
            }
            TextField("Filter text", text: filterType == .messages ? $tester.messagesFilterText : $tester.objectsFilterText)
                .background(Color(.gray))
            //        .frame(width: 200, alignment: .leading)
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
            .environmentObject(Tester())
    }
}
