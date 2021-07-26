//
//  ObjectsViewNew.swift
//  xApiMac
//
//  Created by Douglas Adams on 4/13/21.
//

import SwiftUI
import xClient6001
import xLib6001

struct ObjectsView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radio: Radio

    @AppStorage("fontSize") var fontSize: Int = 10

    var body: some View {

        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading) {
                RadioView(radio: radio)
                ClientView(tester: tester, radio: radio)
            }
            .frame(minWidth: 920, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity, alignment: .leading)
            .font(.system(size: CGFloat(fontSize), weight: .regular, design: .monospaced))
        }
    }
}

 struct ObjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectsView(tester: Tester(), radio: Radio("local.1234-5678-9012-3456"))
    }
 }

// ----------------------------------------------------------------------------

struct RadioView: View {
    @ObservedObject var radio: Radio

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack(spacing: 20) {
                    Text("RADIO -> ").frame(width: 140, alignment: .leading)
                    Text(radio.nickname).frame(width: 120, alignment: .leading)
                    Text(radio.model)
                    Text(radio.status)
                    Text(radio.isWan ? "Smartlink" : "Local")
                    Text(radio.publicIp)
                    Text(radio.serialNumber)
                    Text(radio.firmwareVersion)
                }.padding(.trailing, 10)
                HStack(spacing: 20) {
                    Text("Atu \(radio.atuPresent ? "Y" : "N")")
                    Text("Gps \(radio.gpsPresent ? "Y" : "N")")
                    Text("Scu \(radio.numberOfScus)")
                }
            }
            if radio.atuPresent {  AtuView(radio: radio) }
            if radio.gpsPresent {  GpsView(radio: radio) }
        }
        .foregroundColor(Color(.systemGreen))
    }
}

// ----------------------------------------------------------------------------

struct ClientView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radio: Radio

    @AppStorage("guiIsEnabled") var guiIsEnabled: Bool = false

    var body: some View {

        let guiClients = radio.guiClients

        if !guiIsEnabled { NonGuiView(tester: tester, radio: radio) }
        ForEach(guiClients, id: \.id) { guiClient in
            Divider().background(Color(.red))
            HStack(spacing: 20) {
                Text("GUI CLIENT -> ").frame(width: 140, alignment: .leading)
                Text(guiClient.station).frame(width: 120, alignment: .leading)
                Text("Handle \(guiClient.handle.hex)")
                Text("ClientId \(guiClient.clientId ?? "Unknown")")
                Text("LocalPtt \(guiClient.isLocalPtt ? "Y" : "N")")
                Text("Program \(guiClient.program)")
            }
            ClientSubView(tester: tester, radio: radio, handle: guiClient.handle)
        }
    }
}

struct ClientSubView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radio: Radio
    let handle: Handle

    @AppStorage("objectsFilterBy") var objectsFilterBy: ObjectFilters = .core

    var body: some View {

        switch objectsFilterBy {
        case .core:
            StreamView(tester: tester, radio: radio, handle: handle)
            PanadapterView(radio: radio, handle: handle, showMeters: true)
        case .coreNoMeters:
            StreamView(tester: tester, radio: radio, handle: handle)
            PanadapterView(radio: radio, handle: handle, showMeters: false)
        case .amplifiers:       AmplifierView(radio: radio)
        case .bandSettings:     BandView(radio: radio)
        case .interlock:        InterlockView(radio: radio)
        case .memories:         MemoryView(radio: radio)
        case .meters:           MeterView(radio: radio, sliceId: nil)
        case .streams:          StreamView(tester: tester, radio: radio, handle: handle)
        case .transmit:         TransmitView(radio: radio, handle: handle)
        case .tnfs:             TnfView(radio: radio)
        case .waveforms:        WaveformView(radio: radio)
        case .xvtrs:            XvtrView(radio: radio)
        }
    }
}

// ----------------------------------------------------------------------------

struct NonGuiView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radio: Radio

    @AppStorage("objectsFilterBy") var objectsFilterBy: ObjectFilters = .core

    var body: some View {
        VStack(alignment: .leading) {
            Divider().foregroundColor(Color(.systemRed))
            HStack(spacing: 20) {
                Text("NONGUI CLIENT -> ").frame(width: 140, alignment: .leading)
                Text(tester.stationName ?? "UNKNOWN").frame(width: 120, alignment: .leading)
                Text("Handle \(Api.sharedInstance.connectionHandle!.hex)")
            }
            if objectsFilterBy == .streams { StreamView(tester: tester, radio: radio, handle: Api.sharedInstance.connectionHandle!) }
            if objectsFilterBy == .transmit { TransmitView(radio: radio, handle: Api.sharedInstance.connectionHandle!) }
        }
    }
}

