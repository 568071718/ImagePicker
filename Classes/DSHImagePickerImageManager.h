//
//  DSHImagePickerImageManager.h
//  IPicker
//
//  Created by 路 on 2020/5/14.
//  Copyright © 2020 路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSHImagePickerImageManager : NSObject

+ (void)requestImageDataWithPHAsset:(PHAsset *)asset progressBlock:(nullable void(^)(CGFloat progress))progressBlock successBlock:(nullable void(^)(NSData *imageData))successBlock failureBlock:(nullable void(^)(NSError *error))failureBlock;
+ (void)requestImageForPreviewWithPHAsset:(PHAsset *)asset progressBlock:(nullable void(^)(CGFloat progress))progressBlock successBlock:(nullable void(^)(UIImage *resultImage))successBlock failureBlock:(nullable void(^)(NSError *error))failureBlock;
+ (void)requestAVAssetWithPHAsset:(PHAsset *)asset progressBlock:(nullable void(^)(CGFloat progress))progressBlock successBlock:(nullable void(^)(AVAsset *asset))successBlock failureBlock:(nullable void(^)(NSError *error))failureBlock;

// caching image manager
@property (strong ,nonatomic ,readonly) PHCachingImageManager *imageManager;
@property (strong ,nonatomic ,readonly) PHImageRequestOptions *imageRequestOptions;
@property (assign ,nonatomic) CGSize targetSize;
@property (assign ,nonatomic) PHImageContentMode contentMode;
- (void)cachingAssets:(NSArray <PHAsset *>*)assets;
- (void)imageFromAsset:(PHAsset *)asset resultBlock:(void(^)(UIImage *resultImage))resultBlock;
@end

NS_ASSUME_NONNULL_END
