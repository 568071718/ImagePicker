//
//  DSHImagePickerTimer.h
//  IPicker
//
//  Created by 路 on 2020/5/13.
//  Copyright © 2020 路. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSHImagePickerTimer : NSObject

- (id)initWithTimerWithTimeInterval:(NSTimeInterval)ti userInfo:(id)userInfo repeats:(BOOL)yesOrNo;
+ (DSHImagePickerTimer *)timerWithTimeInterval:(NSTimeInterval)ti userInfo:(id)userInfo repeats:(BOOL)yesOrNo;
@property (strong ,nonatomic) NSTimer *timer;
@property (strong ,nonatomic) void(^handler)(DSHImagePickerTimer *timerObject);
@end
