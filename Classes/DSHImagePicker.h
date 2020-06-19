//
//  DSHImagePicker.h
//  IPicker
//
//  Created by 路 on 2020/1/13.
//  Copyright © 2020年 路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

// Public
#import "DSHImageScrollView.h"
#import "DSHImagePickerProgressView.h"
#import "DSHImagePickerTimer.h"
#import "DSHImagePickerImageManager.h"
#import "DSHImagePickerVideoPlayer.h"
#import "DSHImagePickerEditImageController.h"
#import "DSHImagePickerEditVideoController.h"
#import "DSHImagePickerHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface DSHPhotoResult : NSObject
@property (strong ,nonatomic) PHAsset *asset;
@property (strong ,nonatomic) UIImage *image;
@end

@interface DSHVideoResult : NSObject
@property (strong ,nonatomic) PHAsset *asset;
@property (strong ,nonatomic) NSURL *fileURL;
@property (strong ,nonatomic) UIImage *cover;
@property (assign ,nonatomic) NSInteger coverTime;
@end

typedef NS_ENUM(NSUInteger ,DSHImagePickerMode) {
    // 图片单选
    DSHImagePickerModeImage,
    DSHImagePickerModeImageCamera,
    
    // 图片单选 + 裁切效果 (默认正方形，可用来选择头像)
    DSHImagePickerModeSquare,
    DSHImagePickerModeSquareCamera,
    
    // 图片多选
    DSHImagePickerModeMultipleImage,
    
    // 选择视频
    DSHImagePickerModeVideo,
};

@class DSHImagePicker;
@protocol DSHImagePickerDelegate <UINavigationControllerDelegate>
@optional
- (void)imagePickerDidCancel:(DSHImagePicker *)picker;
- (void)imagePicker:(DSHImagePicker *)picker didFinishPickingVideo:(DSHVideoResult *)resultVideo;
- (void)imagePicker:(DSHImagePicker *)picker didFinishPickingImages:(NSArray <DSHPhotoResult *>*)resultImages;
@end

@interface DSHImagePicker : UINavigationController

@property (weak ,nonatomic) id<DSHImagePickerDelegate>delegate;
@property (assign ,nonatomic) NSInteger tag;
@property (assign ,nonatomic) DSHImagePickerMode mode;

@property (assign ,nonatomic) NSUInteger column;
@property (assign ,nonatomic) NSUInteger minimumLineSpacing;
@property (assign ,nonatomic) NSUInteger minimumInteritemSpacing;
@property (assign ,nonatomic) UIEdgeInsets sectionInset;

// * DSHImagePickerModeMultipleImage
@property (assign ,nonatomic) NSInteger multipleMaxCount; // 单次最多选择多少张图片
@property (strong ,nonatomic ,readonly) NSMutableArray <DSHPhotoResult *>*selectPhotos;

// * DSHImagePickerModeVideo
@property (assign ,nonatomic) BOOL customVideoCoverSupported; // 从视频内选取一帧封面图片
@property (assign ,nonatomic) NSTimeInterval videoMinimumDuration; // 最短视频长度
@property (assign ,nonatomic) NSTimeInterval videoMaximumDuration; // 最长视频长度
@end

@interface DSHImagePicker (Private)
- (void)completImages:(NSArray <DSHPhotoResult *>*)images;
- (void)completVideo:(DSHVideoResult *)video;
- (void)cancel;

- (BOOL)isSelect:(PHAsset *)asset;
- (void)addAsset:(PHAsset *)asset complet:(dispatch_block_t)complet;
- (void)removeAsset:(PHAsset *)asset;

- (void)show_error_alert:(NSString *)reason;
@end

NS_ASSUME_NONNULL_END
