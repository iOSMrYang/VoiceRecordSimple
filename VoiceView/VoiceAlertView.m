//
//  VoiceAlertView.m
//  VoiceView
//
//  Created by 杨杰 on 16/3/29.
//  Copyright © 2016年 杨杰. All rights reserved.
//

#import "VoiceAlertView.h"

@implementation VoiceAlertView
- (void)awakeFromNib
{
    self.childView.layer.cornerRadius = 5.0f;
    self.childView.clipsToBounds = YES;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)setIsCancel:(BOOL)isCancel
{
    _isCancel = isCancel;
    if (!isCancel) {
        _cancelBottomHeight.constant = 0;
        [UIView animateWithDuration:0.2 animations:^{
            [_childView layoutIfNeeded];
        }];
    }else
    {
        _cancelBottomHeight.constant = -17;
        [UIView animateWithDuration:0.2 animations:^{
            [_childView layoutIfNeeded];
        }];
    }
    
}

@end
