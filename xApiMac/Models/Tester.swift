//
//  Tester.swift
//
//
//  Created by Douglas Adams on 8/9/20.
//

import xLib6001
import SwiftyUserDefaults
import SwiftUI
import xClient6001

#if os(macOS)
let kAppName = "xApiMac"
#elseif os(iOS)
let kAppName = "xApiIos"
#endif

struct Message: Identifiable {
    var id = 0
    var text = ""
}

enum FilterObjects: String, CaseIterable {
    case none
    case sliceMeters
    case otherMeters
    case allMeters
    case slices
    case streams
}

enum FilterMessages: String, CaseIterable {
    case none
    case prefix
    case includes
    case excludes
    case command
    case status
    case reply
    case S0
}

final class Tester: ObservableObject {
    // ----------------------------------------------------------------------------
    // MARK: - Published properties

    @Published var clearAtConnect               = false { didSet {Defaults.clearAtConnect = clearAtConnect} }
    @Published var clearAtDisconnect            = false { didSet {Defaults.clearAtDisconnect = clearAtDisconnect} }
    @Published var clearOnSend                  = false { didSet {Defaults.clearOnSend = clearOnSend} }
    @Published var cmdToSend                    = ""
    @Published var guiIsEnabled                 = false { didSet {Defaults.guiIsEnabled = guiIsEnabled} }
    @Published var fontSize                     = 12 { didSet {Defaults.fontSize = fontSize} }
    @Published var showPings                    = false { didSet {Defaults.showPings = showPings} }
    @Published var showReplies                  = false { didSet {Defaults.showReplies = showReplies} }
    @Published var showTimestamps               = false { didSet {Defaults.showTimestamps = showTimestamps} }
    @Published var smartlinkIsEnabled           = false { didSet {Defaults.smartlinkIsEnabled = smartlinkIsEnabled} }

    @Published var filteredMessages             = [Message]()
    @Published var messagesFilterBy: String     = "none" { didSet {filterCollection() ; Defaults.messagesFilterBy = messagesFilterBy }}
    @Published var messagesFilterText           = "" { didSet {filterCollection() ; Defaults.messagesFilterText = messagesFilterText }}
    @Published var messagesScrollTo: CGPoint?
    @Published var objectsFilterBy: String      = "none"

    // ----------------------------------------------------------------------------
    // MARK: - Internal properties

    var activePacket: DiscoveryPacket?
    var clientId: String? {
        get { Defaults.clientId }
        set { Defaults.clientId = newValue }
    }
    var defaultNonGuiConnection: String? {
        get { Defaults.defaultNonGuiConnection }
        set { Defaults.defaultNonGuiConnection = newValue }
    }
    var defaultGuiConnection: String? {
        get { Defaults.defaultGuiConnection }
        set { Defaults.defaultGuiConnection = newValue }
    }
    var isConnected  = false
    var smartlinkEmail: String? {
        get { Defaults.smartlinkEmail }
        set { Defaults.smartlinkEmail = newValue }
    }
    var stationName  = ""

    // ----------------------------------------------------------------------------
    // MARK: - Private properties

    private var _api                  = Api.sharedInstance
    private var _commandsIndex        = 0
    private var _commandHistory       = [String]()
    private let _log: (_ msg: String, _ level: MessageLevel, _ function: StaticString, _ file: StaticString, _ line: Int) -> Void
    private var _messageNumber        = 0
    private let _objectQ              = DispatchQueue(label: kAppName + ".objectQ", attributes: [.concurrent])
    private var _radios: [Radio] { Discovery.sharedInstance.radios }
    private var _previousCommand      = ""
    private var _startTimestamp: Date?

    // ----------------------------------------------------------------------------
    // MARK: - Private properties with concurrency protection

    private var messages: [Message] {
        get { return _objectQ.sync { _messages } }
        set { _objectQ.sync(flags: .barrier) { _messages = newValue } } }

    // ----- Backing store, do not use -----
    private var _messages       = [Message]()

    // ----------------------------------------------------------------------------
    // MARK: - Initialization

