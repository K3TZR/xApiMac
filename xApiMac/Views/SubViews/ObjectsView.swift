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
    @ObservedObject var radio: Radio
    let filter: String
    let fontSize: Int

    var body: some View {

        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading) {
                RadioView(radio: radio)
                if filter != "otherMeters" && filter != "allMeters" { MeterView(radio: radio, sliceId: nil) }
                ClientView(radio: radio, filter: filter)
            }
            .frame(minWidth: 920, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity, alignment: .leading)
            .font(.system(size: CGFloat(fontSize), weight: .regular, design: .monospaced))
        }
    }
}

 struct ObjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectsView(radio: Radio(DiscoveryPacket()), filter: "none", fontSize: 12)
    }
 }

struct RadioView: View {
    @ObservedObject var radio: Radio

    var body: some View {
        HStack(spacing: 20) {
            Text(radio.nickname)
            Text(radio.packet.model)
            Text(radio.packet.status)
            Text(radio.packet.isWan ? "Smartlink" : "Local")
            Text(radio.packet.publicIp)
            Text(radio.serialNumber)
            Text(radio.packet.firmwareVersion)
            Text("Atu=\(radio.atuPresent ? "Y" : "N")")
            Text("Gps=\(radio.gpsPresent ? "Y" : "N")")
            Text("Scu=\(radio.numberOfScus)")
        }.foregroundColor(Color(.systemGreen))
    }
}

struct ClientView: View {
    @ObservedObject var radio: Radio
    let filter: String

    var body: some View {

        let guiClients = radio.guiClients

        ForEach(guiClients, id: \.id) { guiClient in
            Divider().foregroundColor(Color(.systemRed))
            HStack(spacing: 20) {
                Text("Gui Client -> ")
                Text("Station \(guiClient.station)").frame(width: 120)
                Text("Handle \(guiClient.handle.hex)")
                Text("ClientId \(guiClient.clientId ?? "Unknown")")
                Text("LocalPtt \(guiClient.isLocalPtt ? "Y" : "N")")
                Text("Program \(guiClient.program)")
            }
            if filter != "streams" { StreamView(radio: radio, handle: guiClient.handle) }
            PanadapterView(radio: radio, handle: guiClient.handle, filter: filter)
        }
    }
}

struct PanadapterView: View {
    @ObservedObject var radio: Radio
    let handle: Handle
    let filter: String

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
                if filter != "slices" { SliceView(radio: radio, panadapterId: panadapter.id, filter: filter) }
            }
        }
    }
}

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

struct SliceView: View {
    @ObservedObject var radio: Radio
    let panadapterId: PanadapterStreamId
    let filter: String

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
                if filter != "sliceMeters" && filter != "allMeters" { MeterView(radio: radio, sliceId: slice.id) }
            }
        }
    }
}

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

    var pad: CGFloat {sliceId == nil ? 20 : 120}

    var body: some View {
        HStack(spacing: 20) {
            if show(meter) {
                Text("Meter").frame(width: 50, alignment: .leading).padding(.leading, pad)
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

struct StreamView: View {
    @ObservedObject var radio: Radio
    let handle: Handle

    var body: some View {
        let remRx = Array(radio.remoteRxAudioStreams.values)
        let remTx = Array(radio.remoteTxAudioStreams.values)
        let mics = Array(radio.daxMicAudioStreams.values)
        let rxs = Array(radio.daxRxAudioStreams.values)
        let txs = Array(radio.daxTxAudioStreams.values)
        let iqs = Array(radio.daxIqStreams.values)

        VStack(alignment: .leading) {
            ForEach(remRx) { stream in
                if handle == stream.clientHandle {
                    HStack(spacing: 20) {
                        Text("RemoteRxAudioStream")
                        Text(stream.id.hex)
                        Text("Handle \(stream.clientHandle.hex)")
                        Text("Compression \(stream.compression)")
                        Text("Ip \(stream.ip)")
                        Text("Streaming \(stream.isStreaming ? "Y" : "N")")
                    }
                }
            }
            ForEach(remTx) { stream in
                if handle == stream.clientHandle {
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
                if handle == stream.clientHandle {
                    HStack(spacing: 20) {
                        Text("DaxMicAudioStream")
                        Text(stream.id.hex)
                        Text("Handle \(stream.clientHandle.hex)")
                        Text("Ip \(stream.ip)")
                    }
                }
            }
            ForEach(rxs) { stream in
                if handle == stream.clientHandle {
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
                if handle == stream.clientHandle {
                    HStack(spacing: 20) {
                        Text("DaxTxAudioStream")
                        Text("Id=\(stream.id.hex)")
                        Text("Handle=\(stream.clientHandle.hex)")
                        Text("Transmit=\(stream.isTransmitChannel ? "Y" : "N")")
                    }
                }
            }
            ForEach(iqs) { stream in
                if handle == stream.clientHandle {
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
        .padding(.leading, 20)
        .foregroundColor(.purple)
    }
}
