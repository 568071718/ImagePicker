//
//  DSHImagePickerImageManager.m
//  IPicker
//
//  Created by 路 on 2020/5/14.
//  Copyright © 2020 路. All rights reserved.
//

#import "DSHImagePickerImageManager.h"

@implementation DSHImagePickerImageManager

+ (void)requestImageDataWithPHAsset:(PHAsset *)asset progressBlock:(void (^)(CGFloat))progressBlock successBlock:(void (^)(NSData * _Nonnull))successBlock failureBlock:(void (^)(NSError * _Nonnull))failureBlock; {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [options setProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) progressBlock(progress);
        });
    }];
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        NSError *error = info[PHImageErrorKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (failureBlock) failureBlock(error);
            } else {
                if (successBlock) successBlock(imageData);
            }
        });
    }];
}
+ (void)requestImageForPreviewWithPHAsset:(PHAsset *)asset progressBlock:(void (^)(CGFloat))progressBlock successBlock:(void (^)(UIImage * _Nonnull))successBlock failureBlock:(void (^)(NSError * _Nonnull))failureBlock; {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [options setProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) progressBlock(progress);
        });
    }];
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        NSError *error = info[PHImageErrorKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (failureBlock) failureBlock(error);
            } else {
                if (successBlock) successBlock(result);
            }
        });
    }];
}
+ (void)requestAVAssetWithPHAsset:(PHAsset *)aAsset progressBlock:(void (^)(CGFloat))progressBlock successBlock:(void (^)(AVAsset * _Nonnull))successBlock failureBlock:(void (^)(NSError * _Nonnull))failureBlock; {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [options setProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) progressBlock(progress);
        });
    }];
    [[PHImageManager defaultManager] requestAVAssetForVideo:aAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        NSError *error = info[PHImageErrorKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (failureBlock) failureBlock(error);
            } else {
                if (successBlock) successBlock(asset);
            }
        });
    }];
}

- (id)init; {
    self = [super init];
    if (self) {
        _imageRequestOptions = [[PHImageRequestOptions alloc] init];
        _imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        _imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
        _contentMode = PHImageContentModeDefault;
        UIScreen *mainScreen = [UIScreen mainScreen];
        _targetSize.width = mainScreen.bounds.size.width / 4.f * mainScreen.scale;
        _targetSize.height = _targetSize.width;
        _imageManager = [[PHCachingImageManager alloc] init];
        _imageManager.allowsCachingHighQualityImages = YES;
    } return self;
}
- (void)cachingAssets:(NSArray <PHAsset *>*)assets; {
    [_imageManager startCachingImagesForAssets:assets targetSize:_targetSize contentMode:_contentMode options:_imageRequestOptions];
}
- (void)imageFromAsset:(PHAsset *)asset resultBlock:(void (^)(UIImage * _Nonnull))resultBlock; {
    [_imageManager requestImageForAsset:asset targetSize:_targetSize contentMode:_contentMode options:_imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultBlock) resultBlock(result);
        });
    }];
}
- (void)dealloc; {
    [_imageManager stopCachingImagesForAllAssets];
    _imageManager = nil;
}
@end
