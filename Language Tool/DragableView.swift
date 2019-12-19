//
//  DragableView.swift
//  Language Tool
//
//  Created by Raysharp666 on 2019/11/11.
//  Copyright © 2019 LyongY. All rights reserved.
//

import SwiftUI

struct DragableView: View {
    
    @EnvironmentObject var userData: UserData
    @State var isDragIn: Bool = false
    @ObservedObject var dragableModel: DragableModel

    var animation: Animation? {
        var index = 0
        findIndex: for tooltype in userData.data {
            index = 0
            for dragableM in tooltype.array {
                if dragableM == self.dragableModel {
                    break findIndex
                }
                index += 1
            }
        }
        return Animation.spring(dampingFraction: 0.8).speed(1).delay(Double(index) * 0.1)
    }
        
    var transition: AnyTransition {
        let insertion = AnyTransition.offset(x: 0, y: -500).combined(with: .move(edge: .top)).animation(animation)
        let removalt = AnyTransition.offset(x: 500, y: 0).combined(with: .move(edge: .trailing)).animation(animation)
        return .asymmetric(insertion: insertion, removal: removalt)
    }
    
    var body: some View {
        
            ZStack {
                    DragableViewRepresentable(isDragIn: $isDragIn, dragableModel: dragableModel)
                        .overlay(Rectangle().stroke(isDragIn ? Color.blue : Color.gray, lineWidth: isDragIn ? 3 : 2))
                    VStack {
                        Text(dragableModel.title)
                        Text(dragableModel.type == .file ? "拖入文件" : "拖入文件夹")
                        Text(dragableModel.path)
                    }
                }
            .transition(transition)
            .animation(animation)

    }
}

struct DragableView_Previews: PreviewProvider {
    static var previews: some View {
        DragableView(dragableModel: DragableModel(title: "DragableView", type: .file, path: "/path"))
    }
}

struct DragableViewRepresentable: NSViewRepresentable {

    @Binding var isDragIn: Bool
    var dragableModel: DragableModel
    
    func makeNSView(context: NSViewRepresentableContext<DragableViewRepresentable>) -> NSView {
        let view = DragableViewContent(parent: self)
        view.registerForDraggedTypes([.fileContents, .fileURL])
        return view
    }

    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<DragableViewRepresentable>) {

    }
}

class DragableViewContent: NSView {
        
    var parent: DragableViewRepresentable
    
    init(parent: DragableViewRepresentable) {
        self.parent = parent
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pathStr(_ sender: NSDraggingInfo) -> String? {
        let pasteBoard = sender.draggingPasteboard
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options: nil), urls.count > 0 {
            let url = urls.first as! NSURL
            
            if let path = url.path {
                return path
            }
        }
        return nil
    }
    
    func isFile(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let isExist = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        if isExist && !isDirectory.boolValue {
            return true
        }
        return false
    }


    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let path = pathStr(sender) {
            if isFile(path) && self.parent.dragableModel.type == .file {
                self.parent.isDragIn = true
            }
            if !isFile(path) && self.parent.dragableModel.type == .directory {
                self.parent.isDragIn = true
            }
        }
        return .link
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.parent.isDragIn = false

    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        self.parent.isDragIn = false
        return true
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        self.parent.isDragIn = false

        if let path = pathStr(sender) {
            if isFile(path) && self.parent.dragableModel.type == .file {                            self.parent.dragableModel.path = path
            }
            if !isFile(path) && self.parent.dragableModel.type == .directory {
                self.parent.dragableModel.path = path
            }
            return true
        }
        return false
    }

}