// ----------------------------------------------------------------------------

struct PanadapterView: View {
    @ObservedObject var radio: Radio
    let handle: Handle
    let showMeters: Bool

    var body: some View {
        let panadapters = Array(radio.panadapters.values)

        ForEach(panadapters, id: \.id) { panadapter in
            if handle == panadapter.clientHandle {
                HStack(spacing: 20) {
                    Text("Panadapter").frame(width: 100, alignment: .trailing)
                    Text(panadapter.id.hex)
                    Text("Center \(panadapter.center)")
                    Text("Bandwidth \(panadapter.bandwidth)")
                }
                WaterfallView(radio: radio, panadapterId: panadapter.id)
                SliceView(radio: radio, panadapterId: panadapter.id, showMeters: showMeters)
            }
        }
    }
}

// ----------------------------------------------------------------------------

struct WaterfallView: View {
    @ObservedObject var radio: Radio
    let panadapterId: PanadapterStreamId

    var body: some View {
        let waterfalls = Array(radio.waterfalls.values)

        ForEach(waterfalls) { waterfall in
            if waterfall.panadapterId == panadapterId {
                HStack(spacing: 20) {
                    Text("Waterfall").frame(width: 100, alignment: .trailing)
                    Text(waterfall.id.hex)
                    Text("AutoBlack \(waterfall.autoBlackEnabled ? "Y" : "N")")
                    Text("ColorGain \(waterfall.colorGain)")
                    Text("BlackLevel \(waterfall.blackLevel)")
                    Text("Duration \(waterfall.lineDuration)")
                }
            }
        }
    }
}

// ----------------------------------------------------------------------------

struct SliceView: View {
    @ObservedObject var radio: Radio
    let panadapterId: PanadapterStreamId
    let showMeters: Bool

    var body: some View {
        let slices = Array(radio.slices.values)

        ForEach(slices) { slice in
            if slice.panadapterId == panadapterId {
                HStack(spacing: 20) {
                    Text("Slice").frame(width: 100, alignment: .trailing)
                    Text(String(format: "% 3d", slice.id))
                    Text("Frequency \(slice.frequency)")
                    Text("Mode \(slice.mode)")
                    Text("FilterLow \(slice.filterLow)")
                    Text("FilterHigh \(slice.filterHigh)")
                    Text("Active \(slice.active ? "Y" : "N")")
                    Text("Locked \(slice.locked ? "Y" : "N")")
                    Text("DAX channel \(slice.daxChannel)")
                    Text("DAX clients \(slice.daxClients)")
                }
                if showMeters { MeterView(radio: radio, sliceId: slice.id) }
            }
        }
    }
}

// ----------------------------------------------------------------------------

struct MeterView: View {
    @ObservedObject var radio: Radio
    let sliceId: ObjectId?

    var body: some View {
        let meters = Array(radio.meters.values).sorted {$0.id < $1.id}

        VStack(alignment: .leading) {
            ForEach(meters, id: \.id) { meter in
                MeterDetailView(meter: meter, sliceId: sliceId)
            }.foregroundColor(.secondary)
        }
    }
}

struct MeterDetailView: View {
    @ObservedObject var meter: Meter
    let sliceId: ObjectId?

    func valueColor(_ value: Float, _ low: Float, _ high: Float) -> Color {
        if value > high { return .red }
        if value < low { return .yellow }
        return .green
    }

    func show(_ meter: Meter) -> Bool {
        sliceId == nil && meter.source != "slc" || sliceId != nil && meter.source == "slc" && UInt16(meter.group) == sliceId
    }

