//
//  Tester.swift
//  xApi6000
//
//  Created by Douglas Adams on 8/9/20.
//

import Cocoa
import xLib6000
import SwiftyUserDefaults
import SwiftUI

typealias ObjectTuple = (color: NSColor, text: String)

struct Message : Identifiable {
  var id = 0
  var text  = ""
}

struct Object : Identifiable {
  var id = 0
  var line : ObjectTuple = (.black, "")
}

enum FilterType: String {
  case messages
  case objects
}

enum FilterObjects : String, CaseIterable {
  case none
  case prefix
  case includes
  case excludes
}

enum FilterMessages : String, CaseIterable {
  case none
  case prefix
  case includes
  case excludes
  case command
  case status
  case reply
  case S0
}

struct AlertParams {
  var style : NSAlert.Style = .informational
  var msg = ""
  var text = ""
  var button1 = ""
  var button2 = ""
  var button3 = ""
  var button4 = ""
  var handler : (NSApplication.ModalResponse) -> Void
}

// ----------------------------------------------------------------------------
// MARK: - Class definition
// ----------------------------------------------------------------------------

final class Tester : ApiDelegate, ObservableObject, RadioManagerDelegate {
    
  static let kAppName     = "xApi6000"
  static let kDomainName  = "net.k3tzr"
  
  // ----------------------------------------------------------------------------
  // MARK: - Published properties
  
  @Published var radioManager         : RadioManager!
  
  // Defaults
  @Published var clearAtConnect       = false   { didSet {Defaults.clearAtConnect = clearAtConnect} }
  @Published var clearAtDisconnect    = false   { didSet {Defaults.clearAtDisconnect = clearAtDisconnect} }
  @Published var clearOnSend          = false   { didSet {Defaults.clearOnSend = clearOnSend} }
  @Published var clientId             = ""      { didSet {Defaults.clientId = clientId} }
  @Published var cmdToSend            = ""
  @Published var connectAsGui         = false   { didSet {Defaults.connectAsGui = connectAsGui} }
  @Published var connectToFirstRadio  = false   { didSet {Defaults.connectToFirstRadio = connectToFirstRadio} }
  @Published var defaultConnection    = ""      { didSet {Defaults.defaultConnection = defaultConnection} }
  @Published var enablePinging        = false   { didSet {Defaults.enablePinging = enablePinging} }
  @Published var isConnected          = false
  @Published var showAllReplies       = false   { didSet {Defaults.showAllReplies = showAllReplies} }
  @Published var showPings            = false   { didSet {Defaults.showPings = showPings} }
  @Published var showTimestamps       = false   { didSet {Defaults.showTimestamps = showTimestamps} }
  @Published var smartLinkAuth0Email  = ""      { didSet {Defaults.smartLinkAuth0Email = smartLinkAuth0Email} }
  @Published var smartLinkEnabled     = false   { didSet {Defaults.smartLinkEnabled = smartLinkEnabled} }
  @Published var smartLinkWasLoggedIn = false   { didSet {Defaults.smartLinkWasLoggedIn = smartLinkWasLoggedIn} }
  @Published var startConnection      = false   { didSet { startStopTester() }}
  @Published var stationName          = ""

  @Published var filteredMessages     = [Message]()
  @Published var messagesFilterBy     : FilterMessages  = .none { didSet {filterCollection(of: .messages) ; Defaults.messagesFilterBy = messagesFilterBy.rawValue }}
  @Published var messagesFilterText   = ""                      { didSet {filterCollection(of: .messages) ; Defaults.messagesFilterText = messagesFilterText }}
  @Published var messagesScrollTo     : CGPoint? = nil
 
  @Published var filteredObjects      = [Object]()
  @Published var objectsFilterBy      : FilterObjects   = .none { didSet {filterCollection(of: .objects) ; Defaults.objectsFilterBy = objectsFilterBy.rawValue }}
  @Published var objectsFilterText    = ""                      { didSet {filterCollection(of: .objects) ; Defaults.objectsFilterText = objectsFilterText}}
  @Published var objectsScrollTo      : CGPoint? = nil

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _api                  = Api.sharedInstance
  private var _commandsIndex        = 0
  private var _commandHistory       = [String]()
  private let _log                  = Logger.sharedInstance.logMessage
  private var _messageNumber        = 0
  private var _objectNumber         = 0
  private let _objectQ              = DispatchQueue(label: AppDelegate.kAppName + ".objectQ", attributes: [.concurrent])
  private var _packets              : [DiscoveryPacket] { Discovery.sharedInstance.discoveryPackets }
  private var _previousCommand      = ""
  private var _startTimestamp       : Date?
  
