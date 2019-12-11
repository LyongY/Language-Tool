//
//  WaittingView.swift
//  Language Tool
//
//  Created by Raysharp666 on 2019/11/12.
//  Copyright © 2019 LyongY. All rights reserved.
//

import SwiftUI

struct WaittingView: View {
    @EnvironmentObject var userData: UserData

    var body: some View {
        VStack(alignment: .center, spacing: 50) {
            Spacer()
            WaittingHud()
            if self.userData.process > 0 {
                WaittingProcess()
            }
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.8))

    }
}

struct WaittingView_Previews: PreviewProvider {
    static var previews: some View {
        WaittingView().environmentObject(UserData())
    }
}

struct WaittingHud: NSViewRepresentable {
        
    func makeNSView(context: NSViewRepresentableContext<WaittingHud>) -> NSView {
        let hud = NSProgressIndicator()
        hud.style = .spinning
        hud.controlSize = .regular
        hud.startAnimation(nil)
        return hud
    }
    
    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<WaittingHud>) {

    }
}

struct WaittingProcess: NSViewRepresentable {
    
    @EnvironmentObject var userData: UserData
    var prosecc = 3

    func makeNSView(context: NSViewRepresentableContext<WaittingProcess>) -> NSView {
        let process = NSProgressIndicator()
        process.style = .bar
        process.isIndeterminate = false
        process.startAnimation(nil)
        process.isBezeled = true
        return process
    }
    
    func updateNSView(_ nsView: WaittingProcess.NSViewType, context: NSViewRepresentableContext<WaittingProcess>) {
        let process = nsView as! NSProgressIndicator
        process.maxValue = 100;
        process.minValue = 0;
        process.doubleValue = userData.process
    }
}
