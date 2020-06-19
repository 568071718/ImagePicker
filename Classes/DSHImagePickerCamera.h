//
//  DSHImagePickerCamera.h
//  IPicker
//
//  Created by 路 on 2020/5/20.
//  Copyright © 2020 路. All rights reserved.
//  自定义相机

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSHImagePickerCameraPreview : UIView
- (id)initWithSession:(AVCaptureSession *)session;
- (AVCaptureVideoPreviewLayer *)previewLayer;
@end

@interface DSHImagePickerCamera : NSObject

- (id)initWithDevicePosition:(AVCaptureDevicePosition)position;

@property (strong ,nonatomic ,readonly) DSHImagePickerCameraPreview *preview;

@property (assign ,nonatomic) AVCaptureDevicePosition position;
@property (strong ,nonatomic) AVCaptureSessionPreset sessionPreset;
@property (assign ,nonatomic) BOOL videoMirrored;
@property (assign ,nonatomic) BOOL turnTorchOn;

// 拍照
- (void)captureStillImageAsynchronously:(void(^)(UIImage *stillImage))successBlock failureBlock:(void(^)(NSError *error))failureBlock;
//// 录制视频
- (void)startRecordingWithRecordingDelegate:(id<AVCaptureFileOutputRecordingDelegate>)delegate;
- (void)startRecordingToOutputFileURL:(NSURL *)outputFileURL recordingDelegate:(id<AVCaptureFileOutputRecordingDelegate>)delegate;
- (void)stopRecording;

- (void)enableAudio;
@end

NS_ASSUME_NONNULL_END
