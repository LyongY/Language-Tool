//
//  UserData.swift
//  Language Tool
//
//  Created by Raysharp666 on 2019/11/9.
//  Copyright © 2019 LyongY. All rights reserved.
//

import Cocoa
import Combine

struct ToolType {
    var id = UUID()
    var title: String
    var array: [DragableModel]
    
    func dragableModel(with id: UUID) -> DragableModel? {
        for dragableModel in self.array {
            if dragableModel.id == id {
                return dragableModel
            }
        }
        return nil
    }
}

class DragableModel: NSObject, ObservableObject {
    var id = UUID()
    var title: String
    var type: DragableModelType
    @Published var path: String
    
    enum DragableModelType {
        case file
        case directory
    }
    
    init(title: String, type: DragableModelType, path: String) {
        self.title = title
        self.type = type
        self.path = path
        super.init()
    }
}

class UserData: NSObject, ObservableObject {
    var data: [ToolType] =
        [
            ToolType(title: "XML 转 String", array: [
                DragableModel(title: "XML",
                              type: .file,
                              path: "/Users/yly/Documents/Programs/SVNPrograms/Resources/Language/SmartCam Lite/ENU.xml"),
                DragableModel(title: "输出目录",
                              type: .directory,
                              path: "/Users/yly/Documents/Programs/SVNPrograms/IOS/SmartCam Lite/SmartCam Lite/Launch/en.lproj"),
            ]),
            ToolType(title: "Excel 更新 Excel", array: [
                DragableModel(title: "以此文件为标准(客户给的)",
                              type: .file,
                              path: "/Users/yly/Desktop/test update excel/工作簿1.xlsx"),
                DragableModel(title: "更新到此文件上(中性的)",
                              type: .file,
                              path: "/Users/yly/Desktop/test update excel/中性语言.xlsx"),
                DragableModel(title: "输出目录",
                              type: .directory,
                              path: "/Users/yly/Desktop/test update excel"),
            ]),
            ToolType(title: "Excel 转 String", array: [
                DragableModel(title: "Excel",
                              type: .file,
                              path: "/Users/yly/Documents/Programs/SVNPrograms/Resources/Language/SmartCam Lite/SmartCam Lite Language.xlsx"),
                DragableModel(title: "输出目录",
                              type: .directory,
                              path: "/Users/yly/Documents/Programs/SVNPrograms/IOS/SmartCam Lite/SmartCam Lite/Launch"),
            ]),
            ToolType(title: "Excel 转 XML", array: [
                DragableModel(title: "Excel",
                              type: .file,
                              path: "/Users/yly/Desktop/xlsx to string/MENU-ENG-VERSION_1 - 副本.xlsx"),
                DragableModel(title: "输出目录",
                              type: .directory,
                              path: "/Users/yly/Desktop/xlsx to string"),
            ]),
            ToolType(title: "找出客户缺失语言", array: [
                DragableModel(title: "客户语言",
                              type: .file,
                              path: "/Users/yly/Desktop/test update excel/工作簿1.xlsx"),
                DragableModel(title: "中性语言",
                              type: .file,
                              path: "/Users/yly/Desktop/test update excel/工作簿2.xlsx"),
                DragableModel(title: "输出目录",
                              type: .directory,
                              path: "/Users/yly/Desktop/test update excel"),
            ]),
            ToolType(title: "CamView Plus语言", array: [
                DragableModel(title: "Excel",
                              type: .file,
                              path: "/Users/yly/Desktop/test update excel/工作簿1.xlsx"),
                DragableModel(title: "App语言文件夹",
                              type: .directory,
                              path: "/Users/yly/Desktop/test update excel"),
                DragableModel(title: "web语言文件夹",
                              type: .directory,
                              path: "/Users/yly/Desktop/test update excel"),
            ]),
            ToolType(title: "1024.png 生成各尺寸icon", array: [
                DragableModel(title: "拖入1024图片",
                              type: .file,
                              path: "/Users/yly/Desktop/image/1024.png"),
                DragableModel(title: "输出目录",
                              type: .directory,
                              path: "/Users/yly/Desktop/image"),
            ]),

    ]
    
    var selected: ToolType? {
        for toolType in data {
            if toolType.title == self.selectedTitle {
                return toolType
            }
        }
        return nil
    }
    
    @Published var selectedTitle = "Excel 转 String"

    @Published var waitting = false
    @Published var process = 0.0
    
    @Published var result = ""

}
