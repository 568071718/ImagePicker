//
//  DSHImagePickerPreviewController.h
//  IPicker
//
//  Created by 路 on 2020/1/14.
//  Copyright © 2020年 路. All rights reserved.
//  图片预览

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSHImagePickerPreviewController : UIViewController <UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource>

@property (strong ,nonatomic ,readonly) UICollectionView *collectionView;
@end

NS_ASSUME_NONNULL_END
