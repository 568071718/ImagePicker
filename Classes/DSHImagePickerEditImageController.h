//
//  DSHImagePickerEditImageController.h
//  IPicker
//
//  Created by 路 on 2020/5/18.
//  Copyright © 2020 路. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSHImagePickerEditImageController : UIViewController

- (id)initWithImage:(nullable UIImage *)image;
@property (strong ,nonatomic) UIImage *image;
@property (assign ,nonatomic) CGFloat cutScale; // 裁剪比例

@property (strong ,nonatomic) dispatch_block_t clickedCancelButtonBlock;
@property (strong ,nonatomic) void(^clickedDownButtonBlock)(UIImage *image);
@end

NS_ASSUME_NONNULL_END