    var body: some View {
        HStack(spacing: 20) {
            if show(meter) {
                Text("Meter").frame(width: 50, alignment: .leading).padding(.leading, sliceId == nil ? 20 : 120)
                Text(String(format: "% 3d", meter.id)).frame(width: 50, alignment: .leading)
                Text(meter.group).frame(width: 50, alignment: .leading)
                Text(meter.name).frame(width: 120, alignment: .leading)
                Text(String(format: "%-4.2f", meter.low)).frame(width: 100, alignment: .trailing)
                Text(String(format: "%-4.2f", meter.value))
                    .foregroundColor(valueColor(meter.value, meter.low, meter.high))
                    .frame(width: 100, alignment: .trailing)
                Text(String(format: "%-4.2f", meter.high)).frame(width: 100, alignment: .trailing)
                Text(meter.units).frame(width: 50, alignment: .leading)
                Text(String(format: "%02d", meter.fps) + " fps").frame(width: 75, alignment: .leading)
                Text(meter.desc)
            }
        }
    }
}

// ----------------------------------------------------------------------------

struct AmplifierView: View {
    @ObservedObject var radio: Radio

    var body: some View {
        let amplifiers = Array(radio.amplifiers.values)

        ForEach(amplifiers, id: \.id) { amplifier in
            HStack(spacing: 20) {
                Text("Amplifier").frame(width: 100, alignment: .trailing)
                Text(amplifier.id.hex)
                Text(amplifier.model)
                Text(amplifier.ip)
                Text("Port \(amplifier.port)")
                Text(amplifier.state)
            }
        }
    }
}

// ----------------------------------------------------------------------------

struct AtuView: View {
    @ObservedObject var radio: Radio

    @AppStorage("showButtons") var showButtons: Bool = false

    var body: some View {
        let atu = radio.atu!
        VStack {
            HStack(spacing: 20) {
                Text("ATU -> ").frame(width: 140, alignment: .leading)
                Text("").frame(width: 120, alignment: .leading)
                Text("Enabled \(atu.enabled ? "Y" : "N")")
                Text("Status \(atu.status)")
                Text("Memories enabled \(atu.memoriesEnabled ? "Y" : "N")")
                Text("Using memories \(atu.usingMemory ? "Y" : "N")")
            }
            if showButtons {
                HStack(spacing: 40) {
                    Button("ATU") { atu.start() }
                    Button("MEM") { atu.memoriesEnabled.toggle() }
                    Button("BYP") { atu.bypass() }
                }.foregroundColor(Color(.controlTextColor))
            }
        }
    }
}

// ----------------------------------------------------------------------------

struct BandView: View {
    @ObservedObject var radio: Radio

    var body: some View {
//        let bandSettings = radio.bandSettings

        HStack(spacing: 20) {
            Text("BANDSETTINGS -> ").frame(width: 140, alignment: .leading)
            Text("BANDSETTINGS NOT IMPLEMENTED")
        }
    }
}

// ----------------------------------------------------------------------------

struct GpsView: View {
    @ObservedObject var radio: Radio

    var body: some View {
//        let gps = radio.gps!

        HStack(spacing: 20) {
            Text("GPS -> ").frame(width: 140, alignment: .leading)
            Text("GPS NOT IMPLEMENTED")
        }
    }
}

// ----------------------------------------------------------------------------

struct InterlockView: View {
    @ObservedObject var radio: Radio

    var body: some View {
//        let interlock = radio.interlock!

        HStack(spacing: 20) {
            Text("INTERLOCK -> ").frame(width: 140, alignment: .leading)
            Text("INTERLOCK NOT IMPLEMENTED")
        }
    }
}

// ----------------------------------------------------------------------------

struct MemoryView: View {
    @ObservedObject var radio: Radio

    var body: some View {
//        let memories = radio.memories

        HStack(spacing: 20) {
            Text("MEMORY -> ").frame(width: 140, alignment: .leading)
            Text("MEMORY NOT IMPLEMENTED")
        }
    }
}

// ----------------------------------------------------------------------------

struct StreamView: View {
    @ObservedObject var tester: Tester
    @ObservedObject var radio: Radio
    let handle: Handle

    @AppStorage("showButtons") var showButtons: Bool = false

