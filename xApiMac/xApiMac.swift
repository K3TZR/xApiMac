//
//  xApiMac.swift
//  xApiMac
//
//  Created by Douglas Adams on 3/20/21.
//

import AppKit
import SwiftUI
import xClient

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // disable tab view
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // close when last window closed
        true
    }
}

@main
struct XApiMac: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

//    @StateObject var windowCollection = WindowCollection()

    @StateObject var logManager = LogManager.sharedInstance
    var tester: Tester
    var radioManager: RadioManager

    init() {
        tester = Tester()
        radioManager = RadioManager(delegate: tester as RadioManagerDelegate)
    }

    var body: some Scene {

        WindowGroup {
            ContentView(tester: tester, radioManager: radioManager)
        }

        WindowGroup {
            LogView()
                .environmentObject(radioManager)
                .environmentObject(logManager)
        }
        .handlesExternalEvents(matching: Set(["LoggerView"]))

        .commands {
            // remove the "File->New" menu item
            CommandGroup(replacing: .newItem) {
                EmptyView()
            }
        }
    }
}
