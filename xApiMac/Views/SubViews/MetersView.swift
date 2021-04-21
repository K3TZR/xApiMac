//
//  MetersView.swift
//  xApiMac
//
//  Created by Douglas Adams on 3/29/21.
//

import SwiftUI
import xClient6001

struct MetersView: View {
    @EnvironmentObject var meterManager: MeterManager

    var body: some View {
        VStack(alignment: .leading) {
            MetersHeaderView()
                .environmentObject(meterManager)
            MetersListHeadingView()
            MetersListView()
                .environmentObject(meterManager)
        }
        .padding()
    }
}

struct MetersView_Previews: PreviewProvider {
    static var previews: some View {
        MetersView()
            .environmentObject(MeterManager())

    }
}

struct MetersHeaderView: View {
    @EnvironmentObject var meterManager: MeterManager

    var body: some View {
        VStack(spacing: 20) {
            Text("NOTE: Meter display is being refreshed once a second, actual data rate may be faster or slower").foregroundColor(.red)
            FilterView(selection: $meterManager.filterSelection,
                       text: $meterManager.filterText,
                       choices: MeterManager.MeterFilter.allCases.map {$0.rawValue},
                       message: "Filter Meters by",
                       showText: true)
        }
    }
}

struct MetersListHeadingView: View {
    var body: some View {

        let width: CGFloat = 70

        VStack(alignment: .leading) {
            Divider()
            HStack(spacing: 30) {
                Text("Id").frame(width: 30)
                Text("Source").frame(width: width)
                Text("Group").frame(width: width)
                Text("Name").frame(width: 100, alignment: .leading)
                Text("Value").frame(width: width, alignment: .trailing)
                Text("Units").frame(width: width, alignment: .leading)
                Text("Low").frame(width: width, alignment: .trailing)
                Text("High").frame(width: width, alignment: .trailing)
                Text("FPS").frame(width: width, alignment: .trailing)
                Text("Description").frame(width: 650, alignment: .leading)
            }.padding(.horizontal, 15)
            Divider()
        }
    }
}

struct MetersListView: View {
    @EnvironmentObject var meterManager: MeterManager
    @State var meterSelection: UInt16?

    func valueColor(_ value: Float, _ low: Float, _ high: Float) -> Color {
        if value > high { return .red }
        if value < low { return .yellow }
        return .green
    }

    var body: some View {

        let width: CGFloat = 70

        VStack(alignment: .leading) {
            List(meterManager.filteredMeters, id: \.id, selection: $meterSelection) { meter in
                HStack(spacing: 30) {
                    Text(String(meter.id)).frame(width: 30)
                    Text(meter.source).frame(width: width)
                    Text(meter.group).frame(width: width)
                    Text(meter.name).frame(width: 100, alignment: .leading)
                    Text( String(format: "%3.2f", meter.value) )
                        .foregroundColor(valueColor(meter.value, meter.low, meter.high))
                        .frame(width: width, alignment: .trailing)
                    Text(meter.units).frame(width: width, alignment: .leading)
                    Text(String(meter.low)).frame(width: width, alignment: .trailing)
                    Text(String(meter.high)).frame(width: width, alignment: .trailing)
                    Text(String(meter.fps)).frame(width: width, alignment: .trailing)
                    Text(meter.desc).frame(width: 650, alignment: .leading)
                }
            }
        }
    }
}
