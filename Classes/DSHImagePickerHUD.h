//
//  DSHImagePickerHUD.h
//  IPicker
//
//  Created by 路 on 2020/5/30.
//  Copyright © 2020 路. All rights reserved.
//  简单的全屏指示器

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSHImagePickerHUD : NSObject

+ (void)show;
+ (void)showMessage:(nullable NSString *)message;
+ (void)hide;

+ (nullable UIView *)superview;
+ (BOOL)isDisplay;
@end

NS_ASSUME_NONNULL_END
