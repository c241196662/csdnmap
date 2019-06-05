//
//  ZFMessageAnnotationView.m
//  mapHouse
//
//  Created by duy on 2019/5/29.
//  Copyright © 2019 duy. All rights reserved.
//

#import "ZFMessageAnnotationView.h"

@interface ZFMessageAnnotationView ()

@property(nonatomic, strong) UILabel *contentView;

@end


@implementation ZFMessageAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        [self setBounds:CGRectMake(0.f, 0.f, 1, 1)];
        [self setContentView];
        self.canShowCallout = NO;
        UIColor *color = [UIColor colorWithWhite:0.5 alpha:1];
        self.layer.cornerRadius = 3;
        self.layer.borderColor = color.CGColor;
        self.layer.borderWidth = 1;
        self.layer.masksToBounds = YES;
    }
    return self;
}


//- (void)setContentView {
//
//    self.contentView = [[UILabel alloc] init];
//    self.contentView.font = [UIFont systemFontOfSize:10];
//    self.contentView.frame = CGRectMake(0.f, 0.f, 100, 12);
//    self.contentView.textColor = [UIColor whiteColor];
//    self.contentView.backgroundColor = [UIColor redColor];
//    self.contentView.textAlignment = NSTextAlignmentCenter;
//    [self addSubview:self.contentView];
//    [self setBounds:self.contentView.bounds];
//
//}
//- (void)setTitle:(NSString *)title {
//    _title = title;
//    self.contentView.text = title;
//}
//
- (void)setContentView {

    
    for(UIView * view in [self subviews])
    {
        [view removeFromSuperview];
    }
    self.contentView = [[UILabel alloc] init];
    self.contentView.font = [UIFont systemFontOfSize:15];
    self.contentView.frame = CGRectMake(0.f, 0.f, 50, 12);
    self.contentView.textColor = [UIColor blackColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.text = self.title;
    [self.contentView sizeToFit];
    [self addSubview:self.contentView];
    [self setBounds:self.contentView.bounds];

}
- (void)setTitle:(NSString *)title {
    _title = title;
    [self setContentView];
}

- (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
