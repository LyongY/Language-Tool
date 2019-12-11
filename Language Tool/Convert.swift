//
//  Convert.swift
//  Language Tool
//
//  Created by Raysharp666 on 2019/11/11.
//  Copyright © 2019 LyongY. All rights reserved.
//

import Foundation


class Convert: NSObject {
    var userData: UserData
        
    init(_ userData: UserData) {
        self.userData = userData
        super.init()
    }
    
    static func convert(with userdata: UserData) {
        switch userdata.selectedTitle {
        case "XML 转 String":
            XmlToString(userdata).start()
        case "Excel 更新 Excel":
            XlsxUpdateXlsx(userdata).start()
        case "Excel 转 String":
            XlsxToString(userdata).start()
        case "Excel 转 XML":
            XlsxToXml(userdata).start()
        case "1024.png 生成各尺寸icon":
            CreatApplicationIcon(userdata).start()
        default:
            return
        }
    }
    
}

class XmlToString: Convert, XMLParserDelegate {
    var xmlkey: String?
    var xmlvalue: String?
    var sourcePath: String = "/"
    var targetPath: String = "/"

    func start() {
        sourcePath = self.userData.selected!.array[0].path
        targetPath = self.userData.selected!.array[1].path
        targetPath += "/Localizable.strings"

        if FileManager.default.fileExists(atPath: targetPath) {
            try! FileManager.default.removeItem(atPath: targetPath)
            
        }
        if FileManager.default.createFile(atPath: targetPath, contents: nil)  {
            let parser = XMLParser(contentsOf: URL(fileURLWithPath: sourcePath))
            parser?.delegate = self
            parser?.parse()
        } else {
            print("error")
        }

    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        xmlkey = attributeDict["name"]
        guard elementName == "string" && xmlkey?.count != 0 else {
            xmlkey = nil
            return
        }
        if  xmlkey == "IDS_PRIVACY_POLICY" ||
            xmlkey == "IDS_PASSWORD_RULES_CONTENT" {
            xmlkey = nil
            return
        }
        let handle = FileHandle(forWritingAtPath: targetPath)
        handle?.seekToEndOfFile()
        handle?.write("\"".data(using: .utf8)!)
        handle?.write(xmlkey!.data(using: .utf8)!)
        handle?.write("\" = \"".data(using: .utf8)!)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard xmlkey != nil else {
            return
        }
        let handle = FileHandle(forWritingAtPath: targetPath)
        handle?.seekToEndOfFile()
        handle?.write(string.data(using: .utf8)!)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard xmlkey != nil else {
            return
        }
        let handle = FileHandle(forWritingAtPath: targetPath)
        handle?.seekToEndOfFile()
        handle?.write("\";\n".data(using: .utf8)!)
        xmlkey = nil
    }


}

class XlsxUpdateXlsx: Convert {
    var sourcePath: String = "/"
    var updatePath: String = "/"
    var targetPath: String = "/"

    func start() {
        sourcePath = self.userData.selected!.array[0].path
        updatePath = self.userData.selected!.array[1].path
        targetPath = self.userData.selected!.array[2].path + "/更新后的文件.xlsx"
        assert(!FileManager.default.fileExists(atPath: targetPath), "已存在文件, 请更换文件夹")
        
        print(Date())

        updatePath = "/Users/yly/Documents/Programs/SVNPrograms/Resources/Language/中性/中性语言.xlsx"
        let sourcebook = XLWorkbook(path: sourcePath)
        let updatebook = XLWorkbook(path: updatePath)
        let targetbook = XLWorkbook(path: targetPath)

        print(Date())

        let sourcesheet = sourcebook.sheet(with: 0)
        let updatesheet = updatebook.sheet(with: 0)
        let targetsheet = targetbook.sheet(with: 0)

        let cols = updatesheet.colNum()
        let rows = updatesheet.rowNum()
        print(Date())
        for col in 1...cols {
            for row in 1...rows {
                autoreleasepool {
//                    let str = targetsheet.cell(withCol: col, row: row)
                    targetsheet.cell(withCol: col, row: row).stringValue = updatesheet.cell(withCol: col, row: row).stringValue
                }
            }
        }
        print(Date())


    }
}


class XlsxToString: Convert {
    var sourcePath: String = "/"
    var targetPath: String = "/"
    
    func start() {
        sourcePath = self.userData.selected!.array[0].path
        targetPath = self.userData.selected!.array[1].path

        let sourcebook = XLWorkbook(path: sourcePath)
        let sourcesheet = sourcebook.sheet(with: 0)

        let cols = sourcesheet.colNum()
        let rows = sourcesheet.rowNum()
        for col in 2...cols {
            let filePath = targetPath + "/\(sourcesheet.cell(withCol: col, row: 1).stringValue).lproj/Localizable.strings"
            if !recreateFile(path: filePath) {
                continue
            }
            let handle = FileHandle(forWritingAtPath: filePath)
            handle?.seekToEndOfFile()
            for row in 2...rows {
                let key = sourcesheet.cell(withCol: UInt32(1), row: row).stringValue
                let value = sourcesheet.cell(withCol: col, row: row).stringValue
                if key == "IDS_PASSWORD_RULES_CONTENT" {
                    continue
                }
                handle?.write("\"".data(using: .utf8)!)
                handle?.write(key.data(using: .utf8)!)
                handle?.write("\" = \"".data(using: .utf8)!)
                handle?.write(value.data(using: .utf8)!)
                handle?.write("\";\n".data(using: .utf8)!)
            }
        }

    }
}


