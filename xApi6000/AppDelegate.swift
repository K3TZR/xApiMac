//
//  AppDelegate.swift
//  xApi6000
//
//  Created by Douglas Adams on 8/9/20.
//

import Cocoa
import xLib6000
import SwiftUI
import xLibClient

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, LoggerDelegate, ObservableObject {

  // ----------------------------------------------------------------------------
  // MARK: - Static properties
  
  static let kAppName       = "xApi6000"
  static let kDomainName    = "net.k3tzr"  

  // ----------------------------------------------------------------------------
  // MARK: - Published properties
  
  @Published var logWindowIsVisible = false { didSet{ showLogWindow(logWindowIsVisible) }}

  // ----------------------------------------------------------------------------
  // MARK: - Internal properties
  
  var window      : NSWindow!
  var logWindow   : NSWindow?

  // ----------------------------------------------------------------------------
  // MARK: - Internal methods
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    // Create the SwiftUI view that provides the window contents.
    let contentView = ContentView()

    // Create the window and set the content view.
    window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    window.center()
    window.setFrameAutosaveName(AppDelegate.kAppName + "WindowFrame")
    window.title = AppDelegate.kAppName + ", v" + Version().string
    window.contentView = NSHostingView(rootView: contentView
                                        .environmentObject(self)
                                        .environmentObject(Tester()))
    window.makeKeyAndOrderFront(nil)
    
    let logger = Logger.sharedInstance
    logger.config(delegate: self, domain: AppDelegate.kDomainName, appName: AppDelegate.kAppName.replacingSpaces(with: ""))

    // give the Api access to our logger
    Log.sharedInstance.delegate = logger

    
    // Create the log window
    logWindow = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
      styleMask: [.titled, .resizable, .miniaturizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    
    logWindow!.isReleasedWhenClosed = false
    logWindow!.title = "Log Window"
    logWindow!.contentView = NSHostingView(rootView: LogView()
                                            .environmentObject(Logger.sharedInstance))
    
    // initialize Logger with the default log
    let defaultLogUrl = URL(fileURLWithPath: URL.appSupport.path + "/" + AppDelegate.kDomainName + "." + AppDelegate.kAppName + "/Logs/" + AppDelegate.kAppName + ".log")
    Logger.sharedInstance.loadLog(at: defaultLogUrl)
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
  
  /// Show / Hide the Log window
  /// - Parameter show:     show / hide
  ///
  func showLogWindow(_ show: Bool) {
    let frameName = "LogWindowFrame"
    
    if show {
      logWindow?.orderFront(nil)
      logWindow?.level = .floating
      logWindow?.setFrameUsingName(frameName)
      
    } else {
      logWindow?.saveFrame(usingName: frameName)
      logWindow?.orderOut(nil)
    }
  }

}

