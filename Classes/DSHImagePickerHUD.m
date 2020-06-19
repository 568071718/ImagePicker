//
//  DSHImagePickerHUD.m
//  IPicker
//
//  Created by 路 on 2020/5/30.
//  Copyright © 2020 路. All rights reserved.
//

#import "DSHImagePickerHUD.h"

@interface _DSHImagePickerHUDView : UIView
@property (strong ,nonatomic) NSAttributedString *message;
@property (strong ,nonatomic) UIView *contentView;
@property (strong ,nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong ,nonatomic) UILabel *label;
@end
@implementation _DSHImagePickerHUDView
- (id)initWithFrame:(CGRect)frame; {
    frame = UIScreen.mainScreen.bounds;
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = nil;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7];
        _contentView.layer.cornerRadius = 10.f;
        _contentView.layer.masksToBounds = YES;
        [self addSubview:_contentView];
        
        UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleWhite;
        if (@available(iOS 13.0, *)) {
            style = UIActivityIndicatorViewStyleMedium;
        }
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        _indicatorView.color = [UIColor whiteColor];
        _indicatorView.transform = CGAffineTransformMakeScale(2.f, 2.f);
        _indicatorView.center = CGPointMake(_contentView.frame.size.width * .5, _contentView.frame.size.height * .5);
        [_indicatorView startAnimating];
        [_contentView addSubview:_indicatorView];
    } return self;
}
- (void)layoutSubviews; {
    [super layoutSubviews];
    _contentView.center = CGPointMake(self.frame.size.width * .5, self.frame.size.height * .5);
    if (_message.length > 0) {
        if (!_label) {
            _label = [[UILabel alloc] init];
            [_contentView addSubview:_label];
        }
        _label.attributedText = _message;
        // 计算文字宽度并改变 content view 的大小
        CGFloat message_width = _message.size.width;
        CGFloat content_view_width = MAX(100.f, message_width + 40.f);
        _contentView.bounds = CGRectMake(0, 0, content_view_width, 100.f);
        _indicatorView.center = CGPointMake(_contentView.frame.size.width * .5, _contentView.frame.size.height * .5 - 15.f);
        _label.bounds = CGRectMake(0, 0, message_width, _message.size.height);
        _label.center = CGPointMake(_contentView.frame.size.width * .5, _contentView.frame.size.height - 15.f - _label.frame.size.height * .5);
    } else {
        _label.attributedText = nil;
        _contentView.bounds = CGRectMake(0, 0, 100, 100);
        _indicatorView.center = CGPointMake(_contentView.frame.size.width * .5, _contentView.frame.size.height * .5);
    }
}
@end


@implementation DSHImagePickerHUD
+ (UIView *)superview; {
    return UIApplication.sharedApplication.delegate.window;
}
+ (BOOL)isDisplay; {
    return ([DSHImagePickerHUD _currentHUDView] != nil);
}
+ (void)show; {
    [self showMessage:nil];
}
+ (void)showMessage:(NSString *)message; {
    _DSHImagePickerHUDView *view = [self _currentHUDView];
    if (!view) {
        view = [[_DSHImagePickerHUDView alloc] init];
        [DSHImagePickerHUD.superview addSubview:view];
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        anim.values = @[@(0) ,@(1)];
        anim.duration = .25;
        [view.layer addAnimation:anim forKey:nil];
    }
    if ([message isKindOfClass:[NSString class]]) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:message attributes:@{
            NSFontAttributeName:[UIFont systemFontOfSize:15],
            NSForegroundColorAttributeName:[UIColor whiteColor],
        }];
        view.message = string;
    } else {
        view.message = nil;
    }
    [view setNeedsLayout];
}
+ (void)hide; {
    [[self _currentHUDView] removeFromSuperview];
}
+ (_DSHImagePickerHUDView *)_currentHUDView; {
    for (_DSHImagePickerHUDView *view in DSHImagePickerHUD.superview.subviews) {
        if ([view isKindOfClass:[_DSHImagePickerHUDView class]]) {
            return view;
        }
    }
    return nil;
}
@end