class XlsxToXml: Convert {
    var sourcePath: String = "/"
    var targetPath: String = "/"
    
    func start() {
        sourcePath = self.userData.selected!.array[0].path
        targetPath = self.userData.selected!.array[1].path

        let sourcebook = XLWorkbook(path: sourcePath)
        let sourcesheet = sourcebook.sheet(with: 0)
        
        let cols = sourcesheet.colNum()
        let rows = sourcesheet.rowNum()
        
        for col in 2...cols {
            let filePath = targetPath + "/XML/\(sourcesheet.cell(withCol: col, row: 1).stringValue).xml"
            if !recreateFile(path: filePath) {
                continue
            }
            let handle = FileHandle(forWritingAtPath: filePath)
            handle?.seekToEndOfFile()
            handle?.write("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n".data(using: .utf8)!)
            handle?.write("<resources>\n".data(using: .utf8)!)
            for row in 2...rows {
                let key = sourcesheet.cell(withCol: UInt32(1), row: row).stringValue
                var value = sourcesheet.cell(withCol: col, row: row).stringValue
                value = value.replacingOccurrences(of: "&", with: "&amp;")
                handle?.write("    <string name=\"\(key)\">\(value)</string>\n".data(using: .utf8)!)
            }
            handle?.write("</resources>".data(using: .utf8)!)
        }
    }
}

class CreatApplicationIcon: Convert {
    var sourcePath: String = "/"
    var targetPath: String = "/"
    
    func start() {
        sourcePath = self.userData.selected!.array[0].path
        targetPath = self.userData.selected!.array[1].path
        
        enum IdiomType: String {
            case iphone = "iphone"
            case ipad = "ipad"
            case ios_marketing = "ios-marketing"
        }
        
        let imageArr = [
            (size:20, idiom:IdiomType.iphone, scale:2),
            (size:20, idiom:IdiomType.iphone, scale:3),
            (size:29, idiom:IdiomType.iphone, scale:2),
            (size:29, idiom:IdiomType.iphone, scale:3),
            (size:40, idiom:IdiomType.iphone, scale:2),
            (size:40, idiom:IdiomType.iphone, scale:3),
            (size:60, idiom:IdiomType.iphone, scale:2),
            (size:60, idiom:IdiomType.iphone, scale:3),
            (size:20, idiom:IdiomType.ipad, scale:1),
            (size:20, idiom:IdiomType.ipad, scale:2),
            (size:29, idiom:IdiomType.ipad, scale:1),
            (size:29, idiom:IdiomType.ipad, scale:2),
            (size:40, idiom:IdiomType.ipad, scale:1),
            (size:40, idiom:IdiomType.ipad, scale:2),
            (size:76, idiom:IdiomType.ipad, scale:1),
            (size:76, idiom:IdiomType.ipad, scale:2),
            (size:83.5, idiom:IdiomType.ipad, scale:2),
            (size:1024, idiom:IdiomType.ios_marketing, scale:1),
        ]
        let sourceImage = NSImage(contentsOfFile: sourcePath)
        
        let directoryPath = targetPath
        if !FileManager.default.fileExists(atPath: directoryPath) {
            try! FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        }
        for tuple in imageArr {
            let newSize = NSSize(width: Int(tuple.size * Double(tuple.scale)), height: Int(tuple.size * Double(tuple.scale)))
            let newImage = NSImage(size: newSize)

            let sourceRep = sourceImage?.bestRepresentation(for: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), context: nil, hints: nil)

            newImage.lockFocus()
            sourceRep?.draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            newImage.unlockFocus()
  
            let cgRef = newImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
            let newRep = NSBitmapImageRep(cgImage: cgRef!)
            newRep.size = newImage.size
            let pngData = newRep.representation(using: .png, properties: [:])
            
            let path = directoryPath + "/\(Int(tuple.size * Double(tuple.scale))).png"
            try! pngData?.write(to: URL(fileURLWithPath: path), options: .atomic)
        }
        
        let imageInfoArr = imageArr.map { (x) -> Dictionary<String, String> in
            let dic = [
                "size": String(format: "%gx%g", x.size, x.size),
                "idiom": x.idiom.rawValue,
                "filename": "\(Int(x.size * Double(x.scale))).png",
                "scale": "\(x.scale)x"
            ]
            return dic
        }
        
        let json:[String: Any] = [
            "images": imageInfoArr,
            "info": [
                "version": 1,
                "author": "xcode"
            ]
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        try! jsonData.write(to: URL(fileURLWithPath: directoryPath + "/Contents.json"), options: .atomic)
    }
}

func recreateFile(path: String) -> Bool {
    if FileManager.default.fileExists(atPath: path) {
        try! FileManager.default.removeItem(atPath: path)
    }
    
    var arr = path.split(separator: "/")
    arr.removeLast()
    let directoryPath = "/" + arr.joined(separator: "/")
    if !FileManager.default.fileExists(atPath: directoryPath) {
        try! FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
    }
    if FileManager.default.createFile(atPath: path, contents: nil)  {
        return true
    } else {
        print("error")
        return false
    }

}
