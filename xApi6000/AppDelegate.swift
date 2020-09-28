//
//  AppDelegate.swift
//  xApi6000
//
//  Created by Douglas Adams on 8/9/20.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  // ----------------------------------------------------------------------------
  // MARK: - Static properties
  
  static let kAppName = "xApi6000"

  // ----------------------------------------------------------------------------
  // MARK: - Internal properties
  
  var window: NSWindow!

  // ----------------------------------------------------------------------------
  // MARK: - Internal methods
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    // Create the SwiftUI view that provides the window contents.
    let contentView = ContentView()
      .environmentObject(Tester())

    // Create the window and set the content view.
    window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    window.center()
    window.setFrameAutosaveName("Main Window")
    window.title = AppDelegate.kAppName
    window.contentView = NSHostingView(rootView: contentView)
    window.makeKeyAndOrderFront(nil)
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

