//
//  AppExtensions.swift
//  xAPITester
//
//  Created by Douglas Adams on 8/15/15.
//  Copyright © 2018 Douglas Adams & Mario Illgen. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

// ----------------------------------------------------------------------------
// MARK: - EXTENSIONS

typealias NC = NotificationCenter

// ----------------------------------------------------------------------------
// MARK: - Definitions for SwiftyUserDefaults

extension DefaultsKeys {
  
  var clearAtConnect           : DefaultsKey<Bool>            { .init("clearAtConnect", defaultValue: false) }
  var clearAtDisconnect        : DefaultsKey<Bool>            { .init("clearAtDisconnect", defaultValue: false) }
  var clearOnSend              : DefaultsKey<Bool>            { .init("clearOnSend", defaultValue: false) }
  var connectAsGui             : DefaultsKey<Bool>            { .init("connectAsGui", defaultValue: false) }
  var connectToFirstRadio      : DefaultsKey<Bool>            { .init("connectToFirstRadio", defaultValue: false) }
  var clientId                 : DefaultsKey<String>          { .init("clientId", defaultValue: "") }
  var defaultConnection        : DefaultsKey<String>          { .init("defaultConnection", defaultValue: "local.1715-4055-6500-9722") }
  var enablePinging            : DefaultsKey<Bool>            { .init("enablePinging", defaultValue: false) }
  var messagesFilterText       : DefaultsKey<String>          { .init("messagesFilterText", defaultValue: "") }
  var messagesFilterBy         : DefaultsKey<String>          { .init("messagesFilterBy", defaultValue: "none") }
  var objectsFilterText        : DefaultsKey<String>          { .init("objectsFilterText", defaultValue: "") }
  var objectsFilterBy          : DefaultsKey<String>          { .init("objectsFilterBy", defaultValue: "none") }
  var showAllReplies           : DefaultsKey<Bool>            { .init("showAllReplies", defaultValue: false) }
  var showPings                : DefaultsKey<Bool>            { .init("showPings", defaultValue: false) }
  var showTimestamps           : DefaultsKey<Bool>            { .init("showTimestamps", defaultValue: false) }
  var smartLinkAuth0Email      : DefaultsKey<String>          { .init("smartLinkAuth0Email", defaultValue: "") }
  var smartLinkEnabled         : DefaultsKey<Bool>            { .init("smartLinkEnabled", defaultValue: true) }
  var smartLinkWasLoggedIn     : DefaultsKey<Bool>            { .init("smartLinkWasLoggedIn", defaultValue: false) }
  var useLowBw                 : DefaultsKey<Bool>            { .init("useLowBw", defaultValue: false) }
}

/// Struct to hold a Semantic Version number
///     with provision for a Build Number
///
public struct Version {
  var major     : Int = 1
  var minor     : Int = 0
  var patch     : Int = 0
  var build     : Int = 1

  public init(_ versionString: String = "1.0.0") {
    
    let components = versionString.components(separatedBy: ".")
    switch components.count {
    case 3:
      major = Int(components[0]) ?? 1
      minor = Int(components[1]) ?? 0
      patch = Int(components[2]) ?? 0
      build = 1
    case 4:
      major = Int(components[0]) ?? 1
      minor = Int(components[1]) ?? 0
      patch = Int(components[2]) ?? 0
      build = Int(components[3]) ?? 1
    default:
      major = 1
      minor = 0
      patch = 0
      build = 1
    }
  }
  
  public init() {
    // only useful for Apps & Frameworks (which have a Bundle), not Packages
    let versions = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let build   = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String
    self.init(versions + ".\(build)")
   }
  
  public var longString       : String  { "\(major).\(minor).\(patch) (\(build))" }
  public var string           : String  { "\(major).\(minor).\(patch)" }

  public var isV3             : Bool    { major >= 3 }
  public var isV2NewApi       : Bool    { major == 2 && minor >= 5 }
  public var isGreaterThanV22 : Bool    { major >= 2 && minor >= 2 }
  public var isV2             : Bool    { major == 2 && minor < 5 }
  public var isV1             : Bool    { major == 1 }
  
  public var isNewApi         : Bool    { isV3 || isV2NewApi }
  public var isOldApi         : Bool    { isV1 || isV2 }

  static func ==(lhs: Version, rhs: Version) -> Bool { lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch }
  
  static func <(lhs: Version, rhs: Version) -> Bool {
    
    switch (lhs, rhs) {
      
    case (let l, let r) where l == r: return false
    case (let l, let r) where l.major < r.major: return true
    case (let l, let r) where l.major == r.major && l.minor < r.minor: return true
    case (let l, let r) where l.major == r.major && l.minor == r.minor && l.patch < r.patch: return true
    default: return false
    }
  }
}

extension FileManager {
  
  /// Get / create the Application Support folder
  ///
  static var appFolder : URL {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask )
    let appFolderUrl = urls.first!.appendingPathComponent( Bundle.main.bundleIdentifier! )
    
    // does the folder exist?
    if !fileManager.fileExists( atPath: appFolderUrl.path ) {
      
      // NO, create it
      do {
        try fileManager.createDirectory( at: appFolderUrl, withIntermediateDirectories: false, attributes: nil)
      } catch let error as NSError {
        fatalError("Error creating App Support folder: \(error.localizedDescription)")
      }
    }
    return appFolderUrl
  }
}

extension URL {
  
  /// setup the Support folders
  ///
  static var appSupport : URL { return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first! }
  static var logs : URL { return createAsNeeded("net.k3tzr." + AppDelegate.kAppName + "/Logs") }
  static var macros : URL { return createAsNeeded("net.k3tzr." + AppDelegate.kAppName + "/Macros") }
  
