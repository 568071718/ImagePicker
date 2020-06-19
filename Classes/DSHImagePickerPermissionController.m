//
//  DSHImagePickerPermissionController.m
//  IPicker
//
//  Created by 路 on 2020/1/13.
//  Copyright © 2020年 路. All rights reserved.
//

#import "DSHImagePickerPermissionController.h"
#import "DSHImagePickerPhotosController.h"
#import "DSHImagePicker.h"

#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

@interface DSHImagePickerPermissionController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (DSHImagePicker *)imagePicker;
@end

@implementation DSHImagePickerPermissionController
- (DSHImagePicker *)imagePicker; {
    DSHImagePicker *result = (DSHImagePicker *)self.navigationController;
    if ([result isKindOfClass:[DSHImagePicker class]]) {
        return result;
    }
    return nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"权限管理";
    __weak typeof(self) _self = self;
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    if (authorizationStatus == PHAuthorizationStatusAuthorized) {
        [self _requestAuthorization_success];
    } else if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_self _requestAuthorization_success];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_self _requestAuthorization_failure];
                });
            }
        }];
    } else {
        [self _requestAuthorization_failure];
    }
}

- (void)_requestAuthorization_success; {
    if (self.imagePicker.mode == DSHImagePickerModeSquareCamera ||
        self.imagePicker.mode == DSHImagePickerModeImageCamera) {
        [DSHImagePickerHUD show];
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
        vc.delegate = self;
        vc.allowsEditing = NO;
        [self presentViewController:vc animated:NO completion:^{
            [DSHImagePickerHUD hide];
        }];
    } else {
        DSHImagePickerPhotosController *vc = [[DSHImagePickerPhotosController alloc] init];
        [self.navigationController setViewControllers:@[vc] animated:NO];
    }
}
- (void)_requestAuthorization_failure; {
    self.navigationItem.title = @"获取权限失败";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButtonItemAction:)];
}
- (void)leftBarButtonItemAction:(UIBarButtonItem *)sender {
    [self.imagePicker cancel];
}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info; {
    __weak typeof(self) _self = self;
    UIImage *resultImage = info[UIImagePickerControllerOriginalImage];
    
    if (self.imagePicker.mode == DSHImagePickerModeSquareCamera) {
        DSHImagePickerEditImageController *vc = [[DSHImagePickerEditImageController alloc] initWithImage:resultImage];
        [vc setClickedCancelButtonBlock:^{
            [picker dismissViewControllerAnimated:NO completion:nil];
            [_self.imagePicker cancel];
        }];
        [vc setClickedDownButtonBlock:^(UIImage * _Nonnull image) {
            [picker dismissViewControllerAnimated:NO completion:nil];
            DSHPhotoResult *result = [[DSHPhotoResult alloc] init];
            result.asset = info[UIImagePickerControllerPHAsset];
            result.image = image;
            [_self.imagePicker completImages:@[result]];
        }];
        [picker pushViewController:vc animated:YES];
    } else if (self.imagePicker.mode == DSHImagePickerModeImageCamera) {
        [picker dismissViewControllerAnimated:NO completion:nil];
        DSHPhotoResult *result = [[DSHPhotoResult alloc] init];
        result.asset = info[UIImagePickerControllerPHAsset];
        result.image = resultImage;
        [self.imagePicker completImages:@[result]];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker; {
    [picker dismissViewControllerAnimated:NO completion:nil];
    [self.imagePicker cancel];
}
@end
