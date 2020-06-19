//
//  DSHImagePickerEditVideoTimeRangeView.m
//  IPicker
//
//  Created by 路 on 2020/5/19.
//  Copyright © 2020 路. All rights reserved.
//

#import "DSHImagePickerEditVideoTimeRangeView.h"
#import <Masonry.h>

enum {
    DRAG_NONE,
    DRAG_X,
    DRAG_MAX_X,
    DRAG_BODY,
};

// 裁切框
@interface _DSHImagePickerEditVideoTimeRangeViewDragMaskView : UIView
@end
@implementation _DSHImagePickerEditVideoTimeRangeViewDragMaskView
- (BOOL)isOpaque; {
    return NO;
}
- (void)drawRect:(CGRect)rect; {
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor colorWithRed:255 / 255.f green:40 / 255.f blue:103 / 255.f alpha:1.f];
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    CGFloat left = 22.f; CGFloat top = 6.f;
    CGContextClearRect(context, CGRectMake(left, top, self.frame.size.width - left * 2, self.frame.size.height -top * 2));
    
    CGContextMoveToPoint(context, 12.f, 25.f);
    CGContextAddLineToPoint(context, 12.f - 3.f, 35.f);
    CGContextAddLineToPoint(context, 12.f, 45.f);
    CGContextMoveToPoint(context, self.frame.size.width - 12.f, 25.f);
    CGContextAddLineToPoint(context, self.frame.size.width - 12.f + 3.f, 35.f);
    CGContextAddLineToPoint(context, self.frame.size.width - 12.f, 45.f);
    CGContextSetLineWidth(context, 3.f);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokePath(context);
}
@end


@interface DSHImagePickerEditVideoTimeRangeView ()
@property (strong ,nonatomic) UIView *frameImagesView;
@property (strong ,nonatomic) UIView *rangeView;
@property (strong ,nonatomic) _DSHImagePickerEditVideoTimeRangeViewDragMaskView *dragMaskView;

// 记录拖动参数
@property (assign ,nonatomic) CGFloat touch_began_x;
@property (assign ,nonatomic) CGRect touch_began_range_view_frame;
@property (assign ,nonatomic) NSInteger dragMode;

// 播放进度
@property (strong ,nonatomic) UIView *progressLine;
@end

@implementation DSHImagePickerEditVideoTimeRangeView

- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor colorWithRed:47 / 255.f green:47 / 255.f blue:47 / 255.f alpha:1.f];
        backgroundView.layer.cornerRadius = 4.f;
        backgroundView.layer.masksToBounds = YES;
        [self addSubview:backgroundView];
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self).offset(16.f);
            make.right.equalTo(self).offset(-16.f);
        }];
        _frameImagesView = [[UIView alloc] init];
        [self addSubview:_frameImagesView];
        [_frameImagesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.insets(UIEdgeInsetsMake(6.f, 22, 6.f, 22));
        }];
        _rangeView = [[UIView alloc] init];
        [self addSubview:_rangeView];
        _dragMaskView = [[_DSHImagePickerEditVideoTimeRangeViewDragMaskView alloc] init];
        _dragMaskView.layer.cornerRadius = 4.f;
        _dragMaskView.layer.masksToBounds = YES;
        _dragMaskView.contentMode = UIViewContentModeRedraw;
        [self addSubview:_dragMaskView];
    } return self;
}
- (void)layoutSubviews; {
    [super layoutSubviews];
    if (_frameImagesView.subviews.count > 0) {
        for (int i = 0; i < _frameImagesView.subviews.count; i ++) {
            UIImageView *view = _frameImagesView.subviews[i];
            CGFloat y = 0.f;
            CGFloat width = _frameImagesView.frame.size.width / _frameImagesView.subviews.count;
            CGFloat x = i * width;
            CGFloat height = _frameImagesView.frame.size.height;
            view.frame = CGRectMake(x, y, width, height);
        }
    }
}
- (void)setBackgroundImages:(NSArray <UIImage *>*)images; {
    [_frameImagesView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (UIImage *image in images) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [_frameImagesView addSubview:imageView];
    }
    [self setNeedsLayout];
}
- (void)set; {
    CGFloat width = (self.frame.size.width - 22.f * 2);
    CGRect frame = _rangeView.frame;
    frame.origin.x = 22.f + width * _start;
    frame.origin.y = 0.f;
    frame.size.height = self.frame.size.height;
    frame.size.width = width * _width;
    _rangeView.frame = frame;
    [self _rangeViewDidChanged];
}
- (void)setProgress:(CGFloat)progress; {
    CGFloat width = 4.f;
    if (!_progressLine) {
        _progressLine = [[UIView alloc] init];
        _progressLine.backgroundColor = [UIColor whiteColor];
        _progressLine.layer.cornerRadius = width * .5;
        _progressLine.layer.masksToBounds = YES;
        [_rangeView addSubview:_progressLine];
    }
    CGRect frame = CGRectZero;
    frame.origin.x = _rangeView.frame.size.width * progress;
    frame.origin.y = 6.f;
    frame.size.width = width;
    frame.size.height = _rangeView.frame.size.height - frame.origin.y * 2;
    _progressLine.frame = frame;
    _progressLine.hidden = (progress <= 0);
}
#pragma mark -
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event; {
    UITouch *anyTouch = [touches anyObject];
    CGPoint touchInSelf = [anyTouch locationInView:self];
    CGPoint touchInRangeView = [anyTouch locationInView:_rangeView];
    _touch_began_x = touchInSelf.x;
    _touch_began_range_view_frame = _rangeView.frame;
    _dragMode = DRAG_NONE;
    if (touchInRangeView.x > -22.f && touchInRangeView.x < 0.f) {
        _dragMode = DRAG_X;
    } else if (touchInRangeView.x > _touch_began_range_view_frame.size.width && touchInRangeView.x < _touch_began_range_view_frame.size.width + 22.f) {
        _dragMode = DRAG_MAX_X;
    } else if (CGRectContainsPoint(_touch_began_range_view_frame, touchInSelf)) {
        _dragMode = DRAG_BODY;
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event; {
    CGFloat main_width = (self.frame.size.width - 22.f * 2);
    CGFloat max_width = main_width * _maximumWidth;
    CGFloat min_width = main_width * _minimumWidth;
    CGRect newFrame = _touch_began_range_view_frame;
    CGFloat distance = [touches.anyObject locationInView:self].x - _touch_began_x;
    if (_dragMode == DRAG_X) {
        CGFloat maxX = CGRectGetMaxX(_touch_began_range_view_frame);
        CGFloat x = newFrame.origin.x + distance;
        CGFloat width = newFrame.size.width - distance;
        if (width > max_width) {
            width = max_width;
            x = maxX - width;
        } else if (width < min_width) {
            width = min_width;
            x = maxX - width;
        } else if (x < 22.f) {
            x = 22.f;
            width = maxX - x;
        }
        newFrame.origin.x = x;
        newFrame.size.width = width;
    } else if (_dragMode == DRAG_MAX_X) {
        CGFloat width = newFrame.size.width + distance;
        if (width < min_width) width = min_width;
        if (width > max_width) width = max_width;
        if (newFrame.origin.x + width > self.frame.size.width - 22.f) width = self.frame.size.width - 22.f - newFrame.origin.x;
        newFrame.size.width = width;
    } else if (_dragMode == DRAG_BODY) {
        CGFloat x = newFrame.origin.x + distance;
        if (x < 22.f) x = 22.f;
        if (x + newFrame.size.width > self.frame.size.width - 22.f) x = self.frame.size.width - 22.f - newFrame.size.width;
        newFrame.origin.x = x;
    }
    _rangeView.frame = newFrame;
    // 计算新的值
    CGFloat start = (newFrame.origin.x - 22.f) / main_width;
    CGFloat width = newFrame.size.width / main_width;
    if (_start != start || _width != width) {
        _start = start;
        _width = width;
        [self _rangeViewDidChanged];
    }
}

#pragma mark -
- (void)_rangeViewDidChanged; {
    // 调整裁切框框的位置
    _dragMaskView.frame = CGRectMake(_rangeView.frame.origin.x - 22.f, 0.f, _rangeView.frame.size.width + 22 * 2, self.frame.size.height);
    if (_rangeDidChangeBlock) {
        _rangeDidChangeBlock(_start ,_width);
    }
}
@end