    var body: some View {
        let remoteRx = Array(radio.remoteRxAudioStreams.values)
        let remoteTx = Array(radio.remoteTxAudioStreams.values)
        let daxMic = Array(radio.daxMicAudioStreams.values)
        let daxRx = Array(radio.daxRxAudioStreams.values)
        let daxTx = Array(radio.daxTxAudioStreams.values)
        let daxIq = Array(radio.daxIqStreams.values)

        VStack(alignment: .leading) {
            ForEach(remoteRx) { stream in
                if handle == stream.clientHandle {
                    HStack(spacing: 20) {
                        if handle == Api.sharedInstance.connectionHandle { Button("Remove") { stream.remove() } }
                        Text("RemoteRxAudioStream")
                        Text(stream.id.hex)
                        Text("Handle \(stream.clientHandle.hex)")
                        Text("Compression \(stream.compression)")
                        Text("Ip \(stream.ip)")
                        Text("Streaming \(stream.isStreaming ? "Y" : "N")")
                    }
                    .foregroundColor(.red)
                }
            }
            ForEach(remoteTx) { stream in
                if handle == stream.clientHandle {
                    HStack(spacing: 20) {
                        if handle == Api.sharedInstance.connectionHandle { Button("Remove") { stream.remove() } }
                        Text("RemoteTxAudioStream")
                        Text(stream.id.hex)
                        Text("Handle \(stream.clientHandle.hex)")
                        Text("Compression \(stream.compression)")
                        Text("Streaming \(stream.isStreaming ? "Y" : "N")")
                    }
                    .foregroundColor(.orange)
                }
            }
            ForEach(daxMic) { stream in
                if handle == stream.clientHandle {
                    HStack(spacing: 20) {
                        if handle == Api.sharedInstance.connectionHandle { Button("Remove") { stream.remove() } }
                        Text("DaxMicAudioStream")
                        Text(stream.id.hex)
                        Text("Handle \(stream.clientHandle.hex)")
                        Text("Ip \(stream.ip)")
                    }
                    .foregroundColor(.yellow)
                }
            }
            ForEach(daxRx) { stream in
                if handle == stream.clientHandle {
                    HStack(spacing: 20) {
                        if handle == Api.sharedInstance.connectionHandle { Button("Remove") { stream.remove() } }
                        Text("DaxRxAudioStream")
                        Text(stream.id.hex)
                        Text("Handle \(stream.clientHandle.hex)")
                        Text("Channel \(stream.daxChannel)")
                        Text("Ip \(stream.ip)")
                    }
                    .foregroundColor(.green)
                }
            }
            ForEach(daxTx) { stream in

                if handle == stream.clientHandle {
                    HStack(spacing: 20) {
                        if handle == Api.sharedInstance.connectionHandle { Button("Remove") { stream.remove() } }
                        Text("DaxTxAudioStream")
                        Text("Id=\(stream.id.hex)")
                        Text("ClientHandle=\(stream.clientHandle.hex)")
                        Text("Transmit=\(stream.isTransmitChannel ? "Y" : "N")")
                    }
                    .foregroundColor(.blue)
                }
            }
            ForEach(daxIq) { stream in
                if handle == stream.clientHandle {
                    HStack(spacing: 20) {
                        if handle == Api.sharedInstance.connectionHandle { Button("Remove") { stream.remove() } }
                        Text("DaxIqStream")
                        Text(stream.id.hex)
                        Text("Handle=\(stream.clientHandle.hex)")
                        Text("Channel \(stream.channel)")
                        Text("Ip \(stream.ip)")
                        Text("Pan \(stream.pan.hex)")
                        Text("Streaming \(stream.isStreaming ? "Y" : "N")")
                    }
                    .foregroundColor(.purple)
                }
            }
            if showButtons && handle == Api.sharedInstance.connectionHandle {
                HStack(alignment: .center, spacing: 40) {
                    Button("RemoteRxAudio") { radio.requestRemoteRxAudioStream() }
                    Button("RemoteTxAudio") { radio.requestRemoteTxAudioStream() }
                    Button("DaxMicAudio") { radio.requestDaxMicAudioStream() }
                    Button("DaxRxAudio") { radio.requestDaxRxAudioStream("1") }
                    Button("DaxTxAudio") { radio.requestDaxTxAudioStream() }
                    Button("DaxIq") { radio.requestDaxIqStream("1") }
                }
            }
        }
        .padding(.leading, 20)
    }
}

// ----------------------------------------------------------------------------

struct TnfView: View {
    @ObservedObject var radio: Radio

    var body: some View {
        let tnfs = Array(radio.tnfs.values)

        ForEach(tnfs, id: \.id) { tnf in
            HStack(spacing: 20) {
                Text("Tnf").frame(width: 100, alignment: .trailing)
                Text(tnf.id.hex)
                Text("Frequency \(tnf.frequency)")
                Text("Width \(tnf.width)")
                Text("Depth \(tnf.depth)")
                Text("Permanent \(tnf.permanent ? "Y" : "N")")
            }
        }
    }
}

