//
//  DSHImagePickerProgressView.m
//  IPicker
//
//  Created by 路 on 2020/1/15.
//  Copyright © 2020年 路. All rights reserved.
//

#import "DSHImagePickerProgressView.h"

@interface DSHImagePickerProgressView ()
@end

@implementation DSHImagePickerProgressView
+ (Class)layerClass; {
    return [CAShapeLayer class];
}

- (CGSize)intrinsicContentSize; {
    return CGSizeMake(50, 50);
}

- (BOOL)isOpaque; {
    return NO;
}

- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    } return self;
}

- (void)setup; {
    
    UIColor *defaultMainColor = [UIColor whiteColor];
    
    self.lineWidth = 3.f;
    self.lineColor = defaultMainColor;
    self.backgroundColor = nil;
    self.progress = 0;
    
    CGFloat fontSize = 10.f;
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    if (!font) font = [UIFont systemFontOfSize:fontSize];
    self.attributes = @{NSFontAttributeName:font,NSForegroundColorAttributeName:defaultMainColor};
}

- (void)layoutSubviews; {
    [super layoutSubviews];
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.lineWidth, self.lineWidth, self.frame.size.width - self.lineWidth * 2, self.frame.size.height - self.lineWidth * 2)].CGPath;
}

- (void)setProgress:(CGFloat)progress; {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated; {
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.strokeEnd = progress;
    if (animated) {
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
        anim.values = @[@(_progress) ,@(progress)];
        anim.duration = .2;
        anim.removedOnCompletion = NO;
        [layer addAnimation:anim forKey:nil];
    }
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth; {
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.lineWidth = lineWidth;
}

- (CGFloat)lineWidth; {
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    return layer.lineWidth;
}

- (void)setLineColor:(UIColor *)lineColor; {
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.strokeColor = lineColor.CGColor;
}

- (UIColor *)lineColor; {
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    return [UIColor colorWithCGColor:layer.strokeColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor; {
    [super setBackgroundColor:backgroundColor];
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.fillColor = backgroundColor.CGColor;
}

- (void)drawRect:(CGRect)rect; {
    NSString *text = [NSString stringWithFormat:@"%02ld%%" ,(long)(_progress * 100)];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:_attributes];
    CGPoint atPoint = CGPointMake((self.frame.size.width - string.size.width) * .5, (self.frame.size.height - string.size.height) * .5);
    [string drawAtPoint:atPoint];
}

@end
