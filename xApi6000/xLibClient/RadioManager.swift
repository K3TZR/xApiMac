//
//  RadioManager.swift
//  xLibClient package
//
//  Created by Douglas Adams on 8/23/20.
//

import Foundation
import SwiftUI
import xLib6000

typealias OpenCloseStatus = (isNewApi: Bool, status: ConnectionStatus, connectionCount: Int)

struct PickerPacket : Identifiable {
  var id        = 0
  var type      : ConnectionType = .local
  var nickname  = ""
  var status    : ConnectionStatus = .available
  var stations  = ""
}

enum ConnectionType : String {
  case wan
  case local
}

enum ConnectionStatus : String {
  case available
  case inUse = "in_use"
}

struct Station : Identifiable {
  var id        = 0
  var station   = ""
  var clientId  : String?
}

// ----------------------------------------------------------------------------
// RadioManager protocol definition
// ----------------------------------------------------------------------------

protocol RadioManagerDelegate {

  /// Called asynchronously by RadioManager to indicate success / failure for a Radio connection attempt
  /// - Parameters:
  ///   - state:          true if connected
  ///   - connection:     the connection string attempted
  ///
  func connectionState(_ state: Bool, _ connection: String)
  
  /// Called  asynchronously by RadioManager when a disconnection occurs
  /// - Parameter msg:      explanation
  ///
  func disconnectionState(_ msg: String)

  /// Called by the SmartLinkView to initiate a SmartLink Login | Logout
  ///
  func smartLinkLogin()
  
  /// Called asynchronously by WanManager to indicate success / failure for a SmartLink server connection attempt
  /// - Parameter state:      true if connected
  ///
  func smartLinkLoginState(_ state: Bool)
  
  /// Called asynchronously by WanManager to return the results of a SmartLInk Test
  /// - Parameters:
  ///   - status:   success / failure
  ///   - msg:      a string describing the result
  ///
  func smartLinkTestResults(status: Bool, msg: String)

  /// Called by WanManager or RadioManager to Get / Set / Delete the saved Refresh Token
  /// - Parameters:
  ///   - service:  the Auth0 service name
  ///   - account:  the Auth0 email address
  ///
  func refreshTokenGet(service: String, account: String) -> String?
  func refreshTokenSet(service: String, account: String, refreshToken: String)
  func refreshTokenDelete(service: String, account: String)

  /// Called to request an Alert to be shown
  /// - Parameters:
  ///   - style:    the alert style
  ///   - msg:      the alert message
  ///   - text:     the alert informative text
  ///   - button1:  button text (if any)
  ///   - button2:  button text (if any)
  ///   - button3:  button text (if any)
  ///   - button4:  button text (if any)
  ///   - handler:  a callback closure
  ///
//  func showAlert(_ style: NSAlert.Style, msg: String, text: String,
//                 button1: String, button2: String, button3: String, button4: String,
//                 handler: @escaping (NSApplication.ModalResponse) -> Void)

  func openStatus(_ status: OpenCloseStatus, _ clients: [GuiClient], handler: @escaping (NSApplication.ModalResponse) -> Void )
  func closeStatus(_ status: OpenCloseStatus, _ clients: [GuiClient], handler: @escaping (NSApplication.ModalResponse) -> Void )

  var clientId              : String  {get}
  var connectAsGui          : Bool    {get}
  var kAppNameTrimmed       : String  {get}
  var smartLinkAuth0Email   : String  {get set}
  var smartLinkEnabled      : Bool    {get}
  var stationName           : String  {get}     
}

// ----------------------------------------------------------------------------
// RadioManager class implementation
// ----------------------------------------------------------------------------

public final class RadioManager : ObservableObject {
  
  // ----------------------------------------------------------------------------
  // MARK: - Static properties

  static let kAuth0Domain               = "https://frtest.auth0.com/"
  static let kAuth0ClientId             = "4Y9fEIIsVYyQo5u6jr7yBWc4lV5ugC2m"
  static let kRedirect                  = "https://frtest.auth0.com/mobile"
  static let kResponseType              = "token"
  static let kScope                     = "openid%20offline_access%20email%20given_name%20family_name%20picture"
  static let kUserInitiated             = "User initiated"

  // ----------------------------------------------------------------------------
  // MARK: - Published properties

  var useLowBw : Bool = false
  
