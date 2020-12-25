//
//  AppDelegate.swift
//  xApiMac
//
//  Created by Douglas Adams on 8/9/20.
//

import Cocoa
import SwiftUI
import xLib6000
import xClientMac

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject, LoggerDelegate {
    
    // ----------------------------------------------------------------------------
    // MARK: - Static properties
    
    static let kAppName       = "xApiMac"
    static let kDomainName    = "net.k3tzr"  
    
    // ----------------------------------------------------------------------------
    // MARK: - Published properties
    
    var showLogWindow = false { didSet{ updateLogWindow(showLogWindow) }}
    
    // ----------------------------------------------------------------------------
    // MARK: - Internal properties
    
    var window          : NSWindow!
    var logWindow       : NSWindow?
    lazy var tester     = Tester()
    
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
                                            .environmentObject(tester))
        window.makeKeyAndOrderFront(nil)
        
        //    let logger = Logger.sharedInstance
        //    logger.config(delegate: self, domain: AppDelegate.kDomainName, appName: AppDelegate.kAppName.replacingSpaces(with: ""))
        //
        //    // give the Api access to our logger
        //    Log.sharedInstance.delegate = logger
        
        // Create the log window
        logWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.titled, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        logWindow!.isReleasedWhenClosed = false
        logWindow!.title = "Log Window"
        logWindow!.contentView = NSHostingView(rootView: LoggerView()
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
    private func updateLogWindow(_ show: Bool) {
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
    
    /// Refresh the Logger view when a font change occurs
    ///
    private func updateLoggerFont() {
        Logger.sharedInstance.fontSize = tester.fontSize
        Logger.sharedInstance.refreshLog()
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Menu IBAction methods
    
    @IBAction func logViewer(_ sender: Any) {
        showLogWindow.toggle()
    }
    
    @IBAction func larger(_ sender: Any) {
        tester.fontSize(larger: true)
        updateLoggerFont()
    }
    
    @IBAction func smaller(_ sender: Any) {
        tester.fontSize(larger: false)
        updateLoggerFont()
    }
}

