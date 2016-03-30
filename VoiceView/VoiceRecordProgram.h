//
//  VoiceRecordProgram.h
//  VoiceView
//
//  Created by 杨杰 on 16/3/30.
//  Copyright © 2016年 杨杰. All rights reserved.
//

#import "VoiceRecordBase.h"
@protocol VoiceRecordProgramDelegate <NSObject>

- (void)recordDurationOver60Sec:(NSString *)amrPath;
- (void)sendVoiceLevels:(NSString *)level;         //发送音量方法

@end
@interface VoiceRecordProgram : VoiceRecordBase<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    
    NSString *_recordFilePath;
    AVAudioRecorder *_recorder;
    AVAudioPlayer *_player;
    BOOL isPlay;
    NSTimer *_recordDurationTimer;
    NSTimer *_timer;         //发送声音音量
    NSInteger count;
    
}

+(VoiceRecordProgram *)shareInstance;
/**
 *  初始化录音（开始录音）
 **/
- (void)beginRecordByFileName:(NSString*)_fileName;
/**
 *  结束录音
 **/
- (NSString *)endRecord;
/**
 *  播放录音
 **/
- (void)playRecord:(NSString *)amrPath;


@property (nonatomic, assign) BOOL notSend;  //是否发送
@property (nonatomic, assign) id <VoiceRecordProgramDelegate>delegate;
@end

