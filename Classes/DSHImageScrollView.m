//
//  DSHImageScrollView.m
//  IPicker
//
//  Created by 路 on 2020/5/18.
//  Copyright © 2020 路. All rights reserved.
//

#import "DSHImageScrollView.h"

@interface DSHImageScrollView ()

@property (strong ,nonatomic) UIImageView *view;
@end

@implementation DSHImageScrollView
- (void)setDelegate:(id<UIScrollViewDelegate>)delegate; {
    if (delegate == self) {
        [super setDelegate:delegate];
    }
}
- (id)initWithImage:(UIImage *)image; {
    return [self initWithImage:image frame:CGRectZero];
}
- (id)initWithFrame:(CGRect)frame; {
    return [self initWithImage:nil frame:frame];
}
- (id)initWithImage:(UIImage *)image frame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        _image = image;
        _view = [[UIImageView alloc] initWithImage:_image];
        _view.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleClick:)];
        singleTap.numberOfTapsRequired = 1;
        [_view addGestureRecognizer:singleTap];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
        doubleTap.numberOfTapsRequired = 2;
        [_view addGestureRecognizer:doubleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [self addSubview:_view];
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    } return self;
}

- (void)setImage:(UIImage *)image; {
    _image = image;
    [self resetZoomScale];
}

- (void)resetZoomScale; {
    _view.transform = CGAffineTransformIdentity;
    _view.image = _image;
    if (_image.size.width > 0 && _image.size.height > 0) {
        CGRect frame = _view.frame;
        CGFloat image_wh = _image.size.width / _image.size.height;
        CGFloat screen_wh = self.bounds.size.width / self.bounds.size.height;
        CGFloat minimumZoomScale = 1.f;
        CGFloat maximumZoomScale = 1.f;
        if (image_wh > screen_wh) {
            if (self.contentMode == UIViewContentModeScaleAspectFit) {
                frame.size.width = self.bounds.size.width;
                frame.size.height = frame.size.width / image_wh;
                minimumZoomScale = 1.f;
                maximumZoomScale = self.bounds.size.height / MIN(frame.size.height, self.bounds.size.height * .5);
            } else {
                frame.size.height = self.bounds.size.height;
                frame.size.width = frame.size.height * image_wh;
                minimumZoomScale = 1.f;
                maximumZoomScale = minimumZoomScale + 2.f;
            }
        } else {
            if (self.contentMode == UIViewContentModeScaleAspectFit) {
                frame.size.height = self.bounds.size.height;
                frame.size.width = frame.size.height * image_wh;
                minimumZoomScale = 1.f;
                maximumZoomScale = self.bounds.size.width / MIN(frame.size.width, self.bounds.size.width * .5);
            } else {
                frame.size.width = self.bounds.size.width;
                frame.size.height = frame.size.width / image_wh;
                minimumZoomScale = 1.f;
                maximumZoomScale = minimumZoomScale + 2.f;
            }
        }
        _view.frame = frame;
        self.minimumZoomScale = minimumZoomScale;
        self.maximumZoomScale = maximumZoomScale;
    } else {
        self.minimumZoomScale = 1.f;
        self.maximumZoomScale = 1.f;
    }
    self.zoomScale = self.minimumZoomScale;
    [self scrollViewDidZoom:self]; // 手动触发缩放回调
}
#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView; {
    if (_scrollViewDidScrollBlock) {
        _scrollViewDidScrollBlock(self);
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView; {
    CGPoint center = CGPointMake(MAX(scrollView.contentSize.width, scrollView.bounds.size.width) * .5, MAX(scrollView.contentSize.height, scrollView.bounds.size.height) * .5);
    _view.center = center;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView; {
    return _view;
}
#pragma mark -
- (void)singleClick:(UITapGestureRecognizer *)tap; {
    BOOL handle = NO;
    if (_singleClickActionBlock) {
        handle = _singleClickActionBlock(self);
    }
    if (!handle) return;
    if (self.zoomScale != self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
}
- (void)doubleClick:(UITapGestureRecognizer *)tap; {
    BOOL handle = YES;
    if (_doubleClickActionBlock) {
        handle = _doubleClickActionBlock(self);
    }
    if (!handle) return;
    if (self.zoomScale != self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:_view];
        CGRect zoomToRect = (CGRect){0};
        if (self.maximumZoomScale > 0) {
            zoomToRect.size.width = self.frame.size.width / self.maximumZoomScale;
            zoomToRect.size.height = self.frame.size.height / self.maximumZoomScale;
        }
        zoomToRect.origin.x = touchPoint.x - zoomToRect.size.width * .5;
        zoomToRect.origin.y = touchPoint.y - zoomToRect.size.height * .5;
        [self zoomToRect:zoomToRect animated:YES];
    }
}
@end
