//
//  BottomButtonsView.swift
//  xApiMac
//
//  Created by Douglas Adams on 7/28/20.
//  Copyright © 2020 Douglas Adams. All rights reserved.
//

import SwiftUI

struct BottomButtonsView: View {
    @EnvironmentObject var tester : Tester
    @EnvironmentObject var appDelegate : AppDelegate
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0, content: {
            
            HStack (spacing: 30){
                Stepper("Font Size", value: $tester.fontSize, in: 8...24).frame(width: 175)

                Toggle("Clear on Connect", isOn: $tester.clearAtConnect)
                Toggle("Clear on Disconnect", isOn: $tester.clearAtDisconnect)
                
                Spacer()
                
                Button( action: {appDelegate.showLogWindow.toggle()}) {Text("Open/Close Log Window")}
                
                Spacer()
                
                Button(action: {self.tester.clearObjectsAndMessages()}) {Text("Clear Now")}
            }
        })
    }
}

struct BottomButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        BottomButtonsView()
            .environmentObject(Tester())
            .environmentObject(AppDelegate())
    }
}
