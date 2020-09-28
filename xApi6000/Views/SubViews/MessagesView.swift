//
//  MessagesView.swift
//  xApi6000
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI

struct MessagesView: View {
  @EnvironmentObject var tester: Tester
  
  func showTimestamps(_ showTimestamps: Bool, text: String) -> String {
    if showTimestamps {
      return text
    } else {
      return String(text.dropFirst(9))
    }
  }
  
  func lineColor(_ text: String) -> Color {
    var color = Color(.textColor)
    
    let base = text.dropFirst(9)
    if base.prefix(1) == "C" { color = Color(.systemGreen) }
    if base.prefix(1) == "R" { color = Color(.systemRed) }
    if base.prefix(2) == "S0" { color = Color(.systemBrown) }

    return color
  }
  
  var body: some View {
    ScrollableView(scrollTo: $tester.messagesScrollTo) {
      ForEach(self.tester.filteredMessages) { message in
        Text(self.showTimestamps(self.tester.showTimestamps, text: message.text))
          .padding(.leading, 5)
          .font(.system(.subheadline, design: .monospaced))
          .frame(minWidth: 400, maxWidth: .infinity, maxHeight: 18, alignment: .leading)
          .foregroundColor( lineColor(message.text) )
      }
    }
    .background(Color(.textBackgroundColor))
  }
}

struct MessagesView_Previews: PreviewProvider {
  static var previews: some View {
    MessagesView()
      .environmentObject(Tester())
  }
}
