//
//  DSHImagePickerVideoPlayer.h
//  IPicker
//
//  Created by 路 on 2020/5/15.
//  Copyright © 2020 路. All rights reserved.
//  本地视频播放器

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DSHImagePickerVideoPlayer;
@protocol DSHImagePickerVideoPlayerDelegate <NSObject>
@optional
// 开始播放
- (void)imagePickerVideoPlayerDidStart:(DSHImagePickerVideoPlayer *)imagePickerVideoPlayer;
// 暂停播放
- (void)imagePickerVideoPlayerDidPause:(DSHImagePickerVideoPlayer *)imagePickerVideoPlayer;
// 播放结束
- (void)imagePickerVideoPlayerDidPlayToEndTime:(DSHImagePickerVideoPlayer *)imagePickerVideoPlayer;
// 播放进度
- (void)imagePickerVideoPlayer:(DSHImagePickerVideoPlayer *)imagePickerVideoPlayer videoPlayProgress:(CGFloat)progress;
@end

@interface DSHImagePickerVideoPlayer : UIView

@property (strong ,nonatomic ,readonly) AVPlayer *player;
@property (strong ,nonatomic) AVAsset *asset; // 视频源
@property (assign ,nonatomic) NSTimeInterval start; // 设置从第几秒开始播放,默认 0
@property (assign ,nonatomic) NSTimeInterval duration; // 设置视频播放长度
@property (weak ,nonatomic) id <DSHImagePickerVideoPlayerDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
