//
//  ToolTypeView.swift
//  Language Tool
//
//  Created by Raysharp666 on 2019/11/11.
//  Copyright © 2019 LyongY. All rights reserved.
//

import SwiftUI

struct ToolTypeView: View {
    
    @EnvironmentObject var userData: UserData
    
    var toolType: ToolType
    
    var body: some View {
        HStack {
            Text(toolType.title)
                .foregroundColor(self.userData.selectedTitle == self.toolType.title ? Color.red: Color.white)
            Spacer()
        }
            .onTapGesture {
                if self.userData.waitting {
                    return
                }
                self.userData.selectedTitle = self.toolType.title
        }

    }
}

struct ToolTypeView_Previews: PreviewProvider {
    static var previews: some View {
        ToolTypeView(toolType: ToolType(title: "ToolTypeView", array: [])).environmentObject(UserData())
    }
}
