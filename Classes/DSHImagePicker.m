//
//  DSHImagePicker.m
//  IPicker
//
//  Created by 路 on 2020/1/13.
//  Copyright © 2020年 路. All rights reserved.
//

#import "DSHImagePicker.h"
#import "DSHImagePickerPermissionController.h"

@implementation DSHPhotoResult
@end

@implementation DSHVideoResult
@end


@interface DSHImagePicker ()
@end

@implementation DSHImagePicker
@synthesize delegate = _delegate;

- (id)init; {
    return [self initWithDelegate:nil selectedAssets:nil];
}
- (id)initWithDelegate:(id<DSHImagePickerDelegate>)delegate selectedAssets:(NSArray <PHAsset *>*)selectedAssets {
    self = [super init];
    if (self) {
        _mode = DSHImagePickerModeImage;
        _column = 4;
        _sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _minimumLineSpacing = 1.f;
        _minimumInteritemSpacing = 1.f;
        _delegate = delegate;
        _videoMinimumDuration = 10.f;
        _videoMaximumDuration = 60.f;
        _selectPhotos = [NSMutableArray array];
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    } return self;
}

#pragma mark - controller
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    DSHImagePickerPermissionController *vc = [[DSHImagePickerPermissionController alloc] init];
    [self setViewControllers:@[vc] animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    
}

#pragma mark -
- (void)setDelegate:(id<DSHImagePickerDelegate>)delegate; {
    [super setDelegate:delegate];
    _delegate = delegate;
}

#pragma mark -
- (BOOL)shouldAutorotate; {
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations; {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation; {
    return UIInterfaceOrientationPortrait;
}
@end


@implementation DSHImagePicker (Private)
- (void)completImages:(NSArray <DSHPhotoResult *>*)images; {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (images && [_delegate respondsToSelector:@selector(imagePicker:didFinishPickingImages:)]) {
        for (DSHPhotoResult *result in images) {
            result.image = [self fixOrientation:result.image];
        }
        [_delegate imagePicker:self didFinishPickingImages:images];
    }
}
- (void)completVideo:(DSHVideoResult *)video; {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (video.fileURL && [_delegate respondsToSelector:@selector(imagePicker:didFinishPickingVideo:)]) {
        [_delegate imagePicker:self didFinishPickingVideo:video];
    }
}
- (void)cancel; {
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([_delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
        [_delegate imagePickerDidCancel:self];
    }
}
- (BOOL)isSelect:(PHAsset *)asset; {
    for (DSHPhotoResult *object in _selectPhotos) {
        if ([object.asset.localIdentifier isEqualToString:asset.localIdentifier]) {
            return YES;
        }
    }
    return NO;
}
- (void)addAsset:(PHAsset *)asset complet:(nonnull dispatch_block_t)complet; {
    __weak typeof(self) _self = self;
    if (_multipleMaxCount > 0 && _selectPhotos.count >= _multipleMaxCount) {
        NSString *message = [NSString stringWithFormat:@"最多选择%@张图片" ,@(_multipleMaxCount)];
        [self show_error_alert:message];
        return;
    }
    
    if ([self isSelect:asset] == NO) {
        [DSHImagePickerImageManager requestImageDataWithPHAsset:asset progressBlock:nil successBlock:^(NSData * _Nonnull imageData) {
            DSHPhotoResult *object = [[DSHPhotoResult alloc] init];
            object.asset = asset;
            object.image = [UIImage imageWithData:imageData];
            [_self.selectPhotos addObject:object];
            if (complet) {
                complet();
            }
        } failureBlock:^(NSError * _Nonnull error) {
            NSString *reason = error.userInfo[NSLocalizedDescriptionKey]?:@"未知错误";
            [_self show_error_alert:reason];
        }];
    }
}
- (void)removeAsset:(PHAsset *)asset; {
    for (DSHPhotoResult *object in _selectPhotos) {
        if ([object.asset.localIdentifier isEqualToString:asset.localIdentifier]) {
            [_selectPhotos removeObject:object];
            return;
        }
    }
}

- (void)show_error_alert:(NSString *)reason; {
    __weak typeof(self) _self = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:reason preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_self.navigationController popViewControllerAnimated:YES];
    }]];
    [self.topViewController presentViewController:alert animated:YES completion:nil];
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
