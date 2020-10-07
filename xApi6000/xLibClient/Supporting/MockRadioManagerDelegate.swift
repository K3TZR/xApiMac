//
//  MockRadioManagerDelegate.swift
//  xLibClient package
//
//  Created by Douglas Adams on 9/5/20.
//

import Cocoa
import xLib6000

class MockRadioManagerDelegate : RadioManagerDelegate {

  func connectionState(_ connected: Bool, _ connection: String, _ msg: String) { /* stub */ }

  var clientId              = UUID().uuidString
  var connectAsGui          = true
  var kAppNameTrimmed       = "AppName"
  var stationName           = "MyStation"
  
  // SmartLink related
  func smartLinkLogin()     { /* stub */ }
  func smartLinkLogout()    { /* stub */ }
  func smartLinkLoginState(_ loggedIn: Bool) { /* stub */ }

  var smartLinkAuth0Email   = ""
  var smartLinkEnabled      = true
  var smartLinkWasLoggedIn  = false  

  func refreshTokenGet(service: String, account: String) -> String? { return "" }
  func refreshTokenSet(service: String, account: String, refreshToken: String) { /* stub */ }
  func refreshTokenDelete(service: String, account: String) { /* stub */ }
  func smartLinkTestResults(status: Bool, msg: String) { /* stub */ }
  func disconnectionState(_ msg: String) { /* stub */ }
  func openStatus(_ status: OpenCloseStatus, _ clients: [GuiClient], handler: @escaping (NSApplication.ModalResponse) -> Void) { /* stub */ }
  func closeStatus(_ status: OpenCloseStatus, _ clients: [GuiClient], handler: @escaping (NSApplication.ModalResponse) -> Void) { /* stub */ }
}
