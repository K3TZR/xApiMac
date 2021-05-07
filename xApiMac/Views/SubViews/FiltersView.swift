//
//  FiltersView.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/10/20.
//

import SwiftUI

struct FiltersView: View {
    @ObservedObject var tester: Tester

    @State var dummyText = ""
    @AppStorage("objectsFilterBy") var objectsFilterBy: String = ""
    @AppStorage("messagesFilterBy") var messagesFilterBy: String = ""
    @AppStorage("messagesFilterText") var messagesFilterText: String = ""

    var body: some View {
        HStack(spacing: 40) {

            FilterView(selection: $objectsFilterBy,
                        text: $dummyText,
                        choices: ObjectFilters.allCases.map {$0.rawValue},
                        message: "Hide Objects of type",
                        showText: false,
                        object: tester)
            FilterView(selection: $messagesFilterBy,
                        text: $messagesFilterText,
                        choices: MessageFilters.allCases.map {$0.rawValue},
                        message: "Filter Messages by",
                        showText: true,
                        object: tester)
        }
    }
}

struct FiltersView_Previews: PreviewProvider {

    static var previews: some View {
        FiltersView(tester: Tester())
            .previewLayout(.fixed(width: 2160 / 2.0, height: 1620 / 2.0))
    }
}
