//
//  MapViewController.h
//  mapHouse
//
//  Created by duy on 2019/5/29.
//  Copyright © 2019 duy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^ReturnValueBlock) (NSDictionary * dic);
@interface MapViewController : UIViewController 
@property(nonatomic, copy) ReturnValueBlock returnValueBlock;
@end

NS_ASSUME_NONNULL_END