  @Published var activePacket           : DiscoveryPacket?
  @Published var activeRadio            : Radio?
  @Published var stations               = [Station]()
  @Published var stationChoices         = [Station]()
  @Published var bindingChoices         = [Station]()

  @Published var pickerPackets          = [PickerPacket]()
  @Published var showPickerSheet        = false
  @Published var pickerSelection        = Set<Int>()
  @Published var stationSelection       = 0
  @Published var bindingSelection       = 0  {didSet {bind( bindingSelection )}}

  @Published var showAuth0Sheet         = false

  @Published var smartLinkIsLoggedIn    = false
  @Published var smartLinkTestStatus    = false
  @Published var smartLinkName          = ""
  @Published var smartLinkCallsign      = ""
  @Published var smartLinkImage         : NSImage?

  // ----------------------------------------------------------------------------
  // MARK: - Internal properties

  var delegate            : RadioManagerDelegate
  var wanManager          : WanManager?
  var discoveryPackets    : [DiscoveryPacket] { Discovery.sharedInstance.discoveredRadios }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties

  private var _api        = Api.sharedInstance          // initializes the API
  private let _log        = Logger.sharedInstance.logMessage

  private let kAvailable  = "available"
  private let kInUse      = "in_use"

  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  init(delegate: RadioManagerDelegate) {
    self.delegate = delegate

    // give the Api access to our logger
    Log.sharedInstance.delegate = Logger.sharedInstance

    // start Discovery
    let _ = Discovery.sharedInstance
    
    // start listening to notifications
    addNotifications()
  }

  // ----------------------------------------------------------------------------
  // MARK: - Internal methods
  
  /// Initiate a Login to the SmartLink server
  /// - Parameter auth0Email: an Auth0 email address
  ///
  func smartLinkLogin(with auth0Email: String) {
    // start the WanManager
    wanManager = WanManager(radioManager: self)
    
    if wanManager!.smartLinkLogin(using: auth0Email) {
      smartLinkIsLoggedIn = true
    } else {
      wanManager!.validateAuth0Credentials()
    }
  }
  
  /// Initiate a Logout from the SmartLink server
  ///
  func smartLinkLogout() {
    if smartLinkIsLoggedIn {
      // remove any SmartLink radios from Discovery
      Discovery.sharedInstance.removeSmartLinkRadios()
            
      if delegate.smartLinkAuth0Email != "" {
        // remove the RefreshToken
        delegate.refreshTokenDelete( service: delegate.kAppNameTrimmed + ".oauth-token", account: delegate.smartLinkAuth0Email)
      }
      // close out the connection
      wanManager?.smartLinkLogout()
    }
    wanManager = nil
    
    // remember the current state
    smartLinkIsLoggedIn = false
    
    // remove the current user info
    smartLinkName = ""
    smartLinkCallsign = ""
    smartLinkImage = nil
  }
  
  /// Initiate a connection to a Radio
  /// - Parameter connection:   a connection string (in the form <type>.<serialNumber>)
  ///
  func connect(to connection: String = "") {
    
    // was a connection specified?
    if connection == "" {
      // NO, where one or more radios found?
      if discoveryPackets.count > 0 {
        // YES, attempt a connection to the first
        connectTo(index: 0)
      } else {
        // NO, no radios found
        delegate.connectionState(false, connection)
      }
    } else {
      // YES, is it a valid connection string?
      if let conn = parseConnection(connection) {
        // VALID, find the matching packet
        var foundIndex : Int? = nil
        for (i, packet) in discoveryPackets.enumerated() where  (packet.serialNumber == conn.serialNumber) && (packet.isWan == conn.isWan) {
          foundIndex = i
        }
        // is there a match?
        if let index = foundIndex {
          // YES, attempt a connection to it
          connectTo(index: index)
        } else {
          // NO, no match found
          delegate.connectionState(false, connection)
        }
      } else {
        // NO, not a valid connection string
        delegate.connectionState(false, connection)
      }
    }
  }
  
  /// Initiate a connection to a Radio using the RadioPicker
  ///
  func connectUsingPicker() {
    pickerPackets = getPickerPackets()
    smartLinkTestStatus = false
    pickerSelection = Set<Int>()
    showPickerSheet = true
  }
  