// ----------------------------------------------------------------------------

struct TransmitView: View {
    @ObservedObject var radio: Radio
    let handle: Handle

    var body: some View {
        let transmit = radio.transmit!
        let width: CGFloat = 80

        VStack {
            HStack(spacing: 20) {
                Text("Transmit").frame(width: 100, alignment: .trailing)
                Text("RF Power \(transmit.rfPower)")
                Text("Tune Power \(transmit.tunePower)")
                Text("Frequency \(transmit.frequency)")
                Text("Mon Level \(transmit.txMonitorGainSb)")
                Text("Comp Level \(transmit.companderLevel)")
                Text("Mic \(transmit.micSelection)")
                Text("Mic Level \(transmit.micLevel)")
                Text("Vox Delay \(transmit.voxDelay)")
                Text("Vox Level \(transmit.voxLevel)")
            }
            HStack(spacing: 60) {
                VStack {
                    Text("Proc \(transmit.speechProcessorEnabled ? "ON" : "OFF")")
                        .foregroundColor(transmit.speechProcessorEnabled ? .green : .red)
                        .frame(width: width, alignment: .center)
                    if handle == Api.sharedInstance.connectionHandle {
                        Button(action: { transmit.speechProcessorEnabled.toggle() }
                        ) { Text("PROC").frame(width: width) }
                    }
                }
                VStack {
                    Text("Mon \(transmit.txMonitorEnabled ? "ON" : "OFF")")
                        .foregroundColor(transmit.txMonitorEnabled ? .green : .red)
                        .frame(width: width, alignment: .center)
                    if handle == Api.sharedInstance.connectionHandle {
                        Button(action: { transmit.txMonitorEnabled.toggle() }
                        ) { Text("MON").frame(width: width) }
                    }
                }
                VStack {
                    Text("Acc \(transmit.micAccEnabled ? "ON" : "OFF")")
                        .foregroundColor(transmit.micAccEnabled ? .green : .red)
                        .frame(width: width, alignment: .center)
                    if handle == Api.sharedInstance.connectionHandle {
                        Button(action: { transmit.micAccEnabled.toggle() }
                        ) { Text("+ACC").frame(width: width) }
                    }
                }
                VStack {
                    Text("Comp \(transmit.companderEnabled ? "ON" : "OFF")")
                        .foregroundColor(transmit.companderEnabled ? .green : .red)
                        .frame(width: width, alignment: .center)
                    if handle == Api.sharedInstance.connectionHandle {
                        Button(action: { transmit.companderEnabled.toggle() }
                        ) { Text("COMP").frame(width: width) }
                    }
                }
                VStack {
                    Text("Dax \(transmit.daxEnabled ? "ON" : "OFF")")
                        .foregroundColor(transmit.daxEnabled ? .green : .red)
                        .frame(width: width, alignment: .center)
                    if handle == Api.sharedInstance.connectionHandle {
                        Button(action: { transmit.daxEnabled.toggle() }
                        ) { Text("DAX").frame(width: width) }
                    }
                }
                VStack {
                    Text("Vox \(transmit.voxEnabled ? "ON" : "OFF")")
                        .foregroundColor(transmit.voxEnabled ? .green : .red)
                        .frame(width: width, alignment: .center)
                    if handle == Api.sharedInstance.connectionHandle {
                        Button(action: { transmit.voxEnabled.toggle() }
                        ) { Text("VOX").frame(width: width) }
                    }
                }
            }
        }
    }
}

// ----------------------------------------------------------------------------

struct WaveformView: View {
    @ObservedObject var radio: Radio

    var body: some View {
//        let waveform = radio.waveform!

        HStack(spacing: 20) {
            Text("WAVEFORMs -> ").frame(width: 140, alignment: .leading)
            Text("WAVEFORMs NOT IMPLEMENTED")
        }
    }
}

// ----------------------------------------------------------------------------

struct XvtrView: View {
    @ObservedObject var radio: Radio

    var body: some View {
//        let xvtrs = radio.xvtrs

        HStack(spacing: 20) {
            Text("XVTR -> ").frame(width: 140, alignment: .leading)
            Text("XVTR NOT IMPLEMENTED")
        }
    }
}
