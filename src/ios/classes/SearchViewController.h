//
//  SearchViewController.h
//  mapHouse
//
//  Created by duy on 2019/6/3.
//  Copyright © 2019 duy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ReturnValueBlock) (NSDictionary * dic);

@interface SearchViewController : UIViewController

@property(nonatomic, copy) ReturnValueBlock returnValueBlock;

@end

NS_ASSUME_NONNULL_END
