//
//  XLNT.h
//  xlntDemo
//
//  Created by Raysharp666 on 2019/11/14.
//  Copyright © 2019 LyongY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XLWorksheet, XLWorkbook, XLCell;

#pragma mark - XLWorkbook
@interface XLWorkbook : NSObject
@property (nonatomic, copy) NSString *path;

- (nullable instancetype)initWithPath:(NSString *)path;

- (XLWorksheet *)sheetWith:(unsigned int)index;

- (BOOL)save;
- (BOOL)save:(NSString *)path;
@end

#pragma mark - XLWorksheet

@interface XLWorksheet : NSObject

- (instancetype)initWithWorkbook:(XLWorkbook *)workbook index:(unsigned int)index;

- (XLCell *)cellWithCol:(unsigned int)col row:(unsigned int)row;

- (unsigned int)rowNum;
- (unsigned int)colNum;
@end

#pragma mark - XLCell

@interface XLCell : NSObject

@property (nonatomic, copy) NSString *stringValue;

- (instancetype)initWithWorksheet:(XLWorksheet *)worksheet col:(unsigned int)col row:(unsigned int)row;

@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *textColor;
@end

NS_ASSUME_NONNULL_END
