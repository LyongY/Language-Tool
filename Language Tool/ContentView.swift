//
//  ContentView.swift
//  Language Tool
//
//  Created by Raysharp666 on 2019/11/9.
//  Copyright © 2019 LyongY. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userData: UserData
    var body: some View {
        
        GeometryReader { geometry in
            HStack {
                List {
                    ForEach(self.userData.data, id: \.id) { toolType in
                        ToolTypeView(toolType: toolType)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(minWidth: 200, maxWidth: 200)
                
                GeometryReader { rightGeometry in
                    VStack {
                        
                        ForEach(self.userData.selected!.array, id: \.id) { dragableModel in
                            DragableView(dragableModel: dragableModel)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        Button(action: {
                            Convert.convert(with: self.userData)
                        }) {
                            Text("Start")
                                .frame(width: rightGeometry.size.width)
                        }
                        .frame(width: rightGeometry.size.width)
                        
                    }
                    .frame(maxHeight: .infinity)
                    .clipped()
                }
            }
            .padding()
            
            if self.userData.waitting {
                WaittingView()
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
            }
        }
        .frame(minWidth: 450, minHeight: 300)

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
