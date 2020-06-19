//
//  DSHImageScrollView.h
//  IPicker
//
//  Created by 路 on 2020/5/18.
//  Copyright © 2020 路. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSHImageScrollView : UIScrollView <UIScrollViewDelegate>

- (id)initWithImage:(UIImage *)image;
@property (strong ,nonatomic ,nullable) UIImage *image;

@property (strong ,nonatomic) void(^scrollViewDidScrollBlock)(DSHImageScrollView *scrollView);
@property (strong ,nonatomic) BOOL(^singleClickActionBlock)(DSHImageScrollView *scrollView);
@property (strong ,nonatomic) BOOL(^doubleClickActionBlock)(DSHImageScrollView *scrollView);

- (void)resetZoomScale;
@end

NS_ASSUME_NONNULL_END
