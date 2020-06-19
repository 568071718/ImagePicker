//
//  DSHImagePickerEditImageController.m
//  IPicker
//
//  Created by 路 on 2020/5/18.
//  Copyright © 2020 路. All rights reserved.
//

#import "DSHImagePickerEditImageController.h"
#import "DSHImageScrollView.h"
#import "DSHImagePickerTimer.h"
#import <Masonry.h>

@interface _DSHSquareMaskLayer : CALayer
- (CGRect)squareRect;
@property (assign ,nonatomic) CGFloat cutScale;
@end
@implementation _DSHSquareMaskLayer
- (CGRect)squareRect; {
    if (_cutScale <= 0) {
        return CGRectZero;
    }
    CGRect result = CGRectZero;
    result.size.width = self.frame.size.width;
    result.origin.x = 0.f;
    result.size.height = result.size.width / _cutScale;
    result.origin.y = (self.frame.size.height - result.size.height) * .5;
    return result;
}
- (void)drawInContext:(CGContextRef)ctx; {
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillRect(ctx, self.bounds);
    CGContextClearRect(ctx, self.squareRect);
}
@end

@interface _DSHSquareGridLayer : CALayer
@end
@implementation _DSHSquareGridLayer
- (void)drawInContext:(CGContextRef)ctx; {
    CGRect rect = self.bounds;
    CGContextSetLineWidth(ctx, 1.f);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    for (int i = 0; i < 4; i ++) {
        CGFloat x = (rect.size.width / 3) * i;
        CGContextMoveToPoint(ctx, x, 0);
        CGContextAddLineToPoint(ctx, x, rect.size.height);

        CGFloat y = (rect.size.height / 3) * i;
        CGContextMoveToPoint(ctx, 0, y);
        CGContextAddLineToPoint(ctx, rect.size.width, y);
    }
    CGContextStrokePath(ctx);
}
@end

@interface DSHImagePickerEditImageController ()

@property (strong ,nonatomic) DSHImageScrollView *imageView;

@property (strong ,nonatomic) DSHImagePickerTimer *timer;
@property (strong ,nonatomic) UIVisualEffectView *visualEffectView;
@property (strong ,nonatomic) _DSHSquareMaskLayer *squareMaskLayer;
@property (strong ,nonatomic) _DSHSquareGridLayer *squareGridLayer;
@end