  private let _kAppNameTrimmed      = kAppName.replacingSpaces(with: "")
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties with concurrency protection
  
  private var messages: [Message] {
    get { return _objectQ.sync { _messages } }
    set { _objectQ.sync(flags: .barrier) { _messages = newValue } } }
  
  private var objects: [Object] {
    get { return _objectQ.sync { _objects } }
    set { _objectQ.sync(flags: .barrier) { _objects = newValue } } }
  
  private var replyHandlers: [SequenceNumber: ReplyTuple] {
    get { return _objectQ.sync { _replyHandlers } }
    set { _objectQ.sync(flags: .barrier) { _replyHandlers = newValue } } }
  
  // Backing store, do not use
  private var _messages       = [Message]()
  private var _objects        = [Object]()
  private var _replyHandlers  = [SequenceNumber: ReplyTuple]()

  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  init() {
    // restore Defaults
    clearAtConnect        = Defaults.clearAtConnect
    clearAtDisconnect     = Defaults.clearAtDisconnect
    clearOnSend           = Defaults.clearOnSend
    clientId              = Defaults.clientId
    connectAsGui          = Defaults.connectAsGui
    connectToFirstRadio   = Defaults.connectToFirstRadio
    defaultConnection     = Defaults.defaultConnection
    enablePinging         = Defaults.enablePinging
    showAllReplies        = Defaults.showAllReplies
    showPings             = Defaults.showPings
    showTimestamps        = Defaults.showTimestamps
    smartLinkAuth0Email   = Defaults.smartLinkAuth0Email
    smartLinkEnabled      = Defaults.smartLinkEnabled
    smartLinkWasLoggedIn  = Defaults.smartLinkWasLoggedIn
    
    messagesFilterBy      = FilterMessages(rawValue: Defaults.messagesFilterBy) ?? .none
    messagesFilterText    = Defaults.messagesFilterText
    objectsFilterBy       = FilterObjects(rawValue: Defaults.objectsFilterBy) ?? .none
    objectsFilterText     = Defaults.objectsFilterText
    
    // is there a saved Client ID?
    if clientId == "" {
      // NO, assign one
      clientId = UUID().uuidString
      Defaults.clientId = clientId
      _log("Tester: ClientId created - \(clientId)", .debug,  #function, #file, #line)
    }
    // create a Radio Manager
    radioManager = RadioManager(delegate: self, domain: "net.k3tzr", appName: Tester.kAppName)
    
    // receive delegate actions from the Api
    _api.testerDelegate = self
  }
  
  // ----------------------------------------------------------------------------
  // MARK: -  Internal methods (Tester related)
  
  /// Start / Stop the Tester
  ///
  func startStopTester() {
    if isConnected == false {
      startTester()
    } else {
      stopTester()
    }
  }
  
  /// Start the Tester
  ///
  func startTester() {
    // Start connection
    //    Order of attempts:
    //      1. default (if defaultConnection non-blank)
    //      2. first radio found (if connectToFirstRadio true)
    //      3. otherwise, show picker
    //
    _startTimestamp = Date()
    if clearAtConnect { clear() }
    
    checkSmartLinkStatus()
    
    if defaultConnection != "" {
      // connect to default
      radioManager.connect(to: defaultConnection)
    } else if connectToFirstRadio {
      // connect to first
      radioManager.connect()
    } else {
      // use the Picker
      radioManager.connectUsingPicker()
    }
  }
  
  /// Stop the Tester
  ///
  func stopTester() {
    // Stop connection
    DispatchQueue.main.async{ [self] in isConnected = false }
    if clearAtDisconnect { clear() }
    radioManager.disconnect()
  }
  
  /// Clear the object and messages areas
  ///
  func clear() {
    DispatchQueue.main.async {  [self] in
      _messageNumber = 0
      messages.removeAll()
      filterCollection(of: .messages)
      
      _objectNumber = 0
      objects.removeAll()
      filterCollection(of: .objects)
    }
  }
  
  /// Send a command to the Radio
  ///
  func send() {
    guard cmdToSend != "" else { return }
    
    // send the command to the Radio via TCP
    let _ = _api.radio!.sendCommand( cmdToSend )
    
    if cmdToSend != _previousCommand { _commandHistory.append(cmdToSend) }
    
    _previousCommand = cmdToSend
    _commandsIndex = _commandHistory.count - 1
    
    // optionally clear the Command field
    if clearOnSend { cmdToSend = "" }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Internal methods (SmartLink related)
  
  /// Initiate a login to SmartLink
  ///
  func smartLinkLogin() {
    if radioManager.smartLinkIsLoggedIn {
      smartLinkLogout()
    } else {
      _log("Tester: SmartLink Login initiated", .debug,  #function, #file, #line)
      radioManager.smartLinkLogin(with: smartLinkAuth0Email)
    }
  }
  
  /// Initiate a logout from SmartLink
  ///
  func smartLinkLogout() {
    _log("Tester: SmartLink Logout initiated", .debug,  #function, #file, #line)
    radioManager.smartLinkLogout()
  }
  
  // RefreshToken callbacks
  //    NOTE: The RefreshToken can be stored in any secure way, using Keychain
  //    as done here is one possibility

  /// Get a stored refresh token
  /// - Parameters:
  ///   - service:    a service name
  ///   - account:    an account name
  /// - Returns:      a refreshToken (if any)
  ///
  func refreshTokenGet(service: String, account: String) -> String? {
    return MyKeychain.get(service, account: account)
  }
  
  /// Set a stored refresh token
  /// - Parameters:
  ///   - service:        a service name
  ///   - account:        an account name
  ///   - refreshToken:   the token to be stored
  /// - Returns:      a refreshToken (if any)
  func refreshTokenSet(service: String, account: String, refreshToken: String) {
    MyKeychain.set(service, account: account, data: refreshToken)
  }
  
  /// Delete a stored refresh token
  /// - Parameters:
  ///   - service:    a service name
  ///   - account:    an account name
  /// - Returns:      a refreshToken (if any)
  ///
  func refreshTokenDelete(service: String, account: String) {
    MyKeychain.delete(service, account: account)
  }
  
  /// Receives the results of the SmartLInk Test
  /// - Parameters:
  ///   - status:   success / failure
  ///   - msg:      a string describing the result
  ///
  func smartLinkTestResults(status: Bool, msg: String) {
    // if failed, show the user
    if status == false {
      var alertData = AlertParams(handler: { _ in })
      alertData.style = .critical
      alertData.msg = "SmartLink Test failed"
      alertData.text = msg
      displayAlert(alertData)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: -  Private methods (Messages-related)
  
  /// Add an entry to the messages collection
  /// - Parameter text:       the text of the entry
  ///
  private func appendMessage(_ text: String) {
    DispatchQueue.main.async { [self] in
      
      // guard that a session has been started
      guard let startTimestamp = self.self._startTimestamp else { return }
      
      // add the Timestamp to the Text
      let timeInterval = Date().timeIntervalSince(startTimestamp)
      let stampedText = String( format: "%8.3f", timeInterval) + " " + text
      
      self._messageNumber += 1
      self.messages.append( Message(id: self._messageNumber, text: stampedText))
      
      self.filterCollection(of: .messages)
    }
  }
  
  /// Parse a Reply message. format: <sequenceNumber>|<hexResponse>|<message>[|<debugOutput>]
  ///
  /// - parameter commandSuffix:    a Command Suffix
  ///
  private func parseReplyMessage(_ commandSuffix: String) {
    // separate it into its components
    let components = commandSuffix.components(separatedBy: "|")
    
    // ignore incorrectly formatted replies
    guard components.count >= 2 else { appendMessage("ERROR: R\(commandSuffix)") ; return }
    
    if showAllReplies || components[1] != "0" || (components.count >= 3 && components[2] != "") {
      appendMessage("R\(commandSuffix)")
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: -  Private methods (Objects-related)
  
  /// Add an entry to the messages collection
  /// - Parameters:
  ///   - color:        an NSColor for the text
  ///   - text:         the text of the entry
  ///
  private func appendObject(_ color: NSColor, _ text: String) {
    objects.append( Object(id: _objectNumber, line: (color, text)) )
    _objectNumber += 1
  }

  /// Redraw the Objects
  ///
  private func refreshObjects() {
    
    DispatchQueue.main.async { [self] in
      populateObjects()
      self.filterCollection(of: .objects)
    }
  }

  /// Clear & recreate the Objects array
  ///
  private func populateObjects() {
    _objects.removeAll()
    _objectNumber = 0
    
    var activeHandle : Handle = 0
    
    // Radio
    if let radio = Api.sharedInstance.radio {
      self.objects.removeAll()
      var color = NSColor.systemGreen
      
      self.appendObject(color, "Radio          name = \(radio.nickname)  model = \(radio.packet.model)  ip = \(radio.packet.publicIp)" +
                          "  atu = \(Api.sharedInstance.radio!.atuPresent ? "Yes" : "No")  gps = \(Api.sharedInstance.radio!.gpsPresent ? "Yes" : "No")" +
                          "  scu's = \(Api.sharedInstance.radio!.numberOfScus)")
      
      self.appendObject(NSColor.systemBlue, "-------------------------------------------------------------------------------------------------------------------------------------------------------------------")
      
      // what verion is the Radio?
      if radio.version.isNewApi {
        

        // newApi
        for packet in _packets where packet == radioManager.activePacket {
          for guiClient in packet.guiClients {
            
            if  radioManager.stationSelection == 0 || (radioManager.stationSelection > 0 && radioManager.stations[radioManager.stationSelection - 1].station == guiClient.station) {
              activeHandle = guiClient.handle
              
              color = NSColor.systemRed
              if connectAsGui == false && guiClient.clientId != nil && guiClient.clientId == radio.boundClientId { color = NSColor.systemPurple }
              
              self.appendObject(color, "Gui Client     station = \(guiClient.station.padTo(15))  handle = \(guiClient.handle.hex)  id = \(guiClient.clientId ?? "unknown")  localPtt = \(guiClient.isLocalPtt ? "Yes" : "No ")  available = \(radio.packet.status.lowercased() == "available" ? "Yes" : "No ")  program = \(guiClient.program)")
              
              self.addSubsidiaryObjects(activeHandle, radio, NSColor.textColor)
              self.appendObject(NSColor.systemBlue, "-------------------------------------------------------------------------------------------------------------------------------------------------------------------")
            }
          }
        }
        
      } else {
        // oldApi
        self.addSubsidiaryObjects(activeHandle, radio, color)
      }
      color = NSColor.systemGray.withAlphaComponent(0.8)

      // OpusAudioStream
      for (_, stream) in radio.opusAudioStreams {
        self.appendObject(color, "Opus           id = \(stream.id.hex)  rx = \(stream.rxEnabled)  rx stopped = \(stream.rxStopped)  tx = \(stream.txEnabled)  ip = \(stream.ip)  port = \(stream.port)")
      }
      // AudioStream without a Slice
      for (_, stream) in radio.audioStreams where stream.slice == nil {
        self.appendObject(color, "Audio          id = \(stream.id.hex)  ip = \(stream.ip)  port = \(stream.port)  slice = -not assigned-")
      }
      // Tnfs
      for (_, tnf) in radio.tnfs {
        self.appendObject(color, "Tnf            id = \(tnf.id)  frequency = \(tnf.frequency)  width = \(tnf.width)  depth = \(tnf.depth)  permanent = \(tnf.permanent)")
      }
      // Amplifiers
      for (_, amplifier) in radio.amplifiers {
        self.appendObject(color, "Amplifier      id = \(amplifier.id.hex)")
      }
      // Memories
      for (_, memory) in radio.memories {
        self.appendObject(color, "Memory         id = \(memory.id)")
      }
      // USB Cables
      for (_, usbCable) in radio.usbCables {
        self.appendObject(color, "UsbCable       id = \(usbCable.id)")
      }
      // Xvtrs
      for (_, xvtr) in radio.xvtrs {
        self.appendObject(color, "Xvtr           id = \(xvtr.id)  rf frequency = \(xvtr.rfFrequency.hzToMhz)  if frequency = \(xvtr.ifFrequency.hzToMhz)  valid = \(xvtr.isValid.asTrueFalse)")
      }
      // other Meters (non "slc")
      let sortedMeters = radio.meters.sorted(by: {
        ( $0.value.source.prefix(3), Int($0.value.group.suffix(3), radix: 10)!, $0.value.id ) <
          ( $1.value.source.prefix(3), Int($1.value.group.suffix(3), radix: 10)!, $1.value.id )
      })
      for (_, meter) in sortedMeters where !meter.source.hasPrefix("slc") {
        self.appendObject(color, "Meter          source = \(meter.source.prefix(3))  group = \(("00" + meter.group).suffix(3))  id = \(String(format: "%03d", meter.id))  name = \(meter.name.padTo(12))  units = \(meter.units.padTo(5))  low = \(String(format: "% 7.2f", meter.low))  high = \(String(format: "% 7.2f", meter.high))  fps = \(String(format: "% 3d", meter.fps))  desc = \(meter.desc)  ")
      }
    }
  }
  
  /// Add subsidiary objects to the Objects array
  /// - Parameters:
  ///   - activeHandle:       a connection handle
  ///   - radio:              the active radio
  ///   - color:              an NSColor for the text
  ///
  private func addSubsidiaryObjects(_ activeHandle: Handle, _ radio: Radio, _ color: NSColor) {
    
    // MicAudioStream
    for (_, stream) in radio.micAudioStreams where stream.clientHandle == activeHandle {
      self.appendObject(color, "MicAudio       id = \(stream.id.hex)  handle = \(stream.clientHandle.hex)  ip = \(stream.ip)  port = \(stream.port)")
    }
    // IqStream without a Panadapter
    for (_, stream) in radio.iqStreams where stream.clientHandle == activeHandle && stream.pan == 0 {
      self.appendObject(color, "Iq             id = \(stream.id.hex)  channel = \(stream.daxIqChannel)  rate = \(stream.rate)  ip = \(stream.ip)  panadapter = -not assigned-")
    }
    // TxAudioStream
    for (_, stream) in radio.txAudioStreams where stream.clientHandle == activeHandle {
      self.appendObject(color, "TxAudio        id = \(stream.id.hex)  handle = \(stream.clientHandle.hex)  transmit = \(stream.transmit)  ip = \(stream.ip)  port = \(stream.port)")
    }
    // DaxRxAudioStream without a Slice
    for (_, stream) in radio.daxRxAudioStreams where stream.clientHandle == activeHandle && stream.slice == nil {
      self.appendObject(color, "DaxRxAudio     id = \(stream.id.hex)  handle = \(stream.clientHandle.hex)  channel = \(stream.daxChannel)  ip = \(stream.ip)  slice = -not assigned-")
    }
    // DaxTxAudioStream
    for (_, stream) in radio.daxTxAudioStreams where stream.clientHandle == activeHandle {
      self.appendObject(color, "DaxTxAudio     id = \(stream.id.hex)  handle = \(stream.clientHandle.hex)  isTransmit = \(stream.isTransmitChannel)")
    }
    // DaxIqStream without a Panadapter
    for (_, stream) in radio.daxIqStreams where stream.clientHandle == activeHandle && stream.pan == 0 {
      self.appendObject(color, "DaxIq          id = \(stream.id.hex)  handle = \(stream.clientHandle.hex)  channel = \(stream.channel)  rate = \(stream.rate)  ip = \(stream.ip)  panadapter = -not assigned-")
    }
    // RemoteRxAudioStream
    for (_, stream) in radio.remoteRxAudioStreams where stream.clientHandle == activeHandle {
      self.appendObject(color, "RemoteRxAudio  id = \(stream.id.hex)  handle = \(stream.clientHandle.hex)  compression = \(stream.compression)")
    }
    // RemoteTxAudioStream
    for (_, stream) in radio.remoteTxAudioStreams where stream.clientHandle == activeHandle {
      self.appendObject(color, "RemoteTxAudio  id = \(stream.id.hex)  handle = \(stream.clientHandle.hex)  compression = \(stream.compression)  ip = \(stream.ip)")
    }
    // DaxMicAudioStream
    for (_, stream) in radio.daxMicAudioStreams where stream.clientHandle == activeHandle {
      self.appendObject(color, "DaxMicAudio    id = \(stream.id.hex)  handle = \(stream.clientHandle.hex)  ip = \(stream.ip)")
    }
    
    // Panadapters & its accompanying objects
    for (_, panadapter) in radio.panadapters {
      if panadapter.clientHandle != activeHandle { continue }
      
      if radio.version.isNewApi {
        self.appendObject(color, "Panadapter     handle = \(panadapter.clientHandle.hex)  id = \(panadapter.id.hex)  center = \(panadapter.center.hzToMhz)  bandwidth = \(panadapter.bandwidth.hzToMhz)")
      } else {
        self.appendObject(color, "Panadapter     id = \(panadapter.id.hex)  center = \(panadapter.center.hzToMhz)  bandwidth = \(panadapter.bandwidth.hzToMhz)")
      }
      // Waterfall
      for (_, waterfall) in radio.waterfalls where panadapter.id == waterfall.panadapterId {
        self.appendObject(color, "      Waterfall   id = \(waterfall.id.hex)  autoBlackEnabled = \(waterfall.autoBlackEnabled),  colorGain = \(waterfall.colorGain),  blackLevel = \(waterfall.blackLevel),  duration = \(waterfall.lineDuration)")
      }
      // IqStream
      for (_, iqStream) in radio.iqStreams where panadapter.id == iqStream.pan {
        self.appendObject(color, "      Iq          id = \(iqStream.id.hex)")
      }
      // DaxIqStream
      for (_, daxIqStream) in radio.daxIqStreams where panadapter.id == daxIqStream.pan {
        self.appendObject(color, "      DaxIq       id = \(daxIqStream.id.hex)")
      }
      // Slice(s) & their accompanying objects
      for (_, slice) in radio.slices where panadapter.id == slice.panadapterId {
        self.appendObject(color, "      Slice       id = \(slice.id)  frequency = \(slice.frequency.hzToMhz)  mode = \(slice.mode.padTo(4))  filterLow = \(String(format: "% 5d", slice.filterLow))  filterHigh = \(String(format: "% 5d", slice.filterHigh))  active = \(slice.active)  locked = \(slice.locked)")
        
        // AudioStream
        for (_, stream) in radio.audioStreams where stream.slice?.id == slice.id {
          self.appendObject(color, "          Audio       id = \(stream.id.hex)  ip = \(stream.ip)  port = \(stream.port)")
        }
        // DaxRxAudioStream
        for (_, stream) in radio.daxRxAudioStreams where stream.slice?.id == slice.id {
          self.appendObject(color, "          DaxAudio    id = \(stream.id.hex)  channel = \(stream.daxChannel)  ip = \(stream.ip)")
        }
        // Meters
        for (_, meter) in radio.meters.sorted(by: { $0.value.id < $1.value.id }) {
          if meter.source == "slc" && meter.group == String(slice.id) {
            self.appendObject(color, "          Meter id = \(meter.id)  name = \(meter.name.padTo(12))  units = \(meter.units.padTo(5))  low = \(String(format: "% 7.2f", meter.low))  high = \(String(format: "% 7.2f", meter.high))  fps = \(String(format: "% 3d", meter.fps))  desc = \(meter.desc)  ")
          }
        }
      }
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Misc methods
  
  /// Login to the SmartLink server (if appropriate)
  ///
  private func checkSmartLinkStatus() {
    if smartLinkEnabled && radioManager.smartLinkIsLoggedIn == false {
      // SmartLink enabled but not logged in, attempt to make a SmartLink server login
      radioManager.smartLinkLogin(with: smartLinkAuth0Email)
    
    } else if smartLinkEnabled == false && radioManager.smartLinkIsLoggedIn {
      // SmartLink disabled and logged in, SmartLink server logout
      radioManager.smartLinkDisable()
    }
  }

  /// Filter the message and object collections
  ///
  /// - Parameter type:     object type
  ///
  private func filterCollection(of type: FilterType) {
    if type == .messages {
      switch messagesFilterBy {
      
      case .none:       filteredMessages = messages
      case .prefix:     filteredMessages =  messages.filter { $0.text.contains("|" + messagesFilterText) }
      case .includes:   filteredMessages =  messages.filter { $0.text.contains(messagesFilterText) }
      case .excludes:   filteredMessages =  messages.filter { !$0.text.contains(messagesFilterText) }
      case .command:    filteredMessages =  messages.filter { $0.text.dropFirst(9).prefix(1) == "C" }
      case .S0:         filteredMessages =  messages.filter { $0.text.dropFirst(9).prefix(2) == "S0" }
      case .status:     filteredMessages =  messages.filter { $0.text.dropFirst(9).prefix(1) == "S" && $0.text.dropFirst(10).prefix(1) != "0"}
      case .reply:      filteredMessages =  messages.filter { $0.text.dropFirst(9).prefix(1) == "R" }

      }
      //      let lastLine = filteredMessages.count
      //      messagesScrollTo = CGPoint(x: 0, y: (lastLine * 18) + 18)
    }
    else {
      switch objectsFilterBy {
      
      case .none:       filteredObjects = objects
      case .prefix:     filteredObjects = objects.filter { $0.line.text.contains("|" + objectsFilterText) }
      case .includes:   filteredObjects = objects.filter { $0.line.text.contains(objectsFilterText) }
      case .excludes:   filteredObjects = objects.filter { !$0.line.text.contains(objectsFilterText) }
      }
      //      objectsScrollTo = CGPoint(x: 0, y: 0)
    }
  }
  
  /// DIsplay an alert using the supplied parameters
  /// - Parameter data:     a struct containing the needed data
  ///
  private func displayAlert(_ data: AlertParams) {
    DispatchQueue.main.async {
      let alert = NSAlert()
      alert.alertStyle = data.style
      alert.messageText = data.msg
      alert.informativeText = data.text
      if data.button1 != "" { alert.addButton(withTitle: data.button1) }
      if data.button2 != "" { alert.addButton(withTitle: data.button2) }
      if data.button3 != "" { alert.addButton(withTitle: data.button3) }
      if data.button4 != "" { alert.addButton(withTitle: data.button4) }
      
      alert.beginSheetModal(for: NSApplication.shared.mainWindow!, completionHandler: data.handler )}
  }

  // ----------------------------------------------------------------------------
  // MARK: - RadioManagerDelegate

//  let kAppNameTrimmed: String = kAppName.replacingSpaces(with: "")
  
  /// Called asynchronously by RadioManager to indicate success / failure for a SmartLink server connection attempt
  /// - Parameter state:      true if connected
  ///
  func smartLinkLoginState(_ state: Bool) {
    // remember the current state
    smartLinkWasLoggedIn = state
    _log("Tester: SmartLink \(state ? "Login" : "Logout")", .debug,  #function, #file, #line)
  }
  
  /// Called asynchronously by RadioManager to indicate success / failure for a Radio connection attempt
  /// - Parameters:
  ///   - state:          true if connected
  ///   - connection:     the connection string attempted
  ///
  func connectionState(_ state: Bool, _ connection: String, _ msg: String = "") {
    // was the connection successful?
    if state {
      // YES
      DispatchQueue.main.async { [self] in isConnected = true }
      _log("Tester: Connection to \(connection) established", .debug,  #function, #file, #line)

    } else {
      // NO
      _log("Tester: Connection failed to \(connection), \(msg)", .debug,  #function, #file, #line)
      DispatchQueue.main.async { [self] in
        isConnected = false
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = msg
        alert.informativeText = "Connection string = \(connection)"
        
        // tell the user
        alert.beginSheetModal(for: NSApplication.shared.mainWindow!, completionHandler: { _ in
        })
      }
    }
  }
  
  /// Called by RadioManager when a disconnection occurs
  /// - Parameter msg:      explanation
  ///
  func disconnectionState(_ text: String) {
    
    DispatchQueue.main.async { [self] in isConnected = false }
    
    if text != RadioManager.kUserInitiated {
      var params = AlertParams(handler: { _ in })
      params.style = .warning
      params.msg = "Radio was disconnected"
      params.text = text
      displayAlert(params)
    }
  }
  
  /// Called by RadioManager to request a decision during a connection attempt
  /// - Parameters:
  ///   - status:   the status of the targeted Radio
  ///   - clients:  an array of the Radio's GuiClients
  ///   - handler:  a callback closure
  ///
  func openStatus(_ status: OpenCloseStatus, _ clients: [GuiClient], handler: @escaping (NSApplication.ModalResponse) -> Void ) {
    var params = AlertParams(handler: handler)

    switch status {
    
    case (false, .inUse, 1):
      params.msg = "Radio is connected to another Client"
      params.text = "Close the other Client?"
      params.button1 = "Close this client"
      params.button2 = "Cancel"
    
    case (false, .available, _):
      params.handler( NSApplication.ModalResponse.OK )
      return

    case (true, .available, 0):
      params.handler( NSApplication.ModalResponse.OK )
      return
    
    case (true, .available, 1):
      params.msg = "Radio is connected to Station: \(clients[0].station)"
      params.text = "Close the Station . . Or . . Connect using Multiflex"
      params.button1 = "Close \(clients[0].station)"
      params.button2 = "Multiflex Connect"
    
    case (true, .inUse, 2):
      params.msg = "Radio is connected to multiple Stations"
      params.text = "Close one of the Stations"
      params.button1 = "Close \(clients[0].station)"
      params.button2 = "Close \(clients[1].station)"
      params.button3 = "Remote Control"
      params.button4 = "Cancel"

    default:
      return
    }
    // use an Alert to obtain a decision
    displayAlert(params)
  }
  
  /// Called by RadioManager to request a decision during a connection attempt
  /// - Parameters:
  ///   - status:   the status of the targeted Radio
  ///   - clients:  an array of the Radio's GuiClients
  ///   - handler:  a callback closure
  ///
  func closeStatus(_ status: OpenCloseStatus, _ clients: [GuiClient], handler: @escaping (NSApplication.ModalResponse) -> Void ) {
    var params = AlertParams(handler: handler)

    switch status {
    case (true, .inUse, 1):
      params.msg = "Radio is connected to one Station"
      params.text = "Close the Station . . Or . . Disconnect " + _kAppNameTrimmed
      params.button1 = "Close \(clients[0].station)"
      params.button2 = "Disconnect " + _kAppNameTrimmed
      params.button3 = "Cancel"

    case (true, .inUse, 2):
      params.msg = "Radio is connected to multiple Stations"
      params.text = "Close a Station . . Or . . Disconnect "  + _kAppNameTrimmed
      params.button1 = (clients[0].station == _kAppNameTrimmed ? "---" : "Close \(clients[0].station)")
      params.button2 = (clients[1].station == _kAppNameTrimmed ? "---" : "Close \(clients[1].station)")
      params.button3 = "Disconnect " + _kAppNameTrimmed
      params.button4 = "Cancel"

    default:
      return
    }
    // use an Alert to obtain a decision
    displayAlert(params)
  }

  // ----------------------------------------------------------------------------
  // MARK: - ApiDelegate methods
  
  /// Process a sent message
  ///
  /// - Parameter text:       text of the command
  ///
  public func sentMessage(_ text: String) {
    if !text.hasSuffix("|ping") { appendMessage(text) }
    if text.hasSuffix("|ping") && showPings { appendMessage(text) }
  }
  /// Process a received message
  ///
  /// - Parameter text:       text received from the Radio
  ///
  public func receivedMessage(_ text: String) {
    // get all except the first character
    let suffix = String(text.dropFirst())
    
    // switch on the first character
    switch text[text.startIndex] {
    
    case "C":   appendMessage(text)       // Commands
    case "H":   appendMessage(text)       // Handle type
    case "M":   appendMessage(text)       // Message Type
    case "R":   parseReplyMessage(suffix) // Reply Type
    case "S":   appendMessage(text)       // Status type
    case "V":   appendMessage(text)       // Version Type
    default:    appendMessage("ERROR: Unknown Message, \(text[text.startIndex] as! CVarArg)") // Unknown Type
    }
    refreshObjects()
  }
  // unused ApiDelegate methods
  func addReplyHandler(_ sequenceNumber: SequenceNumber, replyTuple: ReplyTuple) { /* unused */ }
  func defaultReplyHandler(_ command: String, sequenceNumber: SequenceNumber, responseValue: String, reply: String) { /* unused */ }
  func vitaParser(_ vitaPacket: Vita) { /* unused */ }
}
