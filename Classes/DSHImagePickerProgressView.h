//
//  DSHImagePickerProgressView.h
//  IPicker
//
//  Created by 路 on 2020/1/15.
//  Copyright © 2020年 路. All rights reserved.
//  加载进度指示器

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSHImagePickerProgressView : UIView

@property (assign ,nonatomic) CGFloat progress; // [0,1]
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@property (assign ,nonatomic) CGFloat lineWidth;
@property (strong ,nonatomic) UIColor *lineColor;

@property (strong ,nonatomic) NSDictionary<NSAttributedStringKey,id> *attributes;
@end

NS_ASSUME_NONNULL_END