@implementation DSHImagePickerEditImageController
- (id)initWithImage:(UIImage *)image; {
    self = [super init];
    if (self) {
        _image = image;
        _cutScale = 1.f / 1.f;
    } return self;
}
- (id)init; {
    return [self initWithImage:nil];
}
#pragma mark -
- (void)viewDidLoad; {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    __weak typeof(self) _self = self;
    
    _imageView = [[DSHImageScrollView alloc] initWithImage:_image];
    _imageView.clipsToBounds = NO;
    _imageView.showsHorizontalScrollIndicator = NO;
    _imageView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        _imageView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [_imageView setScrollViewDidScrollBlock:^(DSHImageScrollView * _Nonnull scrollView) {
        [_self _began_scroll];
    }];
    [self.view addSubview:_imageView];
    
    // 添加蒙层
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    _visualEffectView.userInteractionEnabled = NO;
    [self.view addSubview:_visualEffectView];
    
    CGFloat contentsScale = [UIScreen mainScreen].scale;
    _squareMaskLayer = [_DSHSquareMaskLayer layer];
    _squareMaskLayer.cutScale = _cutScale;
    _squareMaskLayer.contentsScale = contentsScale;
    _visualEffectView.layer.mask = _squareMaskLayer;
    
    _squareGridLayer = [_DSHSquareGridLayer layer];
    _squareGridLayer.contentsScale = contentsScale;
    [self.view.layer addSublayer:_squareGridLayer];
    
    UIView *topBar = [[UIView alloc] init];
    topBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:topBar];
    
    UIView *topBarContentView = [[UIView alloc] init];
    [topBar addSubview:topBarContentView]; {
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton addTarget:self action:@selector(clickedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitle:@"取消" forState:0];
        [topBarContentView addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(topBarContentView).offset(15.f);
            make.centerY.equalTo(topBarContentView);
        }];
        UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [downButton addTarget:self action:@selector(clickedDownButton:) forControlEvents:UIControlEventTouchUpInside];
        [downButton setTitle:@"完成" forState:0];
        [topBarContentView addSubview:downButton];
        [downButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(topBarContentView).offset(-15.f);
            make.centerY.equalTo(topBarContentView);
        }];
    }
    [topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];
    [topBarContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(44.f));
        make.left.right.bottom.equalTo(topBar);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
}
- (void)viewWillAppear:(BOOL)animated; {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewWillDisappear:(BOOL)animated; {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLayoutSubviews; {
    [super viewDidLayoutSubviews];
    [self _reloadViews];
}

#pragma mark -
- (void)setImage:(UIImage *)image; {
    _image = image;
    _imageView.image = image;
    [self _reloadViews];
}
- (void)setCutScale:(CGFloat)cutScale; {
    _cutScale = cutScale;
    _squareMaskLayer.cutScale = cutScale;
    [self _reloadViews];
}
- (void)_reloadViews; {
    _visualEffectView.frame = self.view.bounds;
    _squareMaskLayer.frame = self.view.bounds;
    [_squareMaskLayer setNeedsDisplay];
    CGRect squareRect = _squareMaskLayer.squareRect;
    _squareGridLayer.frame = squareRect;
    [_squareGridLayer setNeedsDisplay];
    _imageView.frame = squareRect;
    [_imageView resetZoomScale];
    _imageView.contentOffset = ({
        CGFloat offsetX = MAX(0, (_imageView.contentSize.width - _imageView.bounds.size.width) * .5);
        CGFloat offsetY = MAX(0, (_imageView.contentSize.height - _imageView.bounds.size.height) * .5);
        CGPointMake(offsetX, offsetY);
    });
    [self _began_scroll];
}
#pragma mark -
- (void)_began_scroll; {
    if (!_timer) {
        __weak typeof(self) _self = self;
        _timer = [DSHImagePickerTimer timerWithTimeInterval:10.f userInfo:nil repeats:NO];
        [_timer setHandler:^(DSHImagePickerTimer *timerObject) {
            [_self _end_scroll];
        }];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.25];
        _visualEffectView.alpha = .5;
        _squareGridLayer.opacity = 1.f;
        [UIView commitAnimations];
    }
    NSTimeInterval fireDate = [[NSDate date] timeIntervalSince1970] + .5;
    _timer.timer.fireDate = [NSDate dateWithTimeIntervalSince1970:fireDate];
}
- (void)_end_scroll; {
    _timer = nil;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.25];
    _visualEffectView.alpha = 1.f;
    _squareGridLayer.opacity = 0.f;
    [UIView commitAnimations];
}
#pragma mark -
- (void)clickedCancelButton:(UIButton *)sender; {
    if (_clickedCancelButtonBlock) {
        _clickedCancelButtonBlock();
    }
}
- (void)clickedDownButton:(UIButton *)sender; {
    if (!_image || _timer) {
        return;
    }
    CGSize contentSize = _imageView.contentSize;
    CGRect squareRect = _squareMaskLayer.squareRect;
    CGFloat x = _imageView.contentOffset.x / contentSize.width;
    CGFloat y = _imageView.contentOffset.y / contentSize.height;
    CGFloat width = squareRect.size.width / contentSize.width;
    CGFloat height = squareRect.size.height / contentSize.height;
    CGSize imageSize = _image.size;
    CGRect cropRect = CGRectMake(imageSize.width * x, imageSize.height * y, imageSize.width * width, imageSize.height * height);
    CGImageRef cgImage = CGImageCreateWithImageInRect(_image.CGImage, cropRect);
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:_image.scale orientation:_image.imageOrientation];
    CGImageRelease(cgImage);
    if (_clickedDownButtonBlock) {
        _clickedDownButtonBlock(image);
    }
}
@end
