//
//  DSHImagePickerEditVideoTimeRangeView.h
//  IPicker
//
//  Created by 路 on 2020/5/19.
//  Copyright © 2020 路. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSHImagePickerEditVideoTimeRangeView : UIView
// 设置背景帧序列图
- (void)setBackgroundImages:(NSArray <UIImage *>*)images;

// 初始化参数
@property (assign ,nonatomic) CGFloat start; // 取值范围 0 - 1
@property (assign ,nonatomic) CGFloat width; // 取值范围 0 - 1
- (void)set; // 填充初始化参数

@property (assign ,nonatomic) CGFloat minimumWidth; // 取值范围 0 - 1
@property (assign ,nonatomic) CGFloat maximumWidth; // 取值范围 0 - 1

// 裁剪框位置变化回调
@property (strong ,nonatomic) void(^rangeDidChangeBlock)(CGFloat start ,CGFloat width);

// 设置播放进度
- (void)setProgress:(CGFloat)progress;
@end

NS_ASSUME_NONNULL_END
