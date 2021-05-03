//
//  xApiMac.swift
//  xApiMac
//
//  Created by Douglas Adams on 3/20/21.
//

import AppKit
import SwiftUI
import xClient6001

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

    var tester = Tester()

    var body: some Scene {

        WindowGroup {
            ContentView(tester: tester, radioManager: RadioManager(delegate: tester as RadioManagerDelegate), selectedTab: 1)
                .navigationTitle("xApiMac " + Version().longString)
        }
        .commands {
            // remove the "File->New" menu item
            CommandGroup(replacing: .newItem) {
                EmptyView()
            }
        }
    }
}
