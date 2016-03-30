//
//  ViewController.m
//  VoiceView
//
//  Created by 杨杰 on 16/3/29.
//  Copyright © 2016年 杨杰. All rights reserved.
//

#import "ViewController.h"
#import "VoiceAlertView.h"
#define WeakSelf __weak typeof(self) wSelf = self;
#define LowLevel @"0";
@interface ViewController ()<AVAudioRecorderDelegate,VoiceRecordProgramDelegate>
{
    VoiceAlertView *_voiceView;
    NSString * _voicePath;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _voiceView = [[[NSBundle mainBundle]loadNibNamed:@"VoiceAlertView" owner:self options:nil]lastObject];
    [self.view addSubview:_voiceView];
    WeakSelf;
    [_voiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(wSelf.view.mas_leading);
        make.trailing.equalTo(wSelf.view.mas_trailing);
        make.top.equalTo(wSelf.view.mas_top);
        make.bottom.equalTo(wSelf.view.mas_bottom).with.offset(-100);
    }];
    
    [self addSignal];
    
    
}

- (void)addSignal
{
    /********************开始录音********************/
    [[_startBtn rac_signalForControlEvents:UIControlEventTouchDown]subscribeNext:^(id x) {
        [[VoiceRecordProgram shareInstance]beginRecordByFileName:[VoiceRecordProgram getCurrentTimeString]];
        [VoiceRecordProgram shareInstance].delegate = self;
       
        _voiceView.isCancel = NO;
    }];
    
    
    /********************结束录音********************/
    [[_startBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        NSLog(@"end-start");
       _voicePath = [[VoiceRecordProgram shareInstance]endRecord];
        _voiceView.isCancel = YES;
        _voiceView.voiceLevelLabel.text = LowLevel;
        
    }];
    
    
    /********************播放录音********************/
    [[_playBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        NSLog(@"playVoice");
        [[VoiceRecordProgram shareInstance]playRecord:_voicePath];
}];
}

#pragma mark -VoiceRecordProgramDelegate
- (void)recordDurationOver60Sec:(NSString *)amrPath
{
    _voicePath = amrPath;

}

- (void)sendVoiceLevels:(NSString *)level
{
    _voiceView.voiceLevelLabel.text = level;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
