//
//  VoiceAlertView.h
//  VoiceView
//
//  Created by 杨杰 on 16/3/29.
//  Copyright © 2016年 杨杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoiceAlertView : UIView
@property (assign, nonatomic) BOOL isCancel;

@property (weak, nonatomic) IBOutlet UIView *childView;
@property (weak, nonatomic) IBOutlet UILabel *voiceLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBottomHeight;


@end
