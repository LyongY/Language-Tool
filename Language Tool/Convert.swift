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
        if userdata.waitting {
            return
        }
        userdata.waitting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            switch userdata.selectedTitle {
            case "XML 转 String":
                XmlToString(userdata).start()
            case "Excel 更新 Excel":
                XlsxUpdateXlsx(userdata).start()
            case "Excel 转 String":
                XlsxToString(userdata).start()
            case "Excel 转 XML":
                XlsxToXml(userdata).start()
            case "找出客户缺失语言":
                XlsxFindMissingKey(userdata).start()
            case "CamView Plus语言":
                CamViewPlusConvert(userdata).start()
            case "1024.png 生成各尺寸icon":
                CreatApplicationIcon(userdata).start()
            default:
                return
            }
        }
    }
    
    func complete() {
        self.userData.waitting = false
        self.userData.result = "任务已完成"
    }
    
    func openExcelFailed(path: String) {
        self.userData.waitting = false
        self.userData.result = "打开 \(path) 失败"
    }
    
    func readData(worksheet: XLWorksheet) -> Array<(id: String, value: Array<(language: String, value: String)>)> {
        var data: Array<(id: String, value: Array<(language: String, value: String)>)> = []
        let cols = worksheet.colNum()
        let rows = worksheet.rowNum()
        for row in 2...rows {
            let key = worksheet.cell(withCol: 1, row: row).stringValue
            data.append((id: key, value: []))
            for col in 2...cols {
                let language = worksheet.cell(withCol: col, row: 1).stringValue
                let value = worksheet.cell(withCol: col, row: row).stringValue
                
                var valueArr = data[Int(row) - 2].value
                let languageTuple = (language: language, value: value)
                valueArr.append(languageTuple)
                
                data[Int(row) - 2].value = valueArr
            }
        }
        return data;
    }
    
    func writeDataToExcel(data: Array<(id: String, value: Array<(language: String, value: String)>)>, targetPath: String) {
        let targetbook = XLWorkbook()
        targetbook.path = targetPath
        let targetsheet = targetbook.sheet(with: 0)
        targetsheet.cell(withCol: 1, row: 1).stringValue = "KEY"
        let updateCols = data.first!.value.count
        for item in 0..<updateCols {
            let language = data.first!.value[item].language
            targetsheet.cell(withCol: UInt32(item) + 2, row: 1).stringValue = language
        }
        for row in 0..<data.count {
            let key = data[row].id
            targetsheet.cell(withCol: 1, row: UInt32(row) + 2).stringValue = key
            for iii in 0..<updateCols {
                let language = targetsheet.cell(withCol: UInt32(iii) + 2, row: 1).stringValue
                
                let xlsxCol = iii + 2
                let xlsxRow = row + 2
                for languageTouple in data[row].value {
                    if languageTouple.language == language {
                        targetsheet.cell(withCol: UInt32(xlsxCol), row: UInt32(xlsxRow)).stringValue = languageTouple.value
                        break
                    }
                }

            }
            
        }
        targetbook.save()
    }
    
    func writeDataToString(data: Array<(id: String, value: Array<(language: String, value: String)>)>, targetPath: String) {
        for i in 0..<data.first!.value.count {
            let language = data.first!.value[i].language
            
            let filePath = targetPath + "/\(language).lproj/Localizable.strings"
            if !recreateFile(path: filePath) {
                continue
            }
            let handle = FileHandle(forWritingAtPath: filePath)
            handle?.seekToEndOfFile()
            for row in 0..<data.count {
                var languageIndex = 0
                for j in 0..<data[row].value.count {
                    if data[row].value[j].language == language {
                        languageIndex = j
                    }
                }
                var value = data[row].value[languageIndex].value
                value = value.replacingOccurrences(of: "\"", with: "\\\"")
                let key = data[row].id

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
    
    func writeDataToXML(data: Array<(id: String, value: Array<(language: String, value: String)>)>, targetPath: String) {
        for i in 0..<data.first!.value.count {
            let language = data.first!.value[i].language

            let filePath = targetPath + "/\(language)/strings.xml"
            if !recreateFile(path: filePath) {
                continue
            }
            let handle = FileHandle(forWritingAtPath: filePath)
            handle?.seekToEndOfFile()
            handle?.write("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n".data(using: .utf8)!)
            handle?.write("<resources>\n".data(using: .utf8)!)
            for row in 0..<data.count {
                var languageIndex = 0
                for j in 0..<data[row].value.count {
                    if data[row].value[j].language == language {
                        languageIndex = j
                    }
                }
                var value = data[row].value[languageIndex].value
                let key = data[row].id

                value = value.replacingOccurrences(of: "&", with: "&amp;")
                handle?.write("    <string name=\"\(key)\">\(value)</string>\n".data(using: .utf8)!)
            }
            handle?.write("</resources>".data(using: .utf8)!)
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
        self.complete()
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
        let value = string.replacingOccurrences(of: "\"", with: "\\\"")
        let handle = FileHandle(forWritingAtPath: targetPath)
        handle?.seekToEndOfFile()
        handle?.write(value.data(using: .utf8)!)
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
        sourcePath = self.userData.selected!.array[0].path // 客户给的语言
        updatePath = self.userData.selected!.array[1].path // 中性的语言
        targetPath = self.userData.selected!.array[2].path + "/更新后的文件\(Date()).xlsx"
        assert(!FileManager.default.fileExists(atPath: targetPath), "已存在文件, 请更换文件夹")
        
        // 读取客户语言文件
        var sourceData: Array<(id: String, value: Array<(language: String, value: String)>)> = []
        guard let sourcebook = XLWorkbook(path: sourcePath) else {
            self.openExcelFailed(path: sourcePath)
            return
        }
        let sourcesheet = sourcebook.sheet(with: 0)
        sourceData = self.readData(worksheet: sourcesheet)
        
        // 读取中性语言文件
        var updateData: Array<(id: String, value: Array<(language: String, value: String)>)> = []
        guard let updatebook = XLWorkbook(path: updatePath) else {
            self.openExcelFailed(path: updatePath)
            return
        }
        let updatesheet = updatebook.sheet(with: 0)
        updateData = self.readData(worksheet: updatesheet)
        
        // 更新读取的数据
        for touple in sourceData {
            let key = touple.id
            for languageTouple in touple.value {
                let language = languageTouple.language
                let value = languageTouple.value
                
                for keyIndex in 0..<updateData.count {
                    let updateTouple = updateData[keyIndex]
                    let updateKey = updateTouple.id
                    if updateKey == key {
                        for languageIndex in 0..<updateTouple.value.count {
                            let updateLanguageTouple = updateData[keyIndex].value[languageIndex]
                            let updateLanguage = updateLanguageTouple.language
                            if updateLanguage == language {
                                updateData[keyIndex].value[languageIndex].value = value
                            }
                        }
                    }
                }
            }
        }
        
        // 写入新文件
        self.writeDataToExcel(data: updateData, targetPath: targetPath)
        self.complete()
    }
}


class XlsxToString: Convert {
    var sourcePath: String = "/"
    var targetPath: String = "/"
    
    func start() {
        sourcePath = self.userData.selected!.array[0].path
        targetPath = self.userData.selected!.array[1].path

        guard let sourcebook = XLWorkbook(path: sourcePath) else {
            self.openExcelFailed(path: sourcePath)
            return
        }
        let sourcesheet = sourcebook.sheet(with: 0)
        
        let data = self.readData(worksheet: sourcesheet)
        self.writeDataToString(data: data, targetPath: targetPath)
        self.complete()
    }
}


class XlsxToXml: Convert {
    var sourcePath: String = "/"
    var targetPath: String = "/"
    
    func start() {
        sourcePath = self.userData.selected!.array[0].path
        targetPath = self.userData.selected!.array[1].path

        guard let sourcebook = XLWorkbook(path: sourcePath) else {
            self.openExcelFailed(path: sourcePath)
            return
        }
        let sourcesheet = sourcebook.sheet(with: 0)
        
        let data = self.readData(worksheet: sourcesheet)
        self.writeDataToXML(data: data, targetPath: targetPath)
        self.complete()
    }
}

class XlsxFindMissingKey: Convert {
    var sourcePath: String = "/"
    var updatePath: String = "/"
    var targetPath: String = "/"
    
    func start() {
        sourcePath = self.userData.selected!.array[0].path // 客户给的语言
        updatePath = self.userData.selected!.array[1].path // 中性的语言
        targetPath = self.userData.selected!.array[2].path + "/查询结果\(Date()).xlsx"
        assert(!FileManager.default.fileExists(atPath: targetPath), "已存在文件, 请更换文件夹")
        
        // 读取客户语言文件
        var sourceData: Array<(id: String, value: Array<(language: String, value: String)>)> = []
        guard let sourcebook = XLWorkbook(path: sourcePath) else {
            self.openExcelFailed(path: sourcePath)
            return
        }
        let sourcesheet = sourcebook.sheet(with: 0)
        sourceData = self.readData(worksheet: sourcesheet)
        
        // 读取中性语言文件
        var updateData: Array<(id: String, value: Array<(language: String, value: String)>)> = []
        guard let updatebook = XLWorkbook(path: updatePath) else {
            self.openExcelFailed(path: updatePath)
            return
        }
        let updatesheet = updatebook.sheet(with: 0)
        updateData = self.readData(worksheet: updatesheet)
        
        var missingData: Array<(id: String, value: Array<(language: String, value: String)>)> = []
        for updateItem in updateData {
            var find = false
            for sourceItem in sourceData {
                if updateItem.id == sourceItem.id {
                    find = true
                    break
                }
            }
            if !find {
                missingData.append(updateItem)
            }
        }
        
        self.writeDataToExcel(data: missingData, targetPath: targetPath)
        self.complete()
    }
}

class CamViewPlusConvert: Convert {
    var sourcePath: String = "/"
    var appPath: String = "/"
    var webPath: String = "/"
    
    func start() {
        sourcePath = self.userData.selected!.array[0].path // Excel
        appPath = self.userData.selected!.array[1].path // app路径
        webPath = self.userData.selected!.array[2].path // web路径
        
        guard let workbook = XLWorkbook(path: sourcePath) else {
            self.openExcelFailed(path: sourcePath)
            return
        }
        let worksheet = workbook.sheet(with: 0)
        let data = self.readData(worksheet: worksheet)
        
        var appData: Array<(id: String, value: Array<(language: String, value: String)>)> = []
        var webData: Array<(id: String, value: Array<(language: String, value: String)>)> = []
        
        var isAppKey = true
        for i in 0..<data.count {
            let item = data[i]
            
            if item.id.count <= 0 {
                isAppKey = false
            }
            
            if isAppKey {
                appData.append(item)
            } else {
                webData.append(item)
            }
        }

        self.writeDataToString(data: appData, targetPath: appPath)
        self.writeDataToXML(data: webData, targetPath: webPath)
        self.complete()
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
        
        guard let sourceImage = NSImage(contentsOfFile: sourcePath) else {
            openExcelFailed(path: sourcePath)
            return
        }
        
        let directoryPath = targetPath
        if !FileManager.default.fileExists(atPath: directoryPath) {
            try! FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        }
        for tuple in imageArr {
            let newSize = NSSize(width: Int(tuple.size * Double(tuple.scale)), height: Int(tuple.size * Double(tuple.scale)))
            let newImage = NSImage(size: newSize)

            let sourceRep = sourceImage.bestRepresentation(for: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), context: nil, hints: nil)

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
        
        self.complete()
    }
}

func recreateFile(path: String) -> Bool {
    var isDirectory: ObjCBool = false
    if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
        if isDirectory.boolValue {
            print("不能删除文件夹")
            return false
        }
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
