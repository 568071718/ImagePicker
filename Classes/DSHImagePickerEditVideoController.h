//
//  DSHImagePickerEditVideoController.h
//  IPicker
//
//  Created by 路 on 2020/5/14.
//  Copyright © 2020 路. All rights reserved.
//  编辑视频

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSHImagePickerEditVideoController : UIViewController

- (id)initWithAVAsset:(AVAsset *)asset;
// 最短视频长度
@property (assign ,nonatomic) NSTimeInterval videoMinimumDuration;
// 最长视频长度
@property (assign ,nonatomic) NSTimeInterval videoMaximumDuration;

@property (strong ,nonatomic) dispatch_block_t clickedCloseButtonBlock;
@property (strong ,nonatomic) void(^exportCompletedBlock)(NSURL *outputFileURL);
@end


// Private
@interface DSHImagePickerVideoCoverController : UIViewController

- (id)initWithVideoURL:(NSURL *)videoURL;
@property (strong ,nonatomic ,readonly) NSURL *videoURL;
@property (strong ,nonatomic) void(^clickedDownButtonBlock)(UIImage *image ,NSURL *fileURL ,NSInteger imageTime);
@end

NS_ASSUME_NONNULL_END
