//
//  VoiceRecordBase.h
//  VoiceView
//
//  Created by 杨杰 on 16/3/30.
//  Copyright © 2016年 杨杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiceConverter.h"
@interface VoiceRecordBase : NSObject
@property (copy, nonatomic)             NSString                *recordFileName;//录音文件名
@property (copy, nonatomic)             NSString                *recordFilePath;//录音文件路径

/**
 生成当前时间字符串
 @returns 当前时间字符串
 */
+ (NSString*)getCurrentTimeString;

/**
 获取缓存路径
 @returns 缓存路径
 */
+ (NSString*)getCacheDirectory;

/**
 判断文件是否存在
 @param _path 文件路径
 @returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path;

/**
 删除文件
 @param _path 文件路径
 @returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path;


#pragma mark -

/**
 生成文件路径
 @param _fileName 文件名
 @param _type 文件类型
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName;
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type;



/******************************录音相关******************************/

/**
 获取录音设置
 @returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict;


@end