  /// Disconnect the current connection
  /// - Parameter msg:    explanation
  ///
  func disconnect(msg: String = RadioManager.kUserInitiated) {
    
    _log("Tester: Disconnect - \(msg)", .info,  #function, #file, #line)
    
    // remove all Client Id's
    for client in activePacket!.guiClients {
      client.value.clientId = nil
    }
    
    // tell the library to disconnect
    _api.disconnect(reason: msg)
    
    DispatchQueue.main.async { [self] in
      activePacket = nil
      activeRadio = nil
      stationSelection = 0
      bindingSelection = 0
      stations.removeAll()
      
    }
    // if anything unusual, tell the delegate
    if msg != RadioManager.kUserInitiated {
      delegate.disconnectionState( msg)
    }
  }
  
  /// Determine the state of the Radio being opened and allow the user to choose how to proceed
  /// - Parameter packet:     the packet describing the Radio to be opened
  ///
  func openRadio(_ packet: DiscoveryPacket) {
        
    guard delegate.connectAsGui else {
      connectRadio(packet, isGui: delegate.connectAsGui, station: delegate.stationName)
      return
    }
    
    let status = packet.status.lowercased()
    let guiCount = packet.guiClients.count
    let isNewApi = Version(packet.firmwareVersion).isNewApi
    
    let handles = [Handle](packet.guiClients.keys)
    let clients = [GuiClient](packet.guiClients.values)
    
    switch (isNewApi, status, guiCount) {
    case (false, kAvailable, _):          // oldApi, not connected to another client
      delegate.openStatus( (false, ConnectionStatus.available, 0), clients )
      { [self] _ in
        connectRadio(packet, isGui: delegate.connectAsGui, station: delegate.stationName)
      }

    case (false, kInUse, _):              // oldApi, connected to another client
      delegate.openStatus( (false, ConnectionStatus.inUse, 1), clients )
      { [self] response in
        switch response {
        case NSApplication.ModalResponse.alertFirstButtonReturn:
          connectRadio(packet, isGui: delegate.connectAsGui, pendingDisconnect: .oldApi, station: delegate.stationName)
          sleep(1)
          _api.disconnect()
          sleep(1)
          connectUsingPicker()
        default:  break
        }
      }

    case (true, kAvailable, 0):           // newApi, not connected to another client
      delegate.openStatus( (true, ConnectionStatus.available, 0), clients )
      { [self] _ in
        connectRadio(packet, station: delegate.stationName)
      }
      
    case (true, kAvailable, _):           // newApi, connected to another client
      delegate.openStatus( (true, ConnectionStatus.available, 1), clients)
      { [self] response in
        switch response {
        case NSApplication.ModalResponse.alertFirstButtonReturn:  connectRadio(packet, isGui: delegate.connectAsGui, pendingDisconnect: .newApi(handle: handles[0]), station: delegate.stationName)
        case NSApplication.ModalResponse.alertSecondButtonReturn: connectRadio(packet, isGui: delegate.connectAsGui, station: delegate.stationName)
        default:  break
        }
      }

    case (true, kInUse, 2):               // newApi, connected to 2 clients
      delegate.openStatus( (true, ConnectionStatus.inUse, 2), clients)
      { [self] response in
        switch response {
        case NSApplication.ModalResponse.alertFirstButtonReturn:  connectRadio(packet, isGui: delegate.connectAsGui, pendingDisconnect: .newApi(handle: handles[0]), station: delegate.stationName)
        case NSApplication.ModalResponse.alertSecondButtonReturn: connectRadio(packet, isGui: delegate.connectAsGui, pendingDisconnect: .newApi(handle: handles[1]), station: delegate.stationName)
        default:  break
        }
      }

    default:
      break
    }
  }
  
  /// Determine the state of the Radio being closed and allow the user to choose how to proceed
  /// - Parameter packet:     the packet describing the Radio to be opened
  ///
  func closeRadio(_ packet: DiscoveryPacket) {
    
    guard delegate.connectAsGui else {
      disconnect()
      return
    }

    let status = packet.status.lowercased()
    let guiCount = packet.guiClients.count
    let isNewApi = Version(packet.firmwareVersion).isNewApi
    
    let handles = [Handle](packet.guiClients.keys)
    let clients = [GuiClient](packet.guiClients.values)
    
    // CONNECT, is the selected radio connected to another client?
    switch (isNewApi, status, guiCount) {
      
    case (false, _, _):                   // oldApi
      self.disconnect()
      
    case (true, kAvailable, 1):           // newApi, 1 client
      // am I the client?
      if handles[0] == _api.connectionHandle {
        // YES, disconnect me
        self.disconnect()
        
      } else {
        
        // FIXME: don't think this code can ever be executed???
        
        // NO, let the user choose what to do
        delegate.closeStatus( (true, ConnectionStatus.inUse, 1), clients)
        { [self] response in
          switch response {
          case NSApplication.ModalResponse.alertFirstButtonReturn:  _api.requestClientDisconnect( packet: packet, handle: handles[0])
          case NSApplication.ModalResponse.alertSecondButtonReturn: disconnect()
          default:  break
          }
        }
      }
        
    case (true, kInUse, 2):           // newApi, 2 clients
      delegate.closeStatus( (true, ConnectionStatus.inUse, 2), clients)
      { [self] response in
        switch response {
        case NSApplication.ModalResponse.alertFirstButtonReturn:  _api.requestClientDisconnect( packet: packet, handle: handles[0])
        case NSApplication.ModalResponse.alertSecondButtonReturn: _api.requestClientDisconnect( packet: packet, handle: handles[1])
        case NSApplication.ModalResponse.alertThirdButtonReturn:  disconnect()
        default:  break
        }
      }
      
    default:
      self.disconnect()
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Picker actions
  
  /// Called when the Picker's Close button is clicked
  ///
  func closePicker() {
    showPickerSheet = false
  }
  
  /// Called when the Picker's Test button is clicked
  ///
  func testSmartLink() {
    if let i = pickerSelection.first {      
      let packet = discoveryPackets[i]
      wanManager?.sendTestConnection(for: packet)
    }
  }
  
  /// Called when the Picker's Select button is clicked
  ///
  func connectToSelection() {
    if let i = pickerSelection.first {
      // remove the selection highlight
      pickerSelection = Set<Int>()
      connectTo(index: i)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Auth0 actions

  /// Called when the Auth0 Login Cancel button is clicked
  ///
  func cancelButton() {
    _log("RadioManager: Auth0 cancel button", .debug,  #function, #file, #line)
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods

  private func bind(_ index: Int) {
    // get the clientId (index 0 is "None", i.e. "unbind")
    let clientId = (index == 0) ? "" : stations[index - 1].clientId
    
    // cause a bind command to be sent
    activeRadio?.boundClientId = clientId
  }
  
  /// Connect to the Radio found at the specified index in the Discovered Radios
  /// - Parameter index:    an index into the discovered radios array
  ///
  private func connectTo(index: Int) {
    
    guard activePacket == nil else { disconnect() ; return }
    
    if discoveryPackets.count - 1 >= index {
      let packet = discoveryPackets[index]
      
      if packet.isWan {
        wanManager?.validateWanRadio(packet)
      } else {
        openRadio(packet)
      }
    }
  }
  
  /// Attempt to open a connection to the specified Radio
  /// - Parameters:
  ///   - packet:             the packet describing the Radio
  ///   - pendingDisconnect:  a struct describing a pending disconnect (if any)
  ///
  private func connectRadio(_ packet: DiscoveryPacket, isGui: Bool = true, pendingDisconnect: Api.PendingDisconnect = .none, station: String = "") {
    // station will be computer name if not passed
    let stationName = (station == "" ? (Host.current().localizedName ?? "").replacingSpaces(with: "") : station)
    
    // attempt a connection
    _api.connect(packet,
                 station           : stationName,
                 program           : delegate.kAppNameTrimmed,
                 clientId          : isGui ? delegate.clientId : nil,
                 isGui             : isGui,
                 wanHandle         : packet.wanHandle,
                 logState: .none,
                 pendingDisconnect : pendingDisconnect)
  }
  
  /// Create a subset of DiscoveryPackets for use by the RadioPicker
  /// - Returns:                an array of PickerPacket
  ///
  private func getPickerPackets() -> [PickerPacket] {
    var pickerPackets = [PickerPacket]()
    
    for (i, packet) in discoveryPackets.enumerated() {
      pickerPackets.append( PickerPacket(id: i, type: packet.isWan ? .wan : .local, nickname: packet.nickname, status: ConnectionStatus(rawValue: packet.status.lowercased()) ?? .inUse, stations: packet.guiClientStations))
    }
    return pickerPackets
  }

  /// Create a subset of GuiClients
  /// - Returns:                an array of Station
  ///
  private func getStations(_ packet: DiscoveryPacket) -> [Station] {
    var stations = [Station]()
    var i = 0
    
    for client in packet.guiClients {
      let station = Station(id: i, station: client.value.station, clientId: client.value.clientId)
      stations.append( station )
      i += 1
    }
    return stations
  }

  /// Parse the Type and Serial Number in a connection string
  ///
  /// - Parameter connectionString:   a string of the form <type>.<serialNumber>
  /// - Returns:                      a tuple containing the parsed values (if any)
  ///
  private func parseConnection(_ connectionString: String) -> (serialNumber: String, isWan: Bool)? {
    // A Connection is stored as a String in the form:
    //      "<type>.<serial number>"
    //      where:
    //          <type>            "local" OR "wan", (wan meaning SmartLink)
    //          <serial number>   a serial number, e.g. 1234-5678-9012-3456
    //
    // If the Type and period separator are omitted. "local" is assumed
    //

    // split by the "." (if any)
    let parts = connectionString.components(separatedBy: ".")
    if parts.count == 2 {
      // <type>.<serial number>
      return (parts[1], (parts[0] == "wan") ? true : false)
      
    } else if parts.count == 1 {
      // <serial number>, type defaults to local
      return (parts[0], false)
    } else {
      // unknown, not a valid connection string
      return nil
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Notification methods
  
  /// Setup notification observers
  ///
  private func addNotifications() {
    NotificationCenter.makeObserver(self, with: #selector(discoveredRadios(_:)),   of: .discoveredRadios)
    NotificationCenter.makeObserver(self, with: #selector(clientDidConnect(_:)),   of: .clientDidConnect)
    NotificationCenter.makeObserver(self, with: #selector(guiClientHasBeenAdded(_:)),   of: .guiClientHasBeenAdded)
    NotificationCenter.makeObserver(self, with: #selector(guiClientHasBeenUpdated(_:)), of: .guiClientHasBeenUpdated)
    NotificationCenter.makeObserver(self, with: #selector(guiClientHasBeenRemoved(_:)), of: .guiClientHasBeenRemoved)
  }

  @objc private func discoveredRadios(_ note: Notification) {
    // the list of radios has changed
    DispatchQueue.main.async { [self] in
      pickerPackets = getPickerPackets()
//      stations = getStations()
//      stationChoices = insertChoice("All", into: stations)
//      bindingChoices = insertChoice("None", into: stations)
    }
  }

  @objc private func clientDidConnect(_ note: Notification) {
    if let radio = note.object as? Radio {
      DispatchQueue.main.async { [self] in
        activePacket = radio.packet
        activeRadio = radio
      }
      let connection = (radio.packet.isWan ? "wan" : "local") + "." + radio.packet.serialNumber
      delegate.connectionState(true, connection)
    }
  }

  @objc private func guiClientHasBeenAdded(_ note: Notification) {
    if let packet = note.object as? DiscoveryPacket {
      DispatchQueue.main.async { [self] in
        pickerPackets = getPickerPackets()
        stations = getStations(packet)

//        stationChoices = insertChoice("All", into: stations)
//        bindingChoices = insertChoice("None", into: stations)
      }
    }
  }
  
  @objc private func guiClientHasBeenUpdated(_ note: Notification) {
    if let packet = note.object as? DiscoveryPacket {
      // ClientId has been populated
      DispatchQueue.main.async { [self] in
        pickerPackets = getPickerPackets()
        stations = getStations(packet)
        
//        stationChoices = insertChoice("All", into: stations)
//        bindingChoices = insertChoice("None", into: stations)
      }
    }
  }

  @objc private func guiClientHasBeenRemoved(_ note: Notification) {

    if let packet = note.object as? DiscoveryPacket {
      DispatchQueue.main.async { [self] in
        pickerPackets = getPickerPackets()
        stations = getStations(packet)

//        stationChoices = insertChoice("All", into: stations)
//        bindingChoices = insertChoice("None", into: stations)
        
        // connected?
        if activeRadio != nil {
          // YES, how?
          if delegate.connectAsGui {
            // as Gui
            stationSelection = 0
          } else {
            // as Non-Gui
            bindingSelection = 0
          }
        }
      }
    }
  }
  
}
