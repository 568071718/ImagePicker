//
//  DSHImagePickerCamera.m
//  IPicker
//
//  Created by 路 on 2020/5/20.
//  Copyright © 2020 路. All rights reserved.
//

#import "DSHImagePickerCamera.h"

@implementation DSHImagePickerCameraPreview
+ (Class)layerClass; {
    return [AVCaptureVideoPreviewLayer class];
}
- (AVCaptureVideoPreviewLayer *)previewLayer; {
    return (AVCaptureVideoPreviewLayer *)[super layer];
}
- (id)initWithSession:(AVCaptureSession *)session; {
    self = [super init];
    if (self) {
        self.previewLayer.session = session;
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    } return self;
}
@end

@interface DSHImagePickerCamera ()

+ (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position;
@property (strong ,nonatomic ,readonly) AVCaptureSession *captureSession;
@property (strong ,nonatomic ,readonly) AVCaptureConnection *videoConnection;
@property (strong ,nonatomic ,readonly) AVCaptureStillImageOutput *stillImageOutput; // 拍照
@property (strong ,nonatomic ,readonly) AVCaptureMovieFileOutput *movieFileOutput; // 录制视频

- (AVCaptureDeviceInput *)currentVideoInput;
@end

@implementation DSHImagePickerCamera
+ (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position; {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position){
            return device;
        }
    }
    return nil;
}
- (id)init; {
    return [self initWithDevicePosition:AVCaptureDevicePositionFront];
}
- (id)initWithDevicePosition:(AVCaptureDevicePosition)position; {
    return [self initWithDevicePosition:position sessionPreset:AVCaptureSessionPreset640x480];
}
- (id)initWithDevicePosition:(AVCaptureDevicePosition)position sessionPreset:(AVCaptureSessionPreset)sessionPreset; {
    self = [super init];
    if (self) {
        
        _captureSession = [[AVCaptureSession alloc] init];
        
        [_captureSession beginConfiguration];
        // sessionPreset
        if ([_captureSession canSetSessionPreset:sessionPreset]) {
            _captureSession.sessionPreset = sessionPreset;
        }
        //  input
        AVCaptureDevice *videoDevice = [DSHImagePickerCamera videoDeviceWithPosition:position];
        AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
        if ([_captureSession canAddInput:videoInput]) {
            [_captureSession addInput:videoInput];
        }
        // output
        _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        _movieFileOutput.movieFragmentInterval = kCMTimeInvalid;
        if ([_captureSession canAddOutput:_movieFileOutput]) {
            [_captureSession addOutput:_movieFileOutput];
        }
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([_captureSession canAddOutput:_stillImageOutput]) {
            [_captureSession addOutput:_stillImageOutput];
        }
        [_captureSession commitConfiguration];
        [_captureSession startRunning];
        
        _preview = [[DSHImagePickerCameraPreview alloc] initWithSession:_captureSession];
        _videoConnection = _preview.previewLayer.connection;
        _videoConnection.automaticallyAdjustsVideoMirroring = NO;
    } return self;
}

- (void)captureStillImageAsynchronously:(void (^)(UIImage * _Nonnull))successBlock failureBlock:(void (^)(NSError * _Nonnull))failureBlock; {
    AVCaptureConnection *connection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoMirrored = _videoConnection.videoMirrored;
    connection.videoOrientation = _videoConnection.videoOrientation;
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) failureBlock(error);
            });
        } else {
            NSData *imageData = nil;
            if (imageDataSampleBuffer) {
                imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            }
            if (imageData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (successBlock) successBlock([UIImage imageWithData:imageData]);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failureBlock) failureBlock([NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:nil]);
                });
            }
        }
    }];
}

- (void)startRecordingWithRecordingDelegate:(id<AVCaptureFileOutputRecordingDelegate>)delegate; {
    NSString *component = [NSTemporaryDirectory() stringByAppendingPathComponent:@"dsh_video"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exists = NO;
    BOOL isDirectory = NO;
    exists = [fileManager fileExistsAtPath:component isDirectory:&isDirectory];
    if (!exists || !isDirectory) {
        [fileManager createDirectoryAtPath:component withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [component stringByAppendingPathComponent:@"dshTemp.mp4"];
    [self startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath] recordingDelegate:delegate];
}
- (void)startRecordingToOutputFileURL:(NSURL *)outputFileURL recordingDelegate:(id<AVCaptureFileOutputRecordingDelegate>)delegate; {
    AVCaptureConnection *connection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoMirrored = _videoConnection.videoMirrored;
    connection.videoOrientation = _videoConnection.videoOrientation;
    [_movieFileOutput startRecordingToOutputFileURL:outputFileURL recordingDelegate:delegate];
}
- (void)stopRecording; {
    [_movieFileOutput stopRecording];
}

#pragma mark -
- (AVCaptureDeviceInput *)currentVideoInput; {
    for (AVCaptureDeviceInput *input in _captureSession.inputs) {
        if ([input.device hasMediaType:AVMediaTypeVideo]) {
            return input;
        }
    } return nil;
}
- (BOOL)videoMirrored; {
    return _videoConnection.videoMirrored;
}
- (void)setVideoMirrored:(BOOL)videoMirrored; {
    if ([_videoConnection isVideoMirroringSupported]) {
        _videoConnection.videoMirrored = videoMirrored;
    }
}
- (AVCaptureSessionPreset)sessionPreset; {
    return _captureSession.sessionPreset;
}
- (void)setSessionPreset:(AVCaptureSessionPreset)sessionPreset; {
    if ([_captureSession canSetSessionPreset:sessionPreset]) {
        _captureSession.sessionPreset = sessionPreset;
    }
}
- (AVCaptureDevicePosition)position; {
    return self.currentVideoInput.device.position;
}
- (void)setPosition:(AVCaptureDevicePosition)position; {
    self.turnTorchOn = NO;
    _preview.previewLayer.session = nil;
    
    [_captureSession beginConfiguration];
    AVCaptureDeviceInput *oldInput = self.currentVideoInput;
    if (oldInput) {
        [_captureSession removeInput:oldInput];
    }
    AVCaptureDevice *videoDevice = [DSHImagePickerCamera videoDeviceWithPosition:position];
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
    if ([_captureSession canAddInput:videoInput]) {
        [_captureSession addInput:videoInput];
    } else if (oldInput) {
        [_captureSession addInput:oldInput];
    }
    [_captureSession commitConfiguration];
    
    _preview.previewLayer.session = _captureSession;
    _videoConnection = _preview.previewLayer.connection;
    _videoConnection.automaticallyAdjustsVideoMirroring = NO;
}
- (void)setTurnTorchOn:(BOOL)turnTorchOn; {
    if (_turnTorchOn == turnTorchOn) {
        return;
    }
    AVCaptureDevice *device = self.currentVideoInput.device;
    if (device && [device hasTorch] && [device hasFlash]) {
        _turnTorchOn = turnTorchOn;
        [device lockForConfiguration:nil];
        if (turnTorchOn) {
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    } else {
        NSLog(@"错误: %s '设备不支持'" ,__func__);
    }
}
- (void)enableAudio; {
    [_captureSession beginConfiguration];
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
    if ([_captureSession canAddInput:audioInput]) {
        [_captureSession addInput:audioInput];
    }
    [_captureSession commitConfiguration];
}
@end
