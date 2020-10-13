//
//  StubView.swift
//  xLibClient package
//
//  Created by Douglas Adams on 8/25/20.
//

import SwiftUI

struct StubView: View {
  @ObservedObject var radioManager: RadioManager
  
  var body: some View {
    ZStack {
      Text("")
        .sheet(isPresented: $radioManager.showPickerSheet) {
          PickerView()
            .environmentObject(radioManager)
        }
      Text("")
        .sheet(isPresented: $radioManager.showAuth0Sheet ) {
          Auth0View()
            .environmentObject(radioManager)
        }
    }
  }
}

struct StubView_Previews: PreviewProvider {
  static var previews: some View {
    StubView(radioManager: RadioManager(delegate: MockRadioManagerDelegate(), domain: "net.k3tzr", appName: "xApi6000"))
  }
}
