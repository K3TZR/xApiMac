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
    @ObservedObject var radioManager: RadioManager
    let filter: String
    let fontSize: Int

    var body: some View {

        let radio = radioManager.activeRadio
        if radio == nil {
            EmptyView()

        } else {
            ScrollView([.horizontal, .vertical]) {
                ScrollViewReader { scrollView in
                    VStack(alignment: .leading) {
                        RadioView(radio: radio!)
                        MeterView(radio: radio!, sliceId: nil, filter: filter)
                        ClientView(radio: radio!, filter: filter)
                    }.onAppear {
                        scrollView.scrollTo(0, anchor: .topLeading)
                    }
                }
            }
            .frame(minWidth: 920, maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .leading)
            .font(.system(size: CGFloat(fontSize), weight: .regular, design: .monospaced))
        }
    }
}

struct ObjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectsView(radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate), filter: "none", fontSize: 12)
    }
}

struct RadioView: View {
    @ObservedObject var radio: Radio

    var body: some View {
        HStack(spacing: 20) {
            Text("Radio -> ")
            Text(radio.packet.isWan ? "Smartlink" : "Local")
            Text(radio.packet.publicIp)
            Text(radio.nickname)
            Text(radio.packet.model)
            Text(radio.serialNumber)
            Text(radio.packet.firmwareVersion)
            Text("Atu=\(radio.atuPresent ? "Y" : "N")")
            Text("Gps=\(radio.gpsPresent ? "Y" : "N")")
            Text("Scu=\(radio.numberOfScus)")
        }.foregroundColor(Color(.textColor))
    }
}

struct ClientView: View {
    @ObservedObject var radio: Radio
    let filter: String

    var body: some View {
        ForEach(radio.packet.guiClients, id: \.handle) { guiClient in
            VStack(alignment: .leading) {
                Divider().background(Color(.systemGreen))
                HStack(spacing: 20) {
                    Text("Gui Client -> ")
                    Text("Station \(guiClient.station)")
                    Text("Handle \(guiClient.handle.hex)")
                    Text("ClientId \(guiClient.clientId ?? "Unknown")")
                    Text("LocalPtt \(guiClient.isLocalPtt ? "Y" : "N")")
                    Text("Status \(radio.packet.status)")
                    Text("Program \(guiClient.program)")
                }
                .foregroundColor(.green)

                if filter != "streams" { StreamView(radio: radio, clientHandle: guiClient.handle) }
                PanadapterView(radio: radio, guiClient: guiClient, filter: filter)
            }
        }
    }
}

struct PanadapterView: View {
    @ObservedObject var radio: Radio
    let guiClient: GuiClient
    let filter: String

    var body: some View {
        let panadapters = Array(radio.panadapters.values)

        ForEach(panadapters) { panadapter in
            if panadapter.clientHandle == guiClient.handle {
                VStack(alignment: .leading) {
                    HStack(spacing: 20) {
                        Text("Panadapter").frame(width: 100, alignment: .trailing)
                        Text(panadapter.id.hex)
                        Text("Center \(panadapter.center)")
                        Text("Bandwidth \(panadapter.bandwidth)")
                    }
                    WaterfallView(radio: radio, panadapter: panadapter)
                    SliceView(radio: radio, panadapter: panadapter, filter: filter)
                }
            }
        }
    }
}

struct WaterfallView: View {
    @ObservedObject var radio: Radio
    let panadapter: Panadapter

