//
//  VoiceRecordProgram.m
//  VoiceView
//
//  Created by 杨杰 on 16/3/30.
//  Copyright © 2016年 杨杰. All rights reserved.
//

#import "VoiceRecordProgram.h"

@implementation VoiceRecordProgram

+ (VoiceRecordProgram *)shareInstance
{
    static VoiceRecordProgram * obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[VoiceRecordProgram alloc]init];
    });
    return obj;
}

- (void)setNotSend:(BOOL)notSend
{
    _notSend = notSend;
}


#pragma mark - 录音操作
- (void)beginRecordByFileName:(NSString*)_fileName
{
    
    //设置文件名和录音路径
    self.recordFileName = _fileName;
    self.recordFilePath = [VoiceRecordProgram getPathByFileName:self.recordFileName ofType:@"wav"];
    NSLog(@"start");
    _recordFilePath = [VoiceRecordBase getPathByFileName:self.recordFileName ofType:@"wav"];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    _recorder=[[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:_recordFilePath] settings:[VoiceRecordBase getAudioRecorderSettingDict] error:nil];
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    [_recorder prepareToRecord];
    [_recorder record];
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(returnsVoiceLevel) userInfo:nil repeats:YES];
    _recordDurationTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(computeRecordDuration) userInfo:nil repeats:YES];
    count = 0;
}

#pragma mark - 录音结束
- (NSString *)endRecord
{
    if (_recorder.isRecording) {
        [_recorder stop];
        _recorder=nil;
        [_recordDurationTimer invalidate];
        _recordDurationTimer = nil;
        [_timer invalidate];
        _timer=nil;
    }
    
    if (self.notSend) {
         [VoiceRecordProgram deleteFileAtPath:_recordFilePath];
    }else
    {
       NSString *amrPath = [self voiceRecorderBaseVCRecordFinish:_recordFilePath fileName:self.recordFileName];
        if (amrPath) {
            return amrPath;
        }
    }
    return nil;
}

/********************wav转amr********************/

- (NSString *)voiceRecorderBaseVCRecordFinish:(NSString *)_filePath fileName:(NSString*)_fileName
{
    NSLog(@"录音完成，文件路径:%@",_filePath);
    
    NSTimeInterval duration = [self getAudioDuration:_filePath];
    NSTimeInterval durationTemp = ceil(duration)>=60.0?60:ceil(duration);
    
    if(duration < 1.5f)
    {
//        [MBProgressManager textHudInView:self.view text:Locale(@"imMessage.recordTimeToShort") delay:1.0f];
        [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
        return nil;
    }
    
    NSString *amrName = [[NSString stringWithFormat:@"%.0f-%.0f",[[NSDate date] timeIntervalSince1970],durationTemp] stringByAppendingPathExtension:@"amr"];
    NSString *armfileName = [[self amrRootPath] stringByAppendingPathComponent:amrName];
    if(![VoiceConverter wavToAmr:_filePath amrSavePath:armfileName])
    {
        [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
    }
    return armfileName;
    
}

- (NSTimeInterval)getAudioDuration:(NSString*)path
{
    AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:nil];
    return play.duration;
}

- (void)playRecord:(NSString *)amrPath
{
    
    if (isPlay) {
        [_player stop];
        isPlay=NO;
    }else{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        if([VoiceConverter amrToWav:amrPath wavSavePath:[VoiceRecordProgram getPathByFileName:@"new" ofType:@"wav"]])
        {
        _player=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[VoiceRecordProgram getPathByFileName:@"new" ofType:@"wav"]] error:nil];
            _player.delegate = self;
        _player.volume=1.0;
        [_player prepareToPlay];
        [_player play];
        isPlay=YES;
        }
    }

}


#pragma mark - AVAudioRecorder Delegate Methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
}
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags{
    
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_player stop];
    isPlay=NO;
}


/***************缓存目录（钓鱼人里面有该方法类 临时写成一个方法）***************/
- (NSString *)amrRootPath
{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *docPath = [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
    
    NSString *path = [docPath stringByAppendingPathComponent:@"seafish.amr"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        if (!success) {
            NSLog(@"error: %@", error);
        }
    }
    return path;
}


#pragma mark -录音时开始计时
- (void)computeRecordDuration
{
    if (count >59) {
        NSString *armPath = [[VoiceRecordProgram shareInstance]endRecord];
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordDurationOver60Sec:)]) {
            [self.delegate recordDurationOver60Sec:armPath];
        }
        return;
    }
    count ++;
}


/**
 *  音量
 **/
- (void)returnsVoiceLevel
{
    NSString * level = @"0";
    if (_recorder.isRecording) {
        [_recorder updateMeters];
        double peak = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
        NSLog(@"%f",peak);
        
        
        if (peak>0.8) {
            
            level = @"8";
        }else if (peak>0.6){
            level = @"7";
            
        }else if (peak>0.4){
            level = @"5";
            
        }else if (peak>0.2){
            level = @"3";
            
        }else if(peak>0.1){
            level = @"2";
            
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVoiceLevels:)]) {
        [self.delegate sendVoiceLevels:level];
    }
}
@end
