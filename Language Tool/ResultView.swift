//
//  ResultView.swift
//  Language Tool
//
//  Created by Raysharp666 on 2019/12/18.
//  Copyright © 2019 LyongY. All rights reserved.
//

import SwiftUI

struct ResultView: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color(.black).opacity(0.8))
            VStack(spacing: 30) {
                Text(self.userData.result)
                
                Button(action: {
                    self.userData.result = ""
                }) {
                    Text("OK")
                }
            }
        }
        .transition(.asymmetric(insertion: .identity, removal: .opacity))
        .animation(.linear(duration: 0.3))
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView().environmentObject(UserData())
    }
}