    init() {
        // initialize @Published properties
        clearAtConnect                  = Defaults.clearAtConnect
        clearAtDisconnect               = Defaults.clearAtDisconnect
        clearOnSend                     = Defaults.clearOnSend
        fontSize                        = Defaults.fontSize
        guiIsEnabled                    = Defaults.guiIsEnabled
        showPings                       = Defaults.showPings
        showReplies                     = Defaults.showReplies
        showTimestamps                  = Defaults.showTimestamps
        smartlinkIsEnabled              = Defaults.smartlinkIsEnabled

        messagesFilterBy                = Defaults.messagesFilterBy
        messagesFilterText              = Defaults.messagesFilterText
        objectsFilterBy                 = Defaults.objectsFilterBy

        // initialize and configure the Logger
        _log = LogManager.sharedInstance.logMessage

        // give the Api access to our logger
        LogProxy.sharedInstance.delegate = LogManager.sharedInstance

        // is there a saved Client ID?
        if clientId == nil {
            // NO, assign one
            clientId = UUID().uuidString
            _log("Tester: ClientId created - \(clientId!)", .debug, #function, #file, #line)
        }
        _api.testerModeEnabled = true
        // receive delegate actions from the Api
        _api.testerDelegate = self
    }

    // ----------------------------------------------------------------------------
    // MARK: - Internal methods (Tester related)

    /// A command  was sent to the Radio
    ///
    func sent(command: String) {
        guard command.isEmpty == false else { return }

        if command != _previousCommand { _commandHistory.append(command) }

        _previousCommand = command
        _commandsIndex = _commandHistory.count - 1

        // optionally clear the Command field
        if clearOnSend { DispatchQueue.main.async { self.cmdToSend = "" }}
    }

    /// Clear the messages area
    ///
    func clearObjectsAndMessages() {
        DispatchQueue.main.async {  [self] in
            _messageNumber = 0
            messages.removeAll()
            filterCollection()
        }
    }

    /// Send a command to the Radio
    ///
    func sendCommand(_ command: String) {
        guard command.isEmpty == false else { return }

        // send the command to the Radio via TCP
        _api.radio!.sendCommand( command )

        if command != _previousCommand { _commandHistory.append(command) }

        _previousCommand = command
        _commandsIndex = _commandHistory.count - 1

        // optionally clear the Command field
        if clearOnSend { DispatchQueue.main.async { self.cmdToSend = "" }}
    }

    /// Adjust the font size larger or smaller (within limits)
    /// - Parameter larger:           larger?
    ///
    func fontSize(larger: Bool) {
        // incr / decr the size
        var newSize =  Defaults.fontSize + (larger ? +1 : -1)
        // subject to limits
        if larger {
            if newSize > Defaults.fontMaxSize { newSize = Defaults.fontMaxSize }
        } else {
            if newSize < Defaults.fontMinSize { newSize = Defaults.fontMinSize }
        }
        fontSize = newSize
    }

    // ----------------------------------------------------------------------------
    // MARK: - Private methods (common to Messages and Objects)

    /// Filter the message and object collections
    /// - Parameter type:     object type
    ///
    private func filterCollection() {
        switch messagesFilterBy {

        case FilterMessages.none.rawValue:       filteredMessages = messages
        case FilterMessages.prefix.rawValue:     filteredMessages =  messages.filter { $0.text.contains("|" + messagesFilterText) }
        case FilterMessages.includes.rawValue:   filteredMessages =  messages.filter { $0.text.contains(messagesFilterText) }
        case FilterMessages.excludes.rawValue:   filteredMessages =  messages.filter { !$0.text.contains(messagesFilterText) }
        case FilterMessages.command.rawValue:    filteredMessages =  messages.filter { $0.text.dropFirst(9).prefix(1) == "C" }
        case FilterMessages.S0.rawValue:         filteredMessages =  messages.filter { $0.text.dropFirst(9).prefix(2) == "S0" }
        case FilterMessages.status.rawValue:     filteredMessages =  messages.filter { $0.text.dropFirst(9).prefix(1) == "S" && $0.text.dropFirst(10).prefix(1) != "0"}
        case FilterMessages.reply.rawValue:      filteredMessages =  messages.filter { $0.text.dropFirst(9).prefix(1) == "R" }
        default: break
        }
    }

    // ----------------------------------------------------------------------------
    // MARK: - Private methods (Messages-related)

    /// Add an entry to the messages collection
    /// - Parameter text:       the text of the entry
    ///
    private func populateMessages(_ text: String) {
        DispatchQueue.main.async { [self] in
            // guard that a session has been started
            if _startTimestamp == nil { _startTimestamp = Date() }

            // add the Timestamp to the Text
            let timeInterval = Date().timeIntervalSince(_startTimestamp!)
            let stampedText = String( format: "%8.3f", timeInterval) + " " + text

            _messageNumber += 1
            messages.append( Message(id: _messageNumber, text: stampedText))

            filterCollection()
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
        guard components.count >= 2 else { populateMessages("ERROR: R\(commandSuffix)") ; return }

        if showReplies || components[1] != "0" || (components.count >= 3 && components[2] != "") {
            populateMessages("R\(commandSuffix)")
        }
    }
}

extension Tester: RadioManagerDelegate {
    func willConnect() { if clearAtConnect { clearObjectsAndMessages() } }
    func willDisconnect() { if clearAtDisconnect { clearObjectsAndMessages() } }

    // unused RadioManagerDelegate methods
    func didConnect() { /* unused */ }
    func didFailToConnect() { /* unused */ }
}

extension Tester: ApiDelegate {
    public func sentMessage(_ text: String) {
        if !text.hasSuffix("|ping") { populateMessages(text) }
        if text.hasSuffix("|ping") && showPings { populateMessages(text) }
    }

    public func receivedMessage(_ text: String) {
        // get all except the first character
        let suffix = String(text.dropFirst())

        // switch on the first character
        switch text[text.startIndex] {

        case "C":   populateMessages(text)       // Commands
        case "H":   populateMessages(text)       // Handle type
        case "M":   populateMessages(text)       // Message Type
        case "R":   parseReplyMessage(suffix)    // Reply Type
        case "S":   populateMessages(text)       // Status type
        case "V":   populateMessages(text)       // Version Type
        default:    populateMessages("Tester: Unknown Message type, \(text[text.startIndex]) ") // Unknown Type
        }
    }

    // unused ApiDelegate methods
    func addReplyHandler(_ sequenceNumber: SequenceNumber, replyTuple: ReplyTuple) { /* unused */ }
    func defaultReplyHandler(_ command: String, sequenceNumber: SequenceNumber, responseValue: String, reply: String) { /* unused */ }
    func vitaParser(_ vitaPacket: Vita) { /* unused */ }
}