  static func createAsNeeded(_ folder: String) -> URL {
    let fileManager = FileManager.default
    let folderUrl = appSupport.appendingPathComponent( folder )
    
    // does the folder exist?
    if fileManager.fileExists( atPath: folderUrl.path ) == false {
      
      // NO, create it
      do {
        try fileManager.createDirectory( at: folderUrl, withIntermediateDirectories: true, attributes: nil)
      } catch let error as NSError {
        fatalError("Error creating App Support folder: \(error.localizedDescription)")
      }
    }
    return folderUrl
  }
}

extension URL {
  
  /// Write an array of Strings to a URL
  ///
  /// - Parameters:
  ///   - textArray:                        an array of String
  ///   - addEndOfLine:                     whether to add an end of line to each String
  /// - Returns:                            an error message (if any)
  ///
  func writeArray(_ textArray: [String], addEndOfLine: Bool = true) -> String? {
    
    let eol = (addEndOfLine ? "\n" : "")
    
    // add a return to each line
    // build a string of all the lines
    let fileString = textArray
      .map { $0 + eol }
      .reduce("", +)
    
    do {
      // write the string to the url
      try fileString.write(to: self, atomically: true, encoding: String.Encoding.utf8)
      
    } catch let error as NSError {
      
      // an error occurred
      return "Error writing to file : \(error.localizedDescription)"
      
    } catch {
      
      // an error occurred
      return "Error writing Log"
    }
    return nil
  }
}

extension NSButton {
  
  /// Boolean equivalent of an NSButton state property
  ///
  var boolState : Bool {
    get { return self.state == NSControl.StateValue.on ? true : false }
    set { self.state = (newValue == true ? NSControl.StateValue.on : NSControl.StateValue.off) }
  }
}

extension NSMenuItem {
  /// Boolean equivalent of an NSMenuItem state property
  ///
  var boolState : Bool {
    get { return self.state == NSControl.StateValue.on ? true : false }
    set { self.state = (newValue == true ? NSControl.StateValue.on : NSControl.StateValue.off) }
  }
}

extension NSMenuItem {
  
  func item(title: String) -> NSMenuItem? {
    self.submenu?.items.first(where: {$0.title == title})
  }
}

public extension String {
  
  /// Check if a String is a valid IP4 address
  ///
  /// - Returns:          the result of the check as Bool
  ///
  func isValidIP4() -> Bool {
    
    // check for 4 values separated by period
    let parts = self.components(separatedBy: ".")
    
    // convert each value to an Int
    let nums = parts.compactMap { Int($0) }
    
    // must have 4 values containing 4 numbers & 0 <= number < 256
    return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256}.count == 4
  }
}

extension String {
  
  /// Pad a string to a fixed length
  /// - Parameters:
  ///   - len:            the desired length
  ///   - padCharacter:   the character to pad with
  /// - Returns:          a padded string
  ///
  func padTo(_ len: Int, with padCharacter: String = " ") -> String {
      String((self + "               ").prefix(15))
//    self.padding(toLength: len, withPad: padCharacter, startingAt: 0)
  }
}

// ----------------------------------------------------------------------------
// MARK: - TOP-LEVEL FUNCTIONS

/// Repeatedly perform a condition func until satisfied or a timeout
/// - Parameters:
///   - interval:           how offten to check the condition func (seconds)
///   - wait:               how long until timeout (seconds)
///   - condition:          a condition func ()->Bool
///   - completionHandler:  a completion handler (wasCancelled)->()
///
func checkLoop(interval: Int, wait: TimeInterval, condition: @escaping ()->Bool, completionHandler: @escaping (Bool)->()) {
  
  // create the timer
  let start = Date()
  let timer = DispatchSource.makeTimerSource()
  
  timer.schedule(deadline: DispatchTime.now(), repeating: .seconds(interval))
  timer.setEventHandler{
    // timeout after "wait" seconds
    if Date(timeIntervalSinceNow:0).timeIntervalSince(start) > wait {
      // time out
      timer.cancel()
      completionHandler(false)
    } else {
      // not time out, check condition
      if condition() {
        timer.cancel()
        completionHandler(true)
      }
    }
  }
  // start the timer
  timer.resume()
}

/// Display an Alert sheet for a limited time or until some condition is met (whichever comes first)
/// - Parameters:
///   - message:            the message to display
///   - window:             the window for the sheet
///   - interval:           how offten to check the condition func (seconds)
///   - wait:               how long until timeout (seconds)
///   - condition:          a condition func ()->Bool
///   - completionHandler:  a completion handler (wasCancelled)->()
///
func waitAlert(message: String, window: NSWindow, interval: Int, wait: TimeInterval, condition: @escaping ()->Bool, completionHandler: @escaping (Bool)->()) {

  // create the timer
  let start = Date()
  let timer = DispatchSource.makeTimerSource()
  let alert = NSAlert()

  timer.schedule(deadline: DispatchTime.now(), repeating: .seconds(interval))
  timer.setEventHandler{
   // timeout after "wait" seconds
    if Date(timeIntervalSinceNow:0).timeIntervalSince(start) > wait {
      // time out
      timer.cancel()
      completionHandler(false)
      DispatchQueue.main.async {
        window.endSheet(alert.window)
      }
    } else {
      // not time out, check condition
      if condition() {
        timer.cancel()
        completionHandler(true)
        DispatchQueue.main.async {
          window.endSheet(alert.window)
        }
      }
    }
  }
  alert.messageText = message
  alert.alertStyle = .informational
  alert.addButton(withTitle: "Cancel")
  alert.beginSheetModal(for: window, completionHandler: { (response) in
    if response == NSApplication.ModalResponse.alertFirstButtonReturn { timer.cancel() ; completionHandler(false) }
  })
  // start the timer
  timer.resume()
}
