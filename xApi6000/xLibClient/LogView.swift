//
//  LogViewer.swift
//  xLibClient package
//
//  Created by Douglas Adams on 10/10/20.
//

import SwiftUI

struct LogView: View {
  let logViewerWindow : NSWindow?
  @EnvironmentObject var radioManager: RadioManager

  let width : CGFloat = 1000
  
  enum logFilter: String, Equatable, CaseIterable {
    case none     = "None"
    case prefix   = "Prefix"
    case includes = "Includes"
    case excludes = "Excludes"
  }
  
  enum logLevel: String, Equatable, CaseIterable {
    case debug    = "Debug"
    case verbose  = "Verbose"
    case info     = "Info"
    case warning  = "Warning"
    case error    = "Error"
    case severe   = "Severe"
  }
  
  @State var filterBy : logFilter = .none
  @State var level    : logLevel  = .debug
  @State var filterText = "some text"

  var body: some View {

    VStack {
      ScrollView {
        VStack {
          ForEach(radioManager.logLines) { line in
            Text(line.text)
              .font(.system(.subheadline, design: .monospaced))
              .frame(minWidth: width, maxWidth: .infinity, alignment: .leading)
          }
          .padding(.leading, 5)
        }
      }
      HStack {
        Picker(selection: $level, label: Text("")) {
          ForEach(logLevel.allCases, id: \.self) {
            Text($0.rawValue)
          }
        }
        .frame(width: 150, height: 18, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .padding(.leading, 10)
        .padding(.trailing, 20)
        
        Picker(selection: $filterBy, label: Text("Filter By")) {
          ForEach(logFilter.allCases, id: \.self) {
            Text($0.rawValue)
          }
        }
        .frame(width: 150, height: 18, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        
        TextField("Filter text", text: $filterText)
          .background(Color(.gray))
          .frame(width: 200, alignment: .leading)
          .padding(.trailing, 20)
        
        Spacer()
        
        Button(action: {radioManager.loadLog() }) {Text("Load") }.padding(.trailing, 20)
        Button(action: {radioManager.saveLog() }) {Text("Save")}.padding(.trailing, 10)
        Toggle("Short", isOn: $radioManager.shortLogView).frame(width: 150, alignment: .leading)
        Button(action: {radioManager.logViewerIsOpen = false}) {Text("Close")}.padding(.trailing, 20)

      }
      .padding(.bottom, 10)
    }
    .frame(minWidth: width, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 400, maxHeight: .infinity)
  }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
      LogView(logViewerWindow: NSWindow()).environmentObject( RadioManager(delegate: Tester()))
    }
}
