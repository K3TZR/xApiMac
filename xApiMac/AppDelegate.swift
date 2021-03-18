//
//  AppDelegate.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/9/20.
//

import Cocoa
import SwiftUI
import xLib6000
import xClient

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject, LoggerDelegate {
    // ----------------------------------------------------------------------------
    // MARK: - Static properties
    
    static let kAppName = "xApiMac"
    static let kDomainName = "net.k3tzr"
    
    // ----------------------------------------------------------------------------
    // MARK: - Internal properties
    
    var window: NSWindow!
    var logWindow: NSWindow?
    var tester = Tester()
    var radioManager: RadioManager!
    
    // ----------------------------------------------------------------------------
    // MARK: - Internal methods
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // instantiate the RadioManager and give it access to the app (i.e. Tester)
        radioManager = RadioManager(delegate: tester as RadioManagerDelegate)

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(tester: tester, radioManager: radioManager)

        // Create the main window
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
                                            .environmentObject(tester))
        window.makeKeyAndOrderFront(nil)
        
        // Create the log window
        logWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.titled, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        logWindow!.isReleasedWhenClosed = false
        logWindow!.title = "Log Window"
        logWindow!.contentView = NSHostingView(rootView: LoggerView()
                                                .environmentObject(LogManager.sharedInstance))
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    
    /// Show / Hide the Log window
    /// - Parameter show:     show /
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
        tester.showLogWindow = show
    }
    
    /// Refresh the Logger view when a font change occurs
    ///
    private func updateLoggerFont() {
        LogManager.sharedInstance.fontSize = tester.fontSize
        LogManager.sharedInstance.refreshLog()
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Action methods
    
    @IBAction func larger(_ sender: Any) {
        tester.fontSize(larger: true)
        updateLoggerFont()
    }
    
    @IBAction func smaller(_ sender: Any) {
        tester.fontSize(larger: false)
        updateLoggerFont()
    }
}
