//
//  XLNT.m
//  xlntDemo
//
//  Created by Raysharp666 on 2019/11/14.
//  Copyright © 2019 LyongY. All rights reserved.
//

#import "XLNT.h"
#import <xlnt/xlnt.hpp>
//using namespace xlnt;

#include <fstream>


#pragma mark - workbook
@interface XLWorkbook() {
    xlnt::path _xlntpath;
    
@public
    xlnt::workbook _workbook;
}

@end

@implementation XLWorkbook

- (instancetype)init
{
    self = [super init];
    if (self) {
        _workbook = xlnt::workbook();
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        self.path = path;
        try {
            _workbook = xlnt::workbook(_xlntpath);
        } catch(std::exception err)  {
            return nil;
        }
    }
    return self;
}

- (void)setPath:(NSString *)path {
    _path = path;
    _xlntpath = xlnt::path(path.UTF8String);
}

- (XLWorksheet *)sheetWith:(unsigned int)index {
    return [[XLWorksheet alloc] initWithWorkbook:self index:index];
}

- (BOOL)save {
    if (_xlntpath == xlnt::path()) {
        return NO;
    }
    _workbook.save(xlnt::path(_xlntpath));
    return YES;
}

- (BOOL)save:(NSString *)path {
    xlnt::path savePath = xlnt::path(path.UTF8String);
    if (savePath.exists()) {
        return NO;
    }
    _workbook.save(savePath);
    return YES;
}

@end

#pragma mark - worksheet

@interface XLWorksheet() {
    @public
    xlnt::worksheet _worksheet;
}

@end

@implementation XLWorksheet

- (instancetype)initWithWorkbook:(XLWorkbook *)book index:(unsigned int)index {
    self = [super init];
    if (self) {
        _worksheet = book->_workbook.sheet_by_index(index);
    }
    return self;
}

- (XLCell *)cellWithCol:(unsigned int)col row:(unsigned int)row {
    return [[XLCell alloc] initWithWorksheet:self col:col row:row];
}

- (unsigned int)rowNum {
    unsigned int maxRow = (unsigned int)_worksheet.rows().length();
    for (int i = maxRow; i > 0; i--) {
        maxRow = i;
        std::string str = _worksheet.cell(1, maxRow).to_string();
        if (str.length() > 0) {
            break;
        }
    }
    return maxRow;
}

- (unsigned int)colNum {
    unsigned int maxCol = (unsigned int)_worksheet.columns(false).length();
    for (int i = maxCol; i > 0; i--) {
        maxCol = i;
        std::string str = _worksheet.cell(maxCol, 1).to_string();
        if (str.length() > 0) {
            break;
        }
    }
    return maxCol;
}
@end

#pragma mark - cell
@interface XLCell() {
    XLWorksheet *_sheet;
    unsigned int _col;
    unsigned int _row;
}
@end

@implementation XLCell

- (instancetype)initWithWorksheet:(XLWorksheet *)sheet col:(unsigned int)col row:(unsigned int)row {
    self = [super init];
    if (self) {
        _sheet = sheet;
        _col = col;
        _row = row;
    }
    return self;
}

- (xlnt::cell)cell {
    xlnt::cell cell = _sheet->_worksheet.cell(_col, _row);
    return cell;
}

- (void)setStringValue:(NSString *)value {
    [self cell].value(value.UTF8String);
}

- (NSString *)stringValue {
    std::string str = [self cell].to_string();
    const char* cstr = str.c_str();
    return [NSString stringWithCString:cstr encoding:NSUTF8StringEncoding];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    if (backgroundColor.colorSpace.colorSpaceModel != NSColorSpaceModelRGB) {
        backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    _backgroundColor = backgroundColor;
    
    [self cell].fill(xlnt::fill().solid(xlnt::rgb_color(backgroundColor.redComponent*255, backgroundColor.greenComponent*255, backgroundColor.blueComponent*255)));
}

- (void)setTextColor:(NSColor *)textColor {
    if (textColor.colorSpace.colorSpaceModel != NSColorSpaceModelRGB) {
        textColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    _textColor = textColor;
    
    xlnt::font font = [self cell].font();
    font.color(xlnt::rgb_color(textColor.redComponent*255, textColor.greenComponent*255, textColor.blueComponent*255));
    [self cell].font(font);
}

@end
