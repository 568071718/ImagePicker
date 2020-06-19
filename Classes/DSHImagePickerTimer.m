//
//  DSHImagePickerTimer.m
//  IPicker
//
//  Created by 路 on 2020/5/13.
//  Copyright © 2020 路. All rights reserved.
//

#import "DSHImagePickerTimer.h"

@implementation DSHImagePickerTimer

- (id)initWithTimerWithTimeInterval:(NSTimeInterval)ti userInfo:(id)userInfo repeats:(BOOL)yesOrNo; {
    self = [super init];
    if (self) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(timerAction) userInfo:userInfo repeats:yesOrNo];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    } return self;
}
+ (DSHImagePickerTimer *)timerWithTimeInterval:(NSTimeInterval)ti userInfo:(id)userInfo repeats:(BOOL)yesOrNo; {
    return [[DSHImagePickerTimer alloc] initWithTimerWithTimeInterval:ti userInfo:userInfo repeats:yesOrNo];
}
- (void)timerAction; {
    if (_handler) {
        _handler(self);
    }
}
@end
