//
//  ZFRoundAnnotationView.m
//  mapHouse
//
//  Created by duy on 2019/5/29.
//  Copyright © 2019 duy. All rights reserved.
//

#import "ZFRoundAnnotationView.h"

@interface ZFRoundAnnotationView ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;

@end

@implementation ZFRoundAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        [self setBounds:CGRectMake(0.f, 0.f, 50, 50)];
        [self setContentView];
        self.canShowCallout = NO;
    }
    return self;
}

- (void)setContentView {
    
    UIColor *color = [UIColor colorWithWhite:0.5 alpha:1];
    self.layer.cornerRadius = 25;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 1;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)/2.5)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.layer.masksToBounds = YES;
    [self addSubview:self.titleLabel];
    
    self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)/3)];
    
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.font = [UIFont systemFontOfSize:9];
    self.subTitleLabel.textColor = [UIColor blackColor];
    self.subTitleLabel.layer.masksToBounds = YES;
    [self addSubview:self.subTitleLabel];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}
- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    self.subTitleLabel.text = subTitle;
}
@end
