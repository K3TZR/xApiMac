//
//  ObjectsViewNew.swift
//  xApiMac
//
//  Created by Douglas Adams on 4/13/21.
//

import SwiftUI
import xClient6001
import xLib6001

struct ObjectsViewNew: View {
    @ObservedObject var radioManager: RadioManager
    let fontSize: Int

    var body: some View {
        if radioManager.isConnected {
            VStack(alignment: .leading) {
                RadioView(radioManager: radioManager)
                Divider()
                ClientView(radioManager: radioManager)
                PanadapterView(radioManager: radioManager)
            }
            .font(.system(size: CGFloat(fontSize), weight: .regular, design: .monospaced))
            .padding()

        } else {
            EmptyView()
        }
    }
}

struct ObjectsViewNew_Previews: PreviewProvider {
    static var previews: some View {
        ObjectsViewNew(radioManager: RadioManager(delegate: Tester() as RadioManagerDelegate), fontSize: 12)
    }
}

struct RadioView: View {
    @ObservedObject var radioManager: RadioManager

    var body: some View {

        let radio = radioManager.activeRadio
        if radio == nil {
            EmptyView()

        } else {
            HStack {
                Text("Radio -> ")
                Text(radio!.packet.isWan ? "Smartlink" : "Local")
                Text(radio!.packet.publicIp)
                Text(radio!.nickname)
                Text(radio!.packet.model)
                Text(radio!.serialNumber)
                Text(radio!.packet.firmwareVersion)
                Text("Atu=\(radio!.atuPresent ? "Y" : "N")")
                Text("Gps=\(radio!.gpsPresent ? "Y" : "N")")
                Text("Scu=\(radio!.numberOfScus)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color(.textColor))
        }
    }
}

struct ClientView: View {
    @ObservedObject var radioManager: RadioManager

    var body: some View {

        let radio = radioManager.activeRadio
        if radio == nil {
            EmptyView()
        } else {
            ForEach(radio!.packet.guiClients, id: \.handle) { guiClient in
                HStack {
                    Text("Gui Client -> ")
                    Text("Station=\(guiClient.station)")
                    Text("Handle=\(guiClient.handle.hex)")
                    Text("Client Id=\(guiClient.clientId ?? "Unknown")")
                    Text("LocalPtt=\(guiClient.isLocalPtt ? "Y" : "N")")
                    Text("Status=\(radio!.packet.status)")
                    Text("Program=\(guiClient.program)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.green)
        }
    }
}

struct PanadapterView: View {
    @ObservedObject var radioManager: RadioManager

    @State var handle: UInt32 = 0x40000002
    @State var id: UInt32 = 0x40000001
    @State var center = 14_250_000
    @State var bandwidth = 200_000

    var body: some View {

        let radio = radioManager.activeRadio
        let pan = radio?.panadapters.first?.value

        if radio == nil || pan == nil {
            EmptyView()

        } else {
            VStack(alignment: .leading) {
                HStack {
                    Text("Panadapter").padding(.leading, 60)
                    Text("Id=\(pan!.id.hex)")
                    Text("Center=\(pan!.center)")
                    Text("Bandwidth=\(pan!.bandwidth)")
                }
                WaterfallView(radioManager: radioManager)
                SliceView(radioManager: radioManager)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.green)
        }
    }
}

struct WaterfallView: View {
    @ObservedObject var radioManager: RadioManager

//    @State var id: UInt32 = 0x40000008
//    @State var autoBlackEnabled = false
//    @State var colorGain = 34
//    @State var blackLevel = 19
//    @State var duration = 55

    var body: some View {

        let radio = radioManager.activeRadio
        let water = radio?.waterfalls.first?.value

        if radio == nil || water == nil {
            EmptyView()

        } else {
            HStack {
                Text("Waterfall").padding(.leading, 60)
                Text("Id=\(water!.id.hex)")
                Text("AutoBlack=\(water!.autoBlackEnabled ? "Y" : "N")")
                Text("ColorGain=\(water!.colorGain)")
                Text("BlackLevel=\(water!.blackLevel)")
                Text("Duration=\(water!.lineDuration)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.green)
        }
    }
}

struct SliceView: View {
    @ObservedObject var radioManager: RadioManager

//    @State var id: UInt32 = 0x40000008
//    @State var frequency = 14_275_000
//    @State var mode = "USB"
//    @State var filterLow = 14_275_100
//    @State var filterHigh = 14_277_100
//    @State var active = true
//    @State var locked = false

    var body: some View {

        let radio = radioManager.activeRadio
        let slice = radio?.slices.first?.value

        if radio == nil || slice == nil {
            EmptyView()

        } else {
            HStack {
                Text("Slice").padding(.leading, 60)
                Text("Id=\(slice!.id.hex)")
                Text("Frequency=\(slice!.frequency)")
                Text("Mode=\(slice!.mode)")
                Text("FilterLow=\(slice!.filterLow)")
                Text("FilterHigh=\(slice!.filterHigh)")
                Text("Active=\(slice!.active ? "Y" : "N")")
                Text("Locked=\(slice!.locked ? "Y" : "N")")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.green)
        }
    }
}

/*
 */

public extension UInt32 {
    var hex: String { return String(format: "0x%08X", self) }
}
