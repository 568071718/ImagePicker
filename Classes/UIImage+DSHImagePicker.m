//
//  UIImage+DSHImagePicker.m
//  IPicker
//
//  Created by 路 on 2020/5/14.
//  Copyright © 2020 路. All rights reserved.
//

#import "UIImage+DSHImagePicker.h"

@implementation UIImage (DSHImagePicker)
+ (UIImage *)dsh_X; {
    CGRect canvasRect = CGRectMake(0, 0, 44.f, 44.f);
    CGRect rect = CGRectMake(16, 16, 12, 12);
    UIGraphicsBeginImageContextWithOptions(canvasRect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    
    CGContextMoveToPoint(context, CGRectGetMaxX(rect), rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x, CGRectGetMaxY(rect));
    
    UIColor *strokeColor = [UIColor colorWithRed:153 / 255.f green:153 / 255.f blue:153 / 255.f alpha:1.f];
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineWidth(context, 2.f);
    CGContextStrokePath(context);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
+ (UIImage *)dsh_pauseImage; {
    CGRect rect = CGRectMake(0, 0, 60, 40);
    UIColor *color = [[UIColor whiteColor] colorWithAlphaComponent:.8];
    
    CGFloat x1 = (rect.size.width / 3) * 1;
    CGFloat x2 = (rect.size.width / 3) * 2;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, x1, 0);
    CGContextAddLineToPoint(context, x1, rect.size.height);
    
    CGContextMoveToPoint(context, x2, 0);
    CGContextAddLineToPoint(context, x2, rect.size.height);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, rect.size.width / 5.f);
    CGContextStrokePath(context);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
+ (UIImage *)dsh_playImage; {
    CGRect rect = CGRectMake(0, 0, 40, 40);
    UIColor *color = [[UIColor whiteColor] colorWithAlphaComponent:.8];
    CGPoint triangleP1 = CGPointMake(0, 0);
    CGPoint triangleP2 = CGPointMake(0, rect.size.height);
    CGPoint triangleP3 = CGPointMake(rect.size.width, rect.size.height * .5);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, triangleP1.x, triangleP1.y);
    CGContextAddLineToPoint(context, triangleP2.x, triangleP2.y);
    CGContextAddLineToPoint(context, triangleP3.x, triangleP3.y);
    CGContextClosePath(context);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
+ (UIImage *)dsh_ring; {
    CGRect rect = CGRectMake(0, 0, 20, 20);
    UIColor *color = [UIColor whiteColor];
    
    CGFloat line_width = 1.f;
    CGRect line_rect = CGRectZero;
    line_rect.origin.x = line_width;
    line_rect.origin.y = line_width;
    line_rect.size.width = rect.size.width - line_rect.origin.x * 2;
    line_rect.size.height = rect.size.height - line_rect.origin.y * 2;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, line_width);
    CGContextStrokeEllipseInRect(context, line_rect);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
+ (UIImage *)dsh_ring_full; {
    CGRect rect = CGRectMake(0, 0, 20, 20);
    UIColor *line_color = [UIColor whiteColor];
    UIColor *full_color = [UIColor colorWithRed:255 / 255.f green:40 / 255.f blue:103 / 255.f alpha:1];
    
    CGFloat line_width = 1.f;
    CGRect line_rect = CGRectZero;
    line_rect.origin.x = line_width;
    line_rect.origin.y = line_width;
    line_rect.size.width = rect.size.width - line_rect.origin.x * 2;
    line_rect.size.height = rect.size.height - line_rect.origin.y * 2;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, line_color.CGColor);
    CGContextSetLineWidth(context, line_width);
    CGContextStrokeEllipseInRect(context, line_rect);
    
    CGRect full_rect = CGRectZero;
    full_rect.origin.x = line_rect.origin.x + 2.f;
    full_rect.origin.y = line_rect.origin.y + 2.f;
    full_rect.size.width = rect.size.width - full_rect.origin.x * 2;
    full_rect.size.height = rect.size.height - full_rect.origin.y * 2;
    CGContextSetFillColorWithColor(context, full_color.CGColor);
    CGContextFillEllipseInRect(context, full_rect);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
@end