    var body: some View {
        let waterfalls = Array(radio.waterfalls.values)

        ForEach(waterfalls) { waterfall in
            if waterfall.panadapterId == panadapter.id {
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

struct SliceView: View {
    @ObservedObject var radio: Radio
    let panadapter: Panadapter
    let filter: String

    var body: some View {
        let slices = Array(radio.slices.values)

        ForEach(slices) { slice in
            if filter != "slices" && slice.panadapterId == panadapter.id {
                VStack(alignment: .leading) {
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
                    MeterView(radio: radio, sliceId: slice.id, filter: filter)
                }
            }
        }
    }
}

struct MeterView: View {
    @ObservedObject var radio: Radio
    let sliceId: ObjectId?
    let filter: String

    func valueColor(_ value: Float, _ low: Float, _ high: Float) -> Color {
        if value > high { return .red }
        if value < low { return .yellow }
        return .green
    }

    var body: some View {
        let meters = Array(radio.meters.values)

        VStack(alignment: .leading) {
            ForEach(meters) { meter in
                if filter != "allMeters" &&
                    ((filter != "sliceMeters" && sliceId != nil && meter.source == "slc" && meter.group == String(sliceId!)) || (filter != "otherMeters" && sliceId == nil && meter.source != "slc")) {
                    HStack(spacing: 20) {
                        Text("Meter").frame(width: 50, alignment: .leading).padding(.leading, sliceId == nil ? 20 : 100)
                        Text(String(format: "% 3d", meter.id)).frame(width: 50, alignment: .leading)
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
            }.foregroundColor(.secondary)
        }
    }
}

struct StreamView: View {
    @ObservedObject var radio: Radio
    let clientHandle: Handle

    var body: some View {
        let opus = Array(radio.opusAudioStreams.values)
        let remRx = Array(radio.remoteRxAudioStreams.values)
        let remTx = Array(radio.remoteTxAudioStreams.values)
        let mics = Array(radio.daxMicAudioStreams.values)
        let rxs = Array(radio.daxRxAudioStreams.values)
        let txs = Array(radio.daxTxAudioStreams.values)
        let iqs = Array(radio.daxIqStreams.values)

        VStack(alignment: .leading) {
            ForEach(opus) { stream in
                if clientHandle == stream.clientHandle {
                    HStack(spacing: 20) {
                        Text("OpusAudioStream")
                        Text(stream.id.hex)
                        Text("Handle \(stream.clientHandle.hex)")
                        Text("Ip \(stream.ip)")
                        Text("Streaming \(stream.isStreaming ? "Y" : "N")")
                        Text("Port \(stream.port)")
                        Text("Stopped \(stream.rxStopped ? "Y" : "N")")
                    }
                }
            }
            ForEach(remRx) { stream in
                if clientHandle == stream.clientHandle {
                    HStack(spacing: 20) {
                        Text("RemoteRxAudioStream")
                        Text(stream.id.hex)
                        Text("Handle \(stream.clientHandle.hex)")
                        Text("Compression \(stream.compression)")
                        Text("Streaming \(stream.isStreaming ? "Y" : "N")")
                    }
                }
            }
            ForEach(remTx) { stream in
                if clientHandle == stream.clientHandle {
                    HStack(spacing: 20) {
                        Text("RemoteTxAudioStream")
                        Text(stream.id.hex)
                        Text("Handle \(stream.clientHandle.hex)")
                        Text("Compression \(stream.compression)")
                        Text("Streaming \(stream.isStreaming ? "Y" : "N")")
                    }
                }
            }
            ForEach(mics) { stream in
                if clientHandle == stream.clientHandle {
                    HStack(spacing: 20) {
                        Text("DaxMicAudioStream")
                        Text(stream.id.hex)
                        Text("Handle \(stream.clientHandle.hex)")
                        Text("Ip \(stream.ip)")
                    }
                }
            }
            ForEach(rxs) { stream in
                if clientHandle == stream.clientHandle {
                    HStack(spacing: 20) {
                        Text("DaxRxAudioStream")
                        Text(stream.id.hex)
                        Text("Handle \(stream.clientHandle.hex)")
                        Text("Channel \(stream.daxChannel)")
                        Text("Ip \(stream.ip)")
                    }
                }
            }
            ForEach(txs) { stream in
                if clientHandle == stream.clientHandle {
                    HStack(spacing: 20) {
                        Text("DaxTxAudioStream")
                        Text("Id=\(stream.id.hex)")
                        Text("Handle=\(stream.clientHandle.hex)")
                        Text("Transmit=\(stream.isTransmitChannel ? "Y" : "N")")
                    }
                }
            }
            ForEach(iqs) { stream in
                if clientHandle == stream.clientHandle {
                    HStack(spacing: 20) {
                        Text("DaxTxAudioStream")
                        Text(stream.id.hex)
                        Text("Handle=\(stream.clientHandle.hex)")
                        Text("Channel \(stream.channel)")
                        Text("Ip \(stream.ip)")
                        Text("Pan \(stream.pan.hex)")
                        Text("Streaming \(stream.isStreaming ? "Y" : "N")")
                    }
                }
            }
        }
        .foregroundColor(.purple)
    }
}
