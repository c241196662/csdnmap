//
//  ZFRoundAnnotationView.h
//  mapHouse
//
//  Created by duy on 2019/5/29.
//  Copyright © 2019 duy. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFRoundAnnotationView : BMKAnnotationView
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *subTitle;
@end

NS_ASSUME_NONNULL_END
