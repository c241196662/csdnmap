//
//  MapViewController.m
//  mapHouse
//
//  Created by duy on 2019/5/29.
//  Copyright © 2019 duy. All rights reserved.
//

#import "MapViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import "ZFRoundAnnotationView.h"
#import "ZFMessageAnnotationView.h"
#import <objc/message.h>
#import "Masonry.h"
#import "SearchViewController.h"

#define zoomLevelmin 14.5
#define zoomLevelmax 15.5

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface MapViewController ()<BMKGeneralDelegate, BMKMapViewDelegate, BMKLocationAuthDelegate, BMKLocationManagerDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong) BMKMapManager *mapManager; //主引擎类
@property (nonatomic, strong) BMKMapView *mapView; //地图

@property (nonatomic, strong) BMKLocationManager *locationManager; //定位对象
@property (nonatomic, strong) BMKUserLocation *userLocation; //当前位置对象

@property (nonatomic, assign) float zoomValue; //层级
@property (nonatomic, assign) CLLocationCoordinate2D oldCoor; //中心点


@property (nonatomic, strong) UIButton * locationButton;
@property (nonatomic, strong) UISlider * rangeSlider;
@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, strong) UIButton * screenButton;
@property (nonatomic, strong) UIButton * subwayButton;

@property (nonatomic, strong) BMKCircle *circle; //锚点的圈
@property (nonatomic, assign) double circleRadius; //圈的半径
@property (nonatomic, copy) NSString * distance;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate; //定位点

@property (nonatomic, copy) NSString * screenString1;//价格
@property (nonatomic, copy) NSString * screenString2;//类型
@property (nonatomic, copy) NSString * screenString3;//面积
@property (nonatomic, copy) NSString * screenString4;//品牌

@property (nonatomic, strong) NSArray * listArr; //小区
@property (nonatomic, assign) BOOL showAllMode; //
@property (nonatomic, assign) BOOL screenViewFlag; //

@property (nonatomic, strong) UIButton * maskView;
@property (nonatomic, strong) UIView * screenView;

@property (nonatomic, strong) NSArray * cqArr; //
@property (nonatomic, strong) NSArray * subArr; //
@property (nonatomic, strong) NSArray * sqArr; //

@property (nonatomic, strong) NSMutableDictionary * pickerViewData; //
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *pickerComponent;
@property (nonatomic, strong) NSDictionary *pickerSelectDic;
@property (nonatomic, strong) UIButton *pickerCancelButton;
@property (nonatomic, strong) UIButton *pickerOKButton;

@property (nonatomic, strong) NSMutableDictionary * subwayData; //

@property (nonatomic, assign) long houseCOunt; //


//screenView
@property (nonatomic, strong) UIView * screenBottomView;
@property (nonatomic, strong) UIButton * screenCancelButton;
@property (nonatomic, strong) UIButton * screenOKButton;

@property (nonatomic, strong) UILabel * screenLabel1;
@property (nonatomic, strong) UILabel * screenLabel2;
@property (nonatomic, strong) UILabel * screenLabel3;
@property (nonatomic, strong) UILabel * screenLabel4;

@property (nonatomic, strong) UIButton * screenButton1;
@property (nonatomic, strong) UIButton * screenButton2;
@property (nonatomic, strong) UIButton * screenButton3;
@property (nonatomic, strong) UIButton * screenButton4;
@property (nonatomic, strong) UIButton * screenButton5;
@property (nonatomic, strong) UIButton * screenButton6;
@property (nonatomic, strong) UIButton * screenButton7;
@property (nonatomic, strong) UIButton * screenButton8;
@property (nonatomic, strong) UIButton * screenButton9;
@property (nonatomic, strong) UIButton * screenButton10;
@property (nonatomic, strong) UIButton * screenButton11;
@property (nonatomic, strong) UIButton * screenButton12;
@property (nonatomic, strong) UIButton * screenButton13;
@property (nonatomic, strong) UIButton * screenButton14;
@property (nonatomic, strong) UIButton * screenButton15;
@property (nonatomic, strong) UIButton * screenButton16;
@property (nonatomic, strong) UIButton * screenButton17;
@property (nonatomic, strong) UIButton * screenButton18;
@property (nonatomic, strong) UIButton * screenButton19;
@property (nonatomic, strong) UIButton * screenButton20;
@property (nonatomic, strong) UIButton * screenButton21;
@property (nonatomic, strong) UIButton * screenButton22;
@property (nonatomic, strong) UIButton * screenButton23;
@property (nonatomic, strong) UIButton * screenButton24;

@property (nonatomic, strong) UITextField * screenTextField1;
@property (nonatomic, strong) UITextField * screenTextField2;

@end

@implementation MapViewController

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    // title
    self.title = @"地图找房";
    _screenViewFlag = YES;
    self.screenString1 = @"";
    self.screenString2 = @"";
    self.screenString3 = @"";
    self.screenString4 = @"";
    //开启定位服务
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:@"pdUSYdyu286m5G63pIRzto1zYaZhfdCK" authDelegate:self];

    //要使用百度地图，请先启动BMKMapManager
    self.mapManager = [[BMKMapManager alloc] init];
    
    
    //启动引擎并设置AK并设置delegate
    BOOL result = [self.mapManager start:@"pdUSYdyu286m5G63pIRzto1zYaZhfdCK" generalDelegate:self];
    if (!result) {
        NSLog(@"启动引擎失败");
    }
    
    //创建地图
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    if ([BMKMapManager setCoordinateTypeUsedInBaiduMapSDK:BMK_COORDTYPE_BD09LL]) {
        NSLog(@"经纬度类型设置成功");
    } else {
        NSLog(@"经纬度类型设置失败");
    }
    
    [self resetPosition];
    
    //UI..
    [self.view addSubview:self.locationButton];
//    [self.view addSubview:self.searchButton];
//    [self.view addSubview:self.screenButton];
    [self.navigationController.navigationBar addSubview:self.searchButton];
    [self.navigationController.navigationBar addSubview:self.screenButton];
    
    [self.view addSubview:self.rangeSlider];
    [self.view addSubview:self.subwayButton];
    
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.screenView];
    [self layoutUI];
    
    
    [self requestPickviewData];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenButton.hidden = NO;
    self.searchButton.hidden = NO;
    [_mapView viewWillAppear];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.screenButton.hidden = YES;
    self.searchButton.hidden = YES;
    [_mapView viewWillDisappear];
}
#pragma mark - UI

- (void)layoutUI{
    
    [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(30);
//        make.top.equalTo(self.view).with.offset(10);
//        make.right.equalTo(self.view).with.offset(-10);
        make.bottom.equalTo(self.rangeSlider.mas_top).with.offset(-15);
        make.width.height.equalTo(@40);
    }];
    
    [self.searchButton setFrame:CGRectMake(kWidth-110, 5, 35, 35)];
    [self.screenButton setFrame:CGRectMake(kWidth-60, 5, 35, 35)];
    
    

    
    [self.rangeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(30);
        //        make.top.equalTo(self.view).with.offset(10);
        //        make.right.equalTo(self.view).with.offset(-10);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).with.offset(-30);
        make.height.equalTo(@40);
//        make.width.equalTo(@180);
    }];
    
    [self.subwayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.rangeSlider.mas_right).with.offset(30);
        //        make.top.equalTo(self.view).with.offset(10);
        //        make.right.equalTo(self.view).with.offset(-10);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).with.offset(-30);
        make.width.equalTo(@120);
        make.height.equalTo(@40);
        make.right.equalTo(self.view).offset(-30);
    }];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    [self layoutScreenUI];
    
}

- (void)layoutScreenUI{
    [self.screenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view.mas_right);
        make.width.equalTo(@300);
    }];
    
    
    UIScrollView * scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 800)];
    view.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview: view];
    scrollView.contentSize = view.bounds.size;
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.screenView addSubview: scrollView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.screenView);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-50);
    }];
    
    [self.screenView addSubview: self.screenBottomView];
    [self.screenView addSubview: self.screenCancelButton];
    [self.screenView addSubview: self.screenOKButton];
    
    // bottom
    [self.screenBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.screenView);
        make.top.equalTo(scrollView.mas_bottom);
        make.height.equalTo(@1);
    }];
    
    [self.screenCancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenView.mas_left).offset(20);
        make.top.equalTo(self.screenBottomView.mas_bottom).offset(10);
        make.width.equalTo(@100);
        make.height.equalTo(@30);
    }];
    
    [self.screenOKButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenCancelButton.mas_right).offset(20);
        make.top.equalTo(self.screenBottomView.mas_bottom).offset(10);
        make.width.equalTo(@100);
        make.height.equalTo(@30);
    }];
    
    [view addSubview:self.screenLabel1];
    [view addSubview:self.screenLabel2];
    [view addSubview:self.screenLabel3];
    [view addSubview:self.screenLabel4];
    
    [view addSubview:self.screenButton1];
    [view addSubview:self.screenButton2];
    [view addSubview:self.screenButton3];
    [view addSubview:self.screenButton4];
    [view addSubview:self.screenButton5];
    [view addSubview:self.screenButton6];
    [view addSubview:self.screenButton7];
    [view addSubview:self.screenButton8];
    [view addSubview:self.screenButton9];
    [view addSubview:self.screenButton10];
    [view addSubview:self.screenButton11];
    [view addSubview:self.screenButton12];
    [view addSubview:self.screenButton13];
    [view addSubview:self.screenButton14];
    [view addSubview:self.screenButton15];
    [view addSubview:self.screenButton16];
    [view addSubview:self.screenButton17];
    [view addSubview:self.screenButton18];
    [view addSubview:self.screenButton19];
    [view addSubview:self.screenButton20];
    [view addSubview:self.screenButton21];
    [view addSubview:self.screenButton22];
    [view addSubview:self.screenButton23];
    [view addSubview:self.screenButton24];
    
    [view addSubview:self.screenTextField1];
    [view addSubview:self.screenTextField2];
    
    //*******   1   *******//
    [self.screenLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(view).offset(20);
        make.width.equalTo(@120);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenLabel1.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton1.mas_right).offset(20);
        make.top.equalTo(self.screenLabel1.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton2.mas_right).offset(20);
        make.top.equalTo(self.screenLabel1.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenButton1.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton1.mas_right).offset(20);
        make.top.equalTo(self.screenButton1.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
//    [self.screenTextField1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(view).offset(20);
//        make.top.equalTo(self.screenButton4.mas_bottom).offset(20);
//        make.width.equalTo(@100);
//        make.height.equalTo(@30);
//    }];
//
//    [self.screenTextField2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.screenTextField1.mas_right).offset(20);
//        make.top.equalTo(self.screenButton4.mas_bottom).offset(20);
//        make.width.equalTo(@100);
//        make.height.equalTo(@30);
//    }];
    
    [self.screenTextField1 setFrame:CGRectMake(20, 180, 88, 30)];
    [self.screenTextField2 setFrame:CGRectMake(150, 180, 88, 30)];
    //*******   2   *******//
    [self.screenLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenTextField1.mas_bottom).offset(20);
        make.width.equalTo(@250);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenLabel2.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton7 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton1.mas_right).offset(20);
        make.top.equalTo(self.screenLabel2.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton8 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton2.mas_right).offset(20);
        make.top.equalTo(self.screenLabel2.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    //*******   3   *******//
    [self.screenLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenButton8.mas_bottom).offset(20);
        make.width.equalTo(@250);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton9 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenLabel3.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton10 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton1.mas_right).offset(20);
        make.top.equalTo(self.screenLabel3.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton11 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton2.mas_right).offset(20);
        make.top.equalTo(self.screenLabel3.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton12 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenButton9.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton13 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton1.mas_right).offset(20);
        make.top.equalTo(self.screenButton9.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton14 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton2.mas_right).offset(20);
        make.top.equalTo(self.screenButton9.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton15 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenButton12.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton16 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton1.mas_right).offset(20);
        make.top.equalTo(self.screenButton12.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    

    //*******   4   *******//
    [self.screenLabel4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenButton16.mas_bottom).offset(20);
        make.width.equalTo(@250);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton17 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenLabel4.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton18 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton1.mas_right).offset(20);
        make.top.equalTo(self.screenLabel4.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton19 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton2.mas_right).offset(20);
        make.top.equalTo(self.screenLabel4.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton20 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenButton17.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton21 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton1.mas_right).offset(20);
        make.top.equalTo(self.screenButton17.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton22 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton2.mas_right).offset(20);
        make.top.equalTo(self.screenButton17.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton23 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(20);
        make.top.equalTo(self.screenButton22.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];
    
    [self.screenButton24 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.screenButton1.mas_right).offset(20);
        make.top.equalTo(self.screenButton22.mas_bottom).offset(20);
        make.width.equalTo(@70);
        make.height.equalTo(@30);
    }];

}

#pragma mark - method
//request pickview data
- (void)requestPickviewData{
    NSURL *url = [NSURL URLWithString:@"http://jia3.tmsf.com/hzf/hzf_subway.jspx"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            weakSelf.subArr = [[NSArray alloc] initWithArray:[dict objectForKey:@"list"]];
            
            NSMutableArray * mutableArr11 = [[NSMutableArray alloc] init];
            NSMutableArray * mutableArr12 = [[NSMutableArray alloc] init];
            NSMutableArray * mutableArr2 = [[NSMutableArray alloc] init];
            NSMutableArray * mutableArr4 = [[NSMutableArray alloc] init];
            
            for (NSDictionary * dic in weakSelf.subArr) {
                if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"psubid"]] isEqualToString:@"1"]) {
                    [mutableArr11 addObject:dic];
                    [mutableArr12 addObject:dic];
                } else if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"psubid"]] isEqualToString:@"2"]) {
                    [mutableArr2 addObject:dic];
                }else if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"psubid"]] isEqualToString:@"4"]) {
                    [mutableArr4 addObject:dic];
                }
            }
            
            
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"乔司南"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"乔司"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"翁梅"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"余杭高铁站"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"南苑"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"临平"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            
            //
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"下沙西"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"金沙湖"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"高沙路"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"文泽路"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"文海南路"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"云水"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"下沙江滨"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            
    
            [mutableArr11 insertObject:@{@"subname":@"全部",@"subid":@"999911"} atIndex:0];
            [mutableArr12 insertObject:@{@"subname":@"全部",@"subid":@"999912"} atIndex:0];
            [mutableArr2 insertObject:@{@"subname":@"全部",@"subid":@"99992"} atIndex:0];
            [mutableArr4 insertObject:@{@"subname":@"全部",@"subid":@"99994"} atIndex:0];
            
            self.pickerSelectDic = @{@"subname":@"全部",@"subid":@"999911"};
            
            self.pickerViewData = [[NSMutableDictionary alloc] init];
            [self.pickerViewData setValue:mutableArr11 forKey:@"11"];
            [self.pickerViewData setValue:mutableArr12 forKey:@"12"];
            [self.pickerViewData setValue:mutableArr2 forKey:@"2"];
            [self.pickerViewData setValue:mutableArr4 forKey:@"4"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self creatPickView];
            });
            
            
        }
    }];
    [dataTask resume];
}
//创建pickview
- (void)creatPickView{
    self.pickerComponent = [[NSArray alloc] initWithArray:[self.pickerViewData objectForKey:@"11"]];
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.view addSubview:self.pickerView];
    self.pickerView.hidden = YES;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    self.pickerOKButton = [[UIButton alloc] init];
    [self.pickerOKButton setTitle:@"确认" forState:UIControlStateNormal];
    [self.pickerOKButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.pickerOKButton addTarget:self action:@selector(pickOK) forControlEvents:UIControlEventTouchUpInside];
    self.pickerOKButton.hidden = YES;
//    self.pickerOKButton = [UIColor yellowColor];
    [self.view addSubview:self.pickerOKButton];
    
    self.pickerCancelButton = [[UIButton alloc] init];
    [self.pickerCancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.pickerCancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.pickerCancelButton addTarget:self action:@selector(hiddenPicker) forControlEvents:UIControlEventTouchUpInside];
    self.pickerCancelButton.hidden = YES;
    //    self.pickerCancelButton = [UIColor yellowColor];
    [self.view addSubview:self.pickerCancelButton];
    
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.height.equalTo(@280);
    }];
    
    [self.pickerOKButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pickerView).offset(10);
        make.right.equalTo(self.pickerView).offset(-10);
        make.height.equalTo(@40);
        make.width.equalTo(@70);
    }];
    
    [self.pickerCancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pickerView).offset(10);
        make.left.equalTo(self.pickerView).offset(10);
        make.height.equalTo(@40);
        make.width.equalTo(@70);
    }];
    
}

- (void)showPicker{
    self.pickerView.hidden = NO;
    self.pickerCancelButton.hidden = NO;
    self.pickerOKButton.hidden = NO;
    
}

- (void)hiddenPicker{
    self.pickerView.hidden = YES;
    self.pickerCancelButton.hidden = YES;
    self.pickerOKButton.hidden = YES;
}

- (void)pickOK{
    [self hiddenPicker];
    self.mapView.zoomLevel = (zoomLevelmax + zoomLevelmin) * 0.5;
//    [self.mapView removeAnnotations:self.mapView.annotations];
//    NSLog(@"%@",self.pickerSelectDic);
    //okokokokokok
    if ([[NSString stringWithFormat:@"%@",[self.pickerSelectDic objectForKey:@"subid"]] isEqualToString:@"999911"]) {
        
        // 1 haoxian1
        [self subwayWithLine:11];
    }
    else if ([[NSString stringWithFormat:@"%@",[self.pickerSelectDic objectForKey:@"subid"]] isEqualToString:@"999912"])
    {
        // 1 haoxian2
        [self subwayWithLine:12];
    }
    else if ([[NSString stringWithFormat:@"%@",[self.pickerSelectDic objectForKey:@"subid"]] isEqualToString:@"99992"])
    {
        // 2 haoxian
        [self subwayWithLine:2];
    }
    else if ([[NSString stringWithFormat:@"%@",[self.pickerSelectDic objectForKey:@"subid"]] isEqualToString:@"99994"])
    {
        // 4 haoxian
        [self subwayWithLine:4];
    }
    else
    {
        // zhandian
        if  (self.showAllMode == YES){
            self.mapView.centerCoordinate = CLLocationCoordinate2DMake([[self.pickerSelectDic objectForKey:@"prjy"] doubleValue], [[self.pickerSelectDic objectForKey:@"prjx"] doubleValue]);
            [self requestDetialDataWithCoordinate:CLLocationCoordinate2DMake([[self.pickerSelectDic objectForKey:@"prjy"] doubleValue], [[self.pickerSelectDic objectForKey:@"prjx"] doubleValue])];
        } else {
            self.mapView.centerCoordinate = CLLocationCoordinate2DMake([[self.pickerSelectDic objectForKey:@"prjy"] doubleValue], [[self.pickerSelectDic objectForKey:@"prjx"] doubleValue]);
            [self mapView:self.mapView onClickedMapBlank:CLLocationCoordinate2DMake([[self.pickerSelectDic objectForKey:@"prjy"] doubleValue], [[self.pickerSelectDic objectForKey:@"prjx"] doubleValue])];
//            self.mapView.centerCoordinate = CLLocationCoordinate2DMake([[self.pickerSelectDic objectForKey:@"prjy"] doubleValue], [[self.pickerSelectDic objectForKey:@"prjx"] doubleValue]);
//            [self requestDetialDataWithCoordinate:CLLocationCoordinate2DMake([[self.pickerSelectDic objectForKey:@"prjy"] doubleValue], [[self.pickerSelectDic objectForKey:@"prjx"] doubleValue])];
        }
    }
}

#pragma mark - pickerView的代理方法
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return  2;
}

 -(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
     if (component == 0) {
         return 4;
     } else {
         return self.pickerComponent.count;
     }
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        if (row == 0) {
            return @"1号线（下沙江滨）";
        } else if(row == 1){
            return @"1号线（临平）";
        }
        else if(row == 2){
            return @"2号线";
        }else{
            return @"4号线";
        }
    } else {
        return [self.pickerComponent[row] objectForKey:@"subname"];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 180;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        if (row == 0) {
            self.pickerComponent = [self.pickerViewData objectForKey:@"11"];
            [self.pickerView reloadAllComponents];
            [self.pickerView selectRow:0 inComponent:1 animated:YES];
            self.pickerSelectDic = @{@"subname":@"全部",@"subid":@"999911"};
        }
        else if(row == 1) {
            self.pickerComponent = [self.pickerViewData objectForKey:@"12"];
            [self.pickerView reloadAllComponents];
            [self.pickerView selectRow:0 inComponent:1 animated:YES];
            self.pickerSelectDic = @{@"subname":@"全部",@"subid":@"999912"};
        }
        else if(row == 2) {
            self.pickerComponent = [self.pickerViewData objectForKey:@"2"];
            [self.pickerView reloadAllComponents];
            [self.pickerView selectRow:0 inComponent:1 animated:YES];
            self.pickerSelectDic = @{@"subname":@"全部",@"subid":@"99992"};
        }
        else if(row == 3) {
            self.pickerComponent = [self.pickerViewData objectForKey:@"4"];
            [self.pickerView reloadAllComponents];
            [self.pickerView selectRow:0 inComponent:1 animated:YES];
            self.pickerSelectDic = @{@"subname":@"全部",@"subid":@"99994"};
        }
    }
    if (component == 1) {
        self.pickerSelectDic = [[NSDictionary alloc] initWithDictionary:self.pickerComponent[row]];
    }
    
}
//获取当前定位 move
- (void)resetPosition{
    __weak typeof(self) weakSelf = self;
    [self.locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
        
        weakSelf.mapView.zoomLevel = 17.17;
        //获取经纬度和该定位点对应的位置信息
        weakSelf.mapView.centerCoordinate = location.location.coordinate;
        weakSelf.coordinate = location.location.coordinate;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            static dispatch_once_t onceToken;
            
            dispatch_once(&onceToken, ^{
                [weakSelf.mapView addOverlay:weakSelf.circle];
            });
            weakSelf.circle.coordinate = location.location.coordinate;
            
            // remove ziji
            for (BMKPointAnnotation * p in self.mapView.annotations) {
                if ([objc_getAssociatedObject(p, @"flag") isEqualToString:@"1"]) {
                    [self.mapView removeAnnotation:p];
                }
            }
            
            BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc]init];
            objc_setAssociatedObject(annotation,@"flag",@"1",OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            annotation.coordinate = location.location.coordinate;
            [weakSelf.mapView addAnnotation:annotation];
            NSLog(@"增加了自己");
            
        });
        
        [weakSelf requestDetialDataWithCoordinate:location.location.coordinate];
        
    }];
}

//show paopao
- (void)showPaopaoWithType:(NSString *)type withData:(NSArray *)dataArr{
    if (dataArr.count == 0) {
        NSLog(@"没有房源信息");
        return;
    }
    if ([type isEqualToString:@"1"]) {
        
        for (NSDictionary * dic in dataArr) {
            NSLog(@"%@",dic);
            BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc]init];
            objc_setAssociatedObject(annotation,@"flag",@"0",OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            annotation.coordinate = CLLocationCoordinate2DMake([[dic objectForKey:@"gisy"] doubleValue], [[dic objectForKey:@"gisx"] doubleValue]);
            //设置标注的标题
            annotation.title = [dic objectForKey:@"cqmc"];
            //副标题
            NSLog(@"%@",dic);
            annotation.subtitle = [[dic objectForKey:@"rentnum"] stringValue];
            [_mapView addAnnotation:annotation];
//            NSLog(@"增加了%@",[dic objectForKey:@"cqmc"]);
        }
        
    } else if ([type isEqualToString:@"2"]) {
        
        for (NSDictionary * dic in dataArr) {
            
            BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc]init];
            objc_setAssociatedObject(annotation,@"flag",@"0",OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            annotation.coordinate = CLLocationCoordinate2DMake([[dic objectForKey:@"gisy"] doubleValue], [[dic objectForKey:@"gisx"] doubleValue]);
            //设置标注的标题
            annotation.title = [dic objectForKey:@"sqmc"];
            //副标题
            annotation.subtitle = [[dic objectForKey:@"rentnum"] stringValue];
            [_mapView addAnnotation:annotation];
//            NSLog(@"增加了%@",[dic objectForKey:@"sqmc"]);
        }
    } else if ([type isEqualToString:@"3"]) {
        
        for (NSDictionary * dic in dataArr) {
            
            BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc]init];
            objc_setAssociatedObject(annotation,@"flag",@"0",OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            annotation.coordinate = CLLocationCoordinate2DMake([[dic objectForKey:@"prjy"] doubleValue], [[dic objectForKey:@"prjx"] doubleValue]);
            //设置标注的标题
            annotation.title = [dic objectForKey:@"communityname"];
            //副标题
            annotation.subtitle = [[dic objectForKey:@"czcount"] stringValue];
            [_mapView addAnnotation:annotation];
//            NSLog(@"增加了%@",[dic objectForKey:@"areaname"]);
        }
    } else if ([type isEqualToString:@"4"]) {
        
        //remove old
        for (BMKPointAnnotation * p in self.mapView.annotations) {
            if ([objc_getAssociatedObject(p, @"flag") isEqualToString:@"0"]) {
                [self.mapView removeAnnotation:p];
            }
        }
        
        for (NSDictionary * dic in dataArr) {
            
            BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc]init];
            objc_setAssociatedObject(annotation,@"flag",@"2",OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            annotation.coordinate = CLLocationCoordinate2DMake([[dic objectForKey:@"prjy"] doubleValue], [[dic objectForKey:@"prjx"] doubleValue]);
            //设置标注的标题
            annotation.title = [dic objectForKey:@"subwayname"];
            //副标题
            annotation.subtitle = [dic objectForKey:@"czcount"];
            [_mapView addAnnotation:annotation];
            //            NSLog(@"增加了%@",[dic objectForKey:@"areaname"]);
        }
    }

}

//获取data  area
- (void)requestAreaDataWithType:(NSString *) type{
    //1.确定请求路径
    NSURL *url = [NSURL URLWithString:@"http://jia3.tmsf.com/hzf/esf_arealist.jspx"];
    //2.创建请求对象
    //请求对象内部默认已经包含了请求头和请求方法（GET）
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //3.获得会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //4.根据会话对象创建一个Task(发送请求）
    /*
            第一个参数：请求对象
            第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
            data：响应体信息（期望的数据）
            response：响应头信息，主要是对服务器端的描述
            error：错误信息，如果请求失败，则error有值
    */
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error == nil) {
                //6.解析服务器返回的数据
                //说明：（此处返回的数据是JSON格式的，因此使用NSJSONSerialization进行反序列化处理）
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//                        NSLog(@"%@",dict);
                
                        /*
                         cqid = 330231;
                         cqmc = "\U5927\U6c5f\U4e1c";
                         gisx = "120.499577";
                         gisy = "30.325908";
                         gwnum = 3;
                         rentnum = 0;
                         sellnum = 60;
                         signprice = 13294;
                         */
                        NSArray * cqArr = [dict objectForKey:@"cqlist"];
                        /*
                         cqid = 330103;
                         gisx = "120.173505";
                         gisy = "30.290431";
                         gwnum = 7;
                         rentnum = 358;
                         sellnum = 1707;
                         sqid = 1000180;
                         sqmc = "\U671d\U6656";
                         */
                        NSArray * sqArr = [dict objectForKey:@"sqlist"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if ([type isEqualToString:@"1"]) {
//                                NSLog(@"%@",cqArr);
                                [weakSelf showPaopaoWithType:@"1" withData:cqArr];
                            } else {
                                [weakSelf showPaopaoWithType:@"2" withData:sqArr];
                            }
                        });
                
                     }
             }];

    //5.执行任务
    [dataTask resume];
}

//获取data  detial
- (void)requestDetialDataWithCoordinate:(CLLocationCoordinate2D)coordinate{
    
    NSLog(@"准备请求数据");
    
    NSString * distance = self.distance;
    NSString * fanglingzoom= @"";
    NSString * lat= [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString * lng= [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString * maprentjzmjzoom = self.screenString1; //价格
    NSString * maprenttypezoom = self.screenString2; //类型
    NSString * maprentzjjezoom = self.screenString3; //面积
    NSString * maprentppmczoom = self.screenString4; //品牌
    NSString * mapfwcxzoom= @"";
    NSString * maphousetypezoom= @"";
    NSString * mapjzmjzoom= @"";
    NSString * mappricezoom= @"";
    NSString * mapratezoom= @"";
    NSString * mapszlczoom= @"";
    NSString * mapzxbzzoom= @"";
    NSString * neLat= [NSString stringWithFormat:@"%f",coordinate.latitude+0.03];
    NSString * neLng= [NSString stringWithFormat:@"%f",coordinate.longitude+0.03];
    NSString * rp= @"30";
    NSString * swLat= [NSString stringWithFormat:@"%f",coordinate.latitude-0.03];
    NSString * swLng= [NSString stringWithFormat:@"%f",coordinate.longitude-0.03];
    
    NSString * distance1 = [NSString stringWithFormat:@"distance=%@",distance]; //距离
    NSString * fanglingzoom1 = [NSString stringWithFormat:@"&fanglingzoom=%@",fanglingzoom];
    NSString * lat1 = [NSString stringWithFormat:@"&lat=%@",lat]; // 中心纬度
    NSString * lng1 = [NSString stringWithFormat:@"&lng=%@",lng]; // 中心经度
    NSString * mapfwcxzoom1 = [NSString stringWithFormat:@"&mapfwcxzoom=%@",mapfwcxzoom];
    NSString * maphousetypezoom1 = [NSString stringWithFormat:@"&maphousetypezoom=%@",maphousetypezoom];
    NSString * mapjzmjzoom1 = [NSString stringWithFormat:@"&mapjzmjzoom=%@",mapjzmjzoom];
    NSString * mappricezoom1 = [NSString stringWithFormat:@"&mappricezoom=%@",mappricezoom];
    NSString * mapratezoom1 = [NSString stringWithFormat:@"&mapratezoom=%@",mapratezoom];
    NSString * mapszlczoom1 = [NSString stringWithFormat:@"&mapszlczoom=%@",mapszlczoom];
    NSString * mapzxbzzoom1 = [NSString stringWithFormat:@"&mapzxbzzoom=%@",mapzxbzzoom];
    NSString * neLat1 = [NSString stringWithFormat:@"&neLat=%@",neLat]; //东北纬度
    NSString * neLng1 = [NSString stringWithFormat:@"&neLng=%@",neLng]; //东北经度
    NSString * rp1 = [NSString stringWithFormat:@"&rp=%@",rp];
    NSString * swLat1 = [NSString stringWithFormat:@"&swLat=%@",swLat]; //西南纬度
    NSString * swLng1 = [NSString stringWithFormat:@"&swLng=%@",swLng]; //西南经度
    
    NSString * maprentjzmjzoom1 = [NSString stringWithFormat:@"&maprentjzmjzoom=%@",maprentjzmjzoom]; //价格
    NSString * maprenttypezoom1 = [NSString stringWithFormat:@"&maprenttypezoom=%@",maprenttypezoom]; ///类型
    NSString * maprentzjjezoom1 = [NSString stringWithFormat:@"&maprentzjjezoom=%@",maprentzjjezoom];  //面积
    NSString * maprentppmczoom1 = [NSString stringWithFormat:@"&maprentppmczoom=%@",maprentppmczoom]; ///品牌
    
    
    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",distance1,fanglingzoom1,lat1,lng1,mapfwcxzoom1,maphousetypezoom1,mapjzmjzoom1,mappricezoom1,mapratezoom1,mapszlczoom1,mapzxbzzoom1,neLat1,neLng1,rp1,swLat1,swLng1,maprentjzmjzoom1,maprentzjjezoom1,maprenttypezoom1,maprentppmczoom1];
    
    NSString * unicodeStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * url = [NSString stringWithFormat:@"%@?%@",@"http://m.howzf.com/hzf/esf_communitylist.jspx",unicodeStr];
    
    NSLog(@"%@",url);
    //1.确定请求路径
    NSURL *url1 = [NSURL URLWithString:url];
    //2.创建请求对象
    //请求对象内部默认已经包含了请求头和请求方法（GET）
    NSURLRequest *request = [NSURLRequest requestWithURL:url1];
    //3.获得会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //4.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    __weak typeof(self) weakSelf = self;
    NSLog(@"开始请求数据");
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"获取到数据");
            //6.解析服务器返回的数据
            //说明：（此处返回的数据是JSON格式的，因此使用NSJSONSerialization进行反序列化处理）
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            NSLog(@"%@",dict);]
            NSLog(@"解析完成");
            
            /*
             communityname = "\U4e0b\U57ce \U671d\U6656";
             cscount = 18;
             prjx = "120.181736";
             prjy = "30.283788";
             */
            weakSelf.listArr = [[NSArray alloc] initWithArray:[dict objectForKey:@"list"]];
            self.houseCOunt = 0;
            for (NSDictionary * dic in weakSelf.listArr) {
                self.houseCOunt = self.houseCOunt + [[dic objectForKey:@"czcount"] longValue];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (weakSelf.mapView.zoomLevel<zoomLevelmax) {
                    return ;
                }
                [self showAlertWithCount:self.houseCOunt];
                //remove old
                for (BMKPointAnnotation * p in weakSelf.mapView.annotations) {
                    if ([objc_getAssociatedObject(p, @"flag") isEqualToString:@"0"]) {
                        [weakSelf.mapView removeAnnotation:p];
                    }
                }
                
                [weakSelf showPaopaoWithType:@"3" withData:self.listArr];
            });
            
            
        }
    }];
    
    //5.执行任务
    [dataTask resume];
}

//  slider
-(void)sliderAction:(UISlider*)sender
{
    //    0         0.25        0.5     0.75        1
    //  0.2km       0.5km       1km     1.5km       all
    //          0.125       0.375   0.625       0.875
    
    if (sender.value <= 0.125) {
        //0.2km
        sender.value = 0;
        self.distance = @"0.2";
        self.circleRadius = 200;
        self.circle.radius = self.circleRadius;
        self.mapView.zoomLevel = 18.55;
        self.showAllMode = NO;
        
        
    } else if (sender.value > 0.125 && sender.value <= 0.375){
        //0.5km
        sender.value = 0.25;
        self.distance = @"0.5";
        self.circleRadius = 500;
        self.circle.radius = self.circleRadius;
        self.mapView.zoomLevel = 17.17;
        self.showAllMode = NO;
        
    } else if (sender.value > 0.375 && sender.value <= 0.625){
        //1km
        sender.value = 0.5;
        self.distance = @"1";
        self.circleRadius = 1000;
        self.circle.radius = self.circleRadius;
        self.mapView.zoomLevel = 16.31;
        self.showAllMode = NO;
        
    } else if (sender.value > 0.625 && sender.value <= 0.875){
        //1.5km
        sender.value = 0.75;
        self.distance = @"1.5";
        self.circleRadius = 1500;
        self.circle.radius = self.circleRadius;
        self.mapView.zoomLevel = 15.69;
        self.showAllMode = NO;
        
        
    } else {
        //all
//        sender.value = 1;
        [self showAllModeOpen];
        
    }
    [self requestDetialDataWithCoordinate:self.coordinate];
}

- (void)showAllModeOpen{
    
    [self resetPosition];
    
    self.rangeSlider.value = 1;
    //全市
    self.distance = @"3.5";
    self.circleRadius = 0;
    self.circle.radius = self.circleRadius;
    self.mapView.zoomLevel = 15.69;
    self.showAllMode = YES;
}

#pragma mark - huidiao
//shangquan
- (void)requestData1With:(NSDictionary * )myData{
    NSURL *url = [NSURL URLWithString:@"http://jia3.tmsf.com/hzf/esf_arealist.jspx"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSArray * sqArr = [dict objectForKey:@"sqlist"];
            weakSelf.sqArr = [[NSArray alloc] initWithArray:sqArr];
            
            for (NSDictionary * dic in weakSelf.sqArr) {
                if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"sqid"]] isEqualToString:[NSString stringWithFormat:@"%@",[myData objectForKey:@"areaid"]]]) {
    
                        self.mapView.centerCoordinate = CLLocationCoordinate2DMake([[dic objectForKey:@"gisy"] doubleValue], [[dic objectForKey:@"gisx"] doubleValue]);
                        self.mapView.zoomLevel = (zoomLevelmax + zoomLevelmin) * 0.5;
        
                    
                }
            }
        }
    }];
    [dataTask resume];
}

//chengqu
- (void)requestData2With:(NSDictionary * )myData{
    NSURL *url = [NSURL URLWithString:@"http://jia3.tmsf.com/hzf/esf_arealist.jspx"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSArray * cqArr = [dict objectForKey:@"cqlist"];
            weakSelf.cqArr = [[NSArray alloc] initWithArray:cqArr];
            for (NSDictionary * dic in weakSelf.cqArr) {
                if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"cqid"]] isEqualToString:[NSString stringWithFormat:@"%@",[myData objectForKey:@"areaid"]]]) {
                    
                    
                        self.mapView.centerCoordinate = CLLocationCoordinate2DMake([[dic objectForKey:@"gisy"] doubleValue], [[dic objectForKey:@"gisx"] doubleValue]);
                        self.mapView.zoomLevel = zoomLevelmin - 0.01;
                    
                    
                }
            }
            
        }
    }];
    [dataTask resume];
}

//xianlu
- (void)requestData4With:(NSDictionary * )myData{
    NSURL *url = [NSURL URLWithString:@"http://jia3.tmsf.com/hzf/hzf_subway.jspx"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            weakSelf.subArr = [[NSArray alloc] initWithArray:[dict objectForKey:@"list"]];
            
            
        }
    }];
    [dataTask resume];
}

//zhan dian
- (void)requestData5With:(NSDictionary * )myData{
    NSURL *url = [NSURL URLWithString:@"http://jia3.tmsf.com/hzf/hzf_subway.jspx"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            weakSelf.subArr = [[NSArray alloc] initWithArray:[dict objectForKey:@"list"]];
            
            for (NSDictionary * dic in weakSelf.subArr) {
                if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"subid"]] isEqualToString:[NSString stringWithFormat:@"%@",[myData objectForKey:@"subid"]]]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{

                        self.mapView.centerCoordinate = CLLocationCoordinate2DMake([[dic objectForKey:@"prjy"] doubleValue], [[dic objectForKey:@"prjx"] doubleValue]);
                        self.mapView.zoomLevel = zoomLevelmax + 0.01;
                        [self mapView:self.mapView onClickedMapBlank:CLLocationCoordinate2DMake([[dic objectForKey:@"prjy"] doubleValue], [[dic objectForKey:@"prjx"] doubleValue])];
    
                    });
                    
                    
                }
            }
        }
    }];
    [dataTask resume];
}



#pragma mark - buttonAction

- (void)searchButtonAction{
    SearchViewController * vc = [[SearchViewController alloc] init];
    vc.returnValueBlock = ^(NSDictionary *data){
        if ([[data objectForKey:@"type"] isEqualToString:@"shangquan"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestData1With:data];
            });
        }
        else if ([[data objectForKey:@"type"] isEqualToString:@"chengqu"]){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestData2With:data];
            });
        }
        else if ([[data objectForKey:@"type"] isEqualToString:@"shequ"]){
            //callback
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.returnValueBlock) {
                    self.returnValueBlock(@{@"key":@"value"});
                }
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            });
        }
        else if ([[data objectForKey:@"type"] isEqualToString:@"xianlu"]){
//            [self requestData4With:data];
            NSInteger a = [[NSString stringWithFormat:@"%@",[data objectForKey:@"subid"]] integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self subwayWithLine:a];
            });
            
        }
        else if ([[data objectForKey:@"type"] isEqualToString:@"zhandian"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestData5With:data];
            });
            
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)screenButtonAction{

    if (_screenViewFlag == YES) {
        _screenViewFlag = NO;
        self.maskView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.screenView.center = CGPointMake(self.screenView.center.x-300, self.screenView.center.y);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        _screenViewFlag = YES;
        [self maskViewAction];
    }
    
    
}

- (void)subwayButtonAction{
    [self showPicker];
}


- (void)maskViewAction{
    self.maskView.hidden = YES;
    _screenViewFlag = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.screenView.center = CGPointMake(self.screenView.center.x+300, self.screenView.center.y);
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark - screenButtonAction
- (void)screenCancelAction{
    self.screenButton1.selected = NO;
    self.screenButton2.selected = NO;
    self.screenButton3.selected = NO;
    self.screenButton4.selected = NO;
    self.screenButton5.selected = NO;
    self.screenButton6.selected = NO;
    self.screenButton7.selected = NO;
    self.screenButton8.selected = NO;
    self.screenButton9.selected = NO;
    self.screenButton10.selected = NO;
    self.screenButton11.selected = NO;
    self.screenButton12.selected = NO;
    self.screenButton13.selected = NO;
    self.screenButton14.selected = NO;
    self.screenButton15.selected = NO;
    self.screenButton16.selected = NO;
    self.screenButton17.selected = NO;
    self.screenButton18.selected = NO;
    self.screenButton19.selected = NO;
    self.screenButton20.selected = NO;
    self.screenButton21.selected = NO;
    self.screenButton22.selected = NO;
    self.screenButton23.selected = NO;
    self.screenButton24.selected = NO;
    self.screenTextField1.text = @"";
    self.screenTextField2.text = @"";
    self.screenString1 = @"";
    self.screenString2 = @"";
    self.screenString3 = @"";
    self.screenString4 = @"";
    [self maskViewAction];
    [self resetPosition];
}

- (void)screenOKAction{
    
    //价格
    self.screenString1 = @"";
    if (self.screenTextField1.text.length != 0||self.screenTextField2.text.length != 0) {
        if (self.screenTextField1.text.length == 0) {
            self.screenString1 = [NSString stringWithFormat:@"0_%@",self.screenTextField2.text];
        } else if (self.screenTextField2.text.length == 0) {
            self.screenString1 = [NSString stringWithFormat:@"%@_9999",self.screenTextField1.text];
        } else {
            self.screenString1 = [NSString stringWithFormat:@"%@_%@",self.screenTextField1.text,self.screenTextField2.text];
        }
    } else {
        NSString * string1 = @"";
        NSString * string2 = @"";
        NSString * string3 = @"";
        NSString * string4 = @"";
        NSString * string5 = @"";
        if (self.screenButton1.selected == YES) {
            string1 = @"0_1200,";
        }
        if (self.screenButton2.selected == YES) {
            string2 = @"1200_1500,";
        }
        if (self.screenButton3.selected == YES) {
            string3 = @"1500_2000,";
        }
        if (self.screenButton4.selected == YES) {
            string4 = @"2000_3000,";
        }
        if (self.screenButton5.selected == YES) {
            string5 = @"3000_9999,";
        }
        self.screenString1 = [NSString stringWithFormat:@"%@%@%@%@%@",string1,string2,string3,string4,string5];
    }
    //类型
    self.screenString2 = @"";
    NSString * string6 = @"";
    NSString * string7 = @"";
    NSString * string8 = @"";
    if (self.screenButton6.selected == YES) {
        string6 = @"0,";
    }
    if (self.screenButton7.selected == YES) {
        string7 = @"1,";
    }
    if (self.screenButton8.selected == YES) {
        string8 = @"2,";
    }
    self.screenString2 = [NSString stringWithFormat:@"%@%@%@",string6,string7,string8];
    
    //面积
    self.screenString3 = @"";
    NSString * string9 = @"";
    NSString * string10 = @"";
    NSString * string11 = @"";
    NSString * string12 = @"";
    NSString * string13 = @"";
    NSString * string14 = @"";
    NSString * string15 = @"";
    NSString * string16 = @"";
    if (self.screenButton9.selected == YES) {
        string9 = @"0_50,";
    }
    if (self.screenButton10.selected == YES) {
        string10 = @"50_70,";
    }
    if (self.screenButton11.selected == YES) {
        string11 = @"70_90,";
    }
    if (self.screenButton12.selected == YES) {
        string12 = @"90_110,";
    }
    if (self.screenButton13.selected == YES) {
        string13 = @"110_130,";
    }
    if (self.screenButton14.selected == YES) {
        string14 = @"130_150,";
    }
    if (self.screenButton15.selected == YES) {
        string15 = @"150_200,";
    }
    if (self.screenButton16.selected == YES) {
        string16 = @"200_99999,";
    }
    self.screenString3 = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",string9,string10,string11,string12,string13,string14,string15,string16];
    
    //品牌
    self.screenString4 = @"";
    NSString * string17 = @"";
    NSString * string18 = @"";
    NSString * string19 = @"";
    NSString * string20 = @"";
    NSString * string21 = @"";
    NSString * string22 = @"";
    NSString * string23 = @"";
    NSString * string24 = @"";
    if (self.screenButton17.selected == YES) {
        string17 = @"泊寓,";
    }
    if (self.screenButton18.selected == YES) {
        string18 = @"魔方,";
    }
    if (self.screenButton19.selected == YES) {
        string19 = @"爱上租,";
    }
    if (self.screenButton20.selected == YES) {
        string20 = @"红璞,";
    }
    if (self.screenButton21.selected == YES) {
        string21 = @"群岛,";
    }
    if (self.screenButton22.selected == YES) {
        string22 = @"冠寓,";
    }
    if (self.screenButton23.selected == YES) {
        string23 = @"麦家,";
    }
    if (self.screenButton24.selected == YES) {
        string24 = @"自如,";
    }
    self.screenString4 = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",string17,string18,string19,string20,string21,string22,string23,string24];
    
    
    [self maskViewAction];
    [self resetPosition];
}


- (void)screenButton1Action{
    self.screenButton1.selected = !self.screenButton1.selected;
}

- (void)screenButton2Action{
    self.screenButton2.selected = !self.screenButton2.selected;
}

- (void)screenButton3Action{
    self.screenButton3.selected = !self.screenButton3.selected;
}

- (void)screenButton4Action{
    self.screenButton4.selected = !self.screenButton4.selected;
}

- (void)screenButton5Action{
    self.screenButton5.selected = !self.screenButton5.selected;
}

- (void)screenButton6Action{
    self.screenButton6.selected = !self.screenButton6.selected;
}

- (void)screenButton7Action{
    self.screenButton7.selected = !self.screenButton7.selected;
}

- (void)screenButton8Action{
    self.screenButton8.selected = !self.screenButton8.selected;
}

- (void)screenButton9Action{
    self.screenButton9.selected = !self.screenButton9.selected;
}

- (void)screenButton10Action{
    self.screenButton10.selected = !self.screenButton10.selected;
}

- (void)screenButton11Action{
    self.screenButton11.selected = !self.screenButton11.selected;
}

- (void)screenButton12Action{
    self.screenButton12.selected = !self.screenButton12.selected;
}

- (void)screenButton13Action{
    self.screenButton13.selected = !self.screenButton13.selected;
}

- (void)screenButton14Action{
    self.screenButton14.selected = !self.screenButton14.selected;
}

- (void)screenButton15Action{
    self.screenButton15.selected = !self.screenButton15.selected;
}

- (void)screenButton16Action{
    self.screenButton16.selected = !self.screenButton16.selected;
}

- (void)screenButton17Action{
    self.screenButton17.selected = !self.screenButton17.selected;
}

- (void)screenButton18Action{
    self.screenButton18.selected = !self.screenButton18.selected;
}

- (void)screenButton19Action{
    self.screenButton19.selected = !self.screenButton19.selected;
}

- (void)screenButton20Action{
    self.screenButton20.selected = !self.screenButton20.selected;
}

- (void)screenButton21Action{
    self.screenButton21.selected = !self.screenButton21.selected;
}

- (void)screenButton22Action{
    self.screenButton22.selected = !self.screenButton22.selected;
}

- (void)screenButton23Action{
    self.screenButton23.selected = !self.screenButton23.selected;
}

- (void)screenButton24Action{
    self.screenButton24.selected = !self.screenButton24.selected;
}

#pragma mark - delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
     * 不能输入.0-9以外的字符。
     * 设置输入框输入的内容格式
     * 只能有一个小数点
     * 小数点后最多能输入两位
     * 如果第一位是.则前面加上0.
     * 如果第一位是0则后面必须输入点，否则不能输入。
     */
    BOOL isHaveDian;
    // 判断是否有小数点
    if ([textField.text containsString:@"."]) {
        isHaveDian = YES;
    }else{
        isHaveDian = NO;
    }
    
    if (string.length > 0) {
        
        //当前输入的字符
        unichar single = [string characterAtIndex:0];
        
        // 不能输入.0-9以外的字符
        if (!((single >= '0' && single <= '9') || single == '.'))
        {
//            [MBProgressHUD bwm_showTitle:@"您的输入格式不正确" toView:self hideAfter:1.0];
            return NO;
        }
        
        // 只能有一个小数点
        if (isHaveDian && single == '.') {
//            [MBProgressHUD bwm_showTitle:@"最多只能输入一个小数点" toView:self hideAfter:1.0];
            return NO;
        }
        
        // 如果第一位是.则前面加上0.
        if ((textField.text.length == 0) && (single == '.')) {
            textField.text = @"0";
        }
        
        // 如果第一位是0则后面必须输入点，否则不能输入。
        if ([textField.text hasPrefix:@"0"]) {
            if (textField.text.length > 1) {
                NSString *secondStr = [textField.text substringWithRange:NSMakeRange(1, 1)];
                if (![secondStr isEqualToString:@"."]) {
//                    [MBProgressHUD bwm_showTitle:@"第二个字符需要是小数点" toView:self hideAfter:1.0];
                    return NO;
                }
            }else{
                if (![string isEqualToString:@"."]) {
//                    [MBProgressHUD bwm_showTitle:@"第二个字符需要是小数点" toView:self hideAfter:1.0];
                    return NO;
                }
            }
        }
        
        // 小数点后最多能输入两位
        if (isHaveDian) {
            NSRange ran = [textField.text rangeOfString:@"."];
            // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
            if (range.location > ran.location) {
                if ([textField.text pathExtension].length > 1) {
//                    [MBProgressHUD bwm_showTitle:@"小数点后最多有两位小数" toView:self hideAfter:1.0];
                    return NO;
                }
            }
        }
        
    }
    
    return YES;
}

- (void)mapStatusDidChanged:(BMKMapView *)mapView{
    
    
    if ((self.oldCoor.latitude-mapView.centerCoordinate.latitude) > 0.003 || (self.oldCoor.latitude-mapView.centerCoordinate.latitude) < -0.003) {
        if ((self.oldCoor.longitude-mapView.centerCoordinate.longitude) > 0.003 || (self.oldCoor.longitude-mapView.centerCoordinate.longitude) < -0.003) {
            NSLog(@"fixxxxxxxxx");
             self.oldCoor = mapView.centerCoordinate;
            // if showAll
            if (self.showAllMode == YES) {
                [self requestDetialDataWithCoordinate:self.mapView.centerCoordinate];
            } else {
                // do nothing
            }
        }
    }
    
}


//地图改变 will
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.zoomValue = mapView.zoomLevel;
    self.oldCoor = mapView.centerCoordinate;
    NSLog(@"之前的比例尺：%f",mapView.zoomLevel);
}

//地图改变 did
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if (mapView.zoomLevel > self.zoomValue) {
        NSLog(@"地图放大了");
    }else if (mapView.zoomLevel < self.zoomValue){
        NSLog(@"地图缩小了");
    }
    NSLog(@"当前比例尺%f",mapView.zoomLevel);
    NSLog(@"regionDidChangeAnimated");
    // if showAll
    if (self.showAllMode == YES) {
        [self requestDetialDataWithCoordinate:self.mapView.centerCoordinate];
    } else {
        // do nothing
    }
    
    //放大隐藏蓝圈
    if (mapView.zoomLevel > zoomLevelmax) {
        NSLog(@"1");
        self.circle.radius = self.circleRadius;
    } else {
        self.circle.radius = 0;
    }
    
    if (mapView.zoomLevel>zoomLevelmax) {
        if (self.zoomValue>zoomLevelmax) {
            //
        } else {
            //remove
            for (BMKPointAnnotation * p in self.mapView.annotations) {
                if ([objc_getAssociatedObject(p, @"flag") isEqualToString:@"0"]) {
                    [self.mapView removeAnnotation:p];
                }
            }
            //remove old
            for (BMKPointAnnotation * p in self.mapView.annotations) {
                if ([objc_getAssociatedObject(p, @"flag") isEqualToString:@"2"]) {
                    [self.mapView removeAnnotation:p];
                }
            }
            NSLog(@"移除了视图");
//            [self requestDetialDataWithCoordinate:self.coordinate];
            
            // if showAll
            if (self.showAllMode == YES) {
                [self requestDetialDataWithCoordinate:self.mapView.centerCoordinate];
            } else {
                [self showPaopaoWithType:@"3" withData:self.listArr];
            }
            
        }

    }
    else if (mapView.zoomLevel <= zoomLevelmax && mapView.zoomLevel > zoomLevelmin)
    {
        if (self.zoomValue <= zoomLevelmax && self.zoomValue > zoomLevelmin) {
            //
        } else {
            //remove
            for (BMKPointAnnotation * p in self.mapView.annotations) {
                if ([objc_getAssociatedObject(p, @"flag") isEqualToString:@"0"]) {
                    [self.mapView removeAnnotation:p];
                }
            }
            NSLog(@"移除了视图asd");
            [self requestAreaDataWithType:@"2"];
        }
        
    } else {
        if (self.zoomValue<zoomLevelmin) {
            //
        } else {
            //remove
            for (BMKPointAnnotation * p in self.mapView.annotations) {
                if ([objc_getAssociatedObject(p, @"flag") isEqualToString:@"0"]) {
                    [self.mapView removeAnnotation:p];
                }
            }
            //remove old
            for (BMKPointAnnotation * p in self.mapView.annotations) {
                if ([objc_getAssociatedObject(p, @"flag") isEqualToString:@"2"]) {
                    [self.mapView removeAnnotation:p];
                }
            }
            NSLog(@"移除了视图");
            [self requestAreaDataWithType:@"1"];
        }
        
    }
    
}



/**
 联网结果回调
 
 @param iError 联网结果错误码信息，0代表联网成功
 */
- (void)onGetNetworkState:(int)iError {
    if (0 == iError) {
        NSLog(@"联网成功");
    } else {
        NSLog(@"联网失败：%d", iError);
    }
}

/**
 鉴权结果回调
 
 @param iError 鉴权结果错误码信息，0代表鉴权成功
 */
- (void)onGetPermissionState:(int)iError {
    if (0 == iError) {
        NSLog(@"授权成功");
    } else {
        NSLog(@"授权失败：%d", iError);
    }
}


//气泡的出现
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation {
   
    if ([objc_getAssociatedObject(annotation, @"flag") isEqualToString:@"1"]) {
        static NSString *pointReuseIndentifier = @"myAnno";
        BMKPinAnnotationView*annotationView = (BMKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.pinColor = BMKPinAnnotationColorRed;
//        annotationView.draggable = YES;          //设置标注可以拖动，默认为NO
        return annotationView;
    }
    

    if (view.zoomLevel < zoomLevelmax) {
        NSString *AnnotationViewID = @"round";
        // 检查是否有重用的缓存
        ZFRoundAnnotationView *annotationView = (ZFRoundAnnotationView *)[view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
        if (annotationView == nil) {
            annotationView = [[ZFRoundAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            annotationView.paopaoView = nil;
        }
        annotationView.title = annotation.title;
        annotationView.subTitle = annotation.subtitle;
        return annotationView;
        
    }else {
        NSString *AnnotationViewID = @"message";
        // 检查是否有重用的缓存
        ZFMessageAnnotationView *annotationView = (ZFMessageAnnotationView *)[view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
        if (annotationView == nil) {
            annotationView = [[ZFMessageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            annotationView.paopaoView = nil;
        }
        annotationView.title = [NSString stringWithFormat:@"%@ %@套",annotation.title,annotation.subtitle];
        return annotationView;
    }
}

//点击地图
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    NSLog(@"点击了");
    
    //全市模式不能点击
    if (self.showAllMode == YES) {
        return;
    }
    //large map
    if (mapView.zoomLevel<=zoomLevelmax) {
        return;
    }
    // remove ziji
    for (BMKPointAnnotation * p in self.mapView.annotations) {
        if ([objc_getAssociatedObject(p, @"flag") isEqualToString:@"1"]) {
            [self.mapView removeAnnotation:p];
        }
    }
    // load list
    if (mapView.zoomLevel>zoomLevelmax) {
//        [self.mapView removeAnnotations:self.mapView.annotations];
        [self requestDetialDataWithCoordinate:coordinate];
    }
    //new
    BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc]init];
    objc_setAssociatedObject(annotation,@"flag",@"1",OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];
    NSLog(@"增加了自己");
    
    //重定位圈圈
    self.circle.coordinate = coordinate;
    self.coordinate = coordinate;
    
}

/**
 根据overlay生成对应的BMKOverlayView
 
 @param mapView 地图View
 @param overlay 指定的overlay
 @return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKCircle class]]) {
        //初始化一个overlay并返回相应的BMKCircleView的实例
        BMKCircleView *circleView = [[BMKCircleView alloc] initWithCircle:overlay];
        //设置circleView的填充色
        circleView.fillColor = [[UIColor alloc] initWithRed:0 green:0.5 blue:1 alpha:0.5];
        //设置circleView的画笔（边框）颜色
        circleView.strokeColor = [[UIColor alloc] initWithRed:0 green:0.5 blue:1 alpha:1];
        //设置circleView的轮廓宽度
        circleView.lineWidth = 1.0;
        return circleView;
    }
    return nil;
}

// paopaoview click
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    if (mapView.zoomLevel < zoomLevelmin) {
        mapView.zoomLevel = (zoomLevelmin+zoomLevelmax)*0.5;
        mapView.centerCoordinate = view.annotation.coordinate;
    } else if (mapView.zoomLevel >= zoomLevelmin && mapView.zoomLevel <= zoomLevelmax){
        mapView.zoomLevel = zoomLevelmax+0.001;
        mapView.centerCoordinate = view.annotation.coordinate;
        [self mapView:mapView onClickedMapBlank:mapView.centerCoordinate];
    } else {
        //callback
        if (self.returnValueBlock) {
            self.returnValueBlock(@{@"key":@"value"});
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    }
}
#pragma mark - Lazy loading
- (BMKLocationManager *)locationManager {
    if (!_locationManager) {
        //初始化BMKLocationManager类的实例
        _locationManager = [[BMKLocationManager alloc] init];
        //设置定位管理类实例的代理
        _locationManager.delegate = self;
        //设定定位坐标系类型，默认为 BMKLocationCoordinateTypeGCJ02
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        //设定定位精度，默认为 kCLLocationAccuracyBest
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设定定位类型，默认为 CLActivityTypeAutomotiveNavigation
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        //指定定位是否会被系统自动暂停，默认为NO
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        /**
         是否允许后台定位，默认为NO。只在iOS 9.0及之后起作用。
         设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
         由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
         */
        _locationManager.allowsBackgroundLocationUpdates = NO;
        /**
         指定单次定位超时时间,默认为10s，最小值是2s。注意单次定位请求前设置。
         注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)
         后开始计算。
         */
        _locationManager.locationTimeout = 10;
    }
    return _locationManager;
}

- (BMKUserLocation *)userLocation {
    if (!_userLocation) {
        //初始化BMKUserLocation类的实例
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}

- (UIButton *)locationButton {
    if (!_locationButton) {
        _locationButton = [[UIButton alloc] init];
        [_locationButton setImage:[UIImage imageNamed:@"4361559361124_.pic_thumb.jpg"] forState:UIControlStateNormal];
        _locationButton.backgroundColor = [UIColor whiteColor];
//        [_locationButton setTitle:@"定位" forState:UIControlStateNormal];
        [_locationButton addTarget:self action:@selector(resetPosition) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationButton;
}

- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [[UIButton alloc] init];
                [_searchButton setImage:[UIImage imageNamed:@"4321559360565_.pic.jpg"] forState:UIControlStateNormal];
//        _searchButton.backgroundColor = [UIColor blackColor];
//        [_searchButton setTitle:@"搜索" forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

- (UIButton *)screenButton {
    if (!_screenButton) {
        _screenButton = [[UIButton alloc] init];
                [_screenButton setImage:[UIImage imageNamed:@"4331559360947_.pic.jpg"] forState:UIControlStateNormal];
//        _screenButton.backgroundColor = [UIColor blackColor];
//        [_screenButton setTitle:@"筛选" forState:UIControlStateNormal];
        [_screenButton addTarget:self action:@selector(screenButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton;
}

- (UIButton *)subwayButton {
    if (!_subwayButton) {
        _subwayButton = [[UIButton alloc] init];
        _subwayButton.backgroundColor = [UIColor whiteColor];
        [_subwayButton setTitle:@"地铁找房" forState:UIControlStateNormal];
        [_subwayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_subwayButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        _subwayButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        [_subwayButton addTarget:self action:@selector(subwayButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView * im = [[UIImageView alloc] initWithFrame:CGRectMake(11, 7.5, 25, 25)];
        [im setImage:[UIImage imageNamed:@"4371559361163_.pic.jpg"]];
        [_subwayButton addSubview:im];
    }
    return _subwayButton;
}

- (UISlider *)rangeSlider {
    if (!_rangeSlider) {
        _rangeSlider = [[UISlider alloc] init];
        _rangeSlider.backgroundColor = [UIColor whiteColor];
        _rangeSlider.value = 0.25;
        self.distance = @"0.5";
        self.circleRadius = 500;
        [_rangeSlider setThumbImage:[UIImage imageNamed:@"2.png"] forState:UIControlStateNormal];
        [_rangeSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    return _rangeSlider;
}

- (NSString *)distance {
    if (!_distance) {
        _distance = @"0.5";
    }
    return _distance;
}

- (BMKCircle *)circle {
    if (!_circle) {
        CLLocationCoordinate2D coor = self.coordinate;
        /**
         根据中心点和半径生成圆
         
         @param coord 中心点的经纬度坐标
         @param radius 半径，单位：米
         @return 新生成的BMKCircle实例
         */
        _circle = [BMKCircle circleWithCenterCoordinate:coor radius:self.circleRadius];
    }
    return _circle;
}

- (UIButton *)maskView {
    if (!_maskView) {
        _maskView = [[UIButton alloc] init];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        [_maskView addTarget:self action:@selector(maskViewAction) forControlEvents:UIControlEventTouchUpInside];
        _maskView.hidden = YES;
    }
    return _maskView;
}

- (UIView *)screenView {
    if (!_screenView) {
        _screenView = [[UIView alloc] init];
        _screenView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    }
    return _screenView;
}

#pragma mark - Lazy loading screenView

- (UIView *)screenBottomView {
    if (!_screenBottomView) {
        _screenBottomView = [[UIView alloc] init];
        _screenBottomView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    }
    return _screenBottomView;
}

- (UIButton *)screenCancelButton {
    if (!_screenCancelButton) {
        _screenCancelButton = [[UIButton alloc] init];
        _screenCancelButton.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [_screenCancelButton setTitle:@"清空条件" forState:UIControlStateNormal];
        [_screenCancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenCancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenCancelButton addTarget:self action:@selector(screenCancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenCancelButton;
}

- (UIButton *)screenOKButton {
    if (!_screenOKButton) {
        _screenOKButton = [[UIButton alloc] init];
        _screenOKButton.backgroundColor = [UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1];
        [_screenOKButton setTitle:@"确认" forState:UIControlStateNormal];
        [_screenOKButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_screenOKButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenOKButton addTarget:self action:@selector(screenOKAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenOKButton;
}

- (UILabel *)screenLabel1 {
    if (!_screenLabel1) {
        _screenLabel1 = [[UILabel alloc] init];
        _screenLabel1.text = @"价格(元/月)";
        _screenLabel1.backgroundColor = [UIColor whiteColor];
        _screenLabel1.textColor = [UIColor blackColor];
        [_screenLabel1 setFont:[UIFont systemFontOfSize:17]];
    }
    return _screenLabel1;
}

- (UILabel *)screenLabel2 {
    if (!_screenLabel2) {
        _screenLabel2 = [[UILabel alloc] init];
        _screenLabel2.text = @"类型选择";
        _screenLabel2.backgroundColor = [UIColor whiteColor];
        _screenLabel2.textColor = [UIColor blackColor];
        [_screenLabel2 setFont:[UIFont systemFontOfSize:17]];
    }
    return _screenLabel2;
}

- (UILabel *)screenLabel3 {
    if (!_screenLabel3) {
        _screenLabel3 = [[UILabel alloc] init];
        _screenLabel3.text = @"面积（平方）";
        _screenLabel3.backgroundColor = [UIColor whiteColor];
        _screenLabel3.textColor = [UIColor blackColor];
        [_screenLabel3 setFont:[UIFont systemFontOfSize:17]];
    }
    return _screenLabel3;
}

- (UILabel *)screenLabel4 {
    if (!_screenLabel4) {
        _screenLabel4 = [[UILabel alloc] init];
        _screenLabel4.text = @"品牌";
        _screenLabel4.backgroundColor = [UIColor whiteColor];
        _screenLabel4.textColor = [UIColor blackColor];
        [_screenLabel4 setFont:[UIFont systemFontOfSize:17]];
    }
    return _screenLabel4;
}


- (UIButton *)screenButton1 {
    if (!_screenButton1) {
        _screenButton1 = [[UIButton alloc] init];
        [_screenButton1 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton1 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton1 setTitle:@"1200以内" forState:UIControlStateNormal];
        [_screenButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton1.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton1 addTarget:self action:@selector(screenButton1Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton1;
}

- (UIButton *)screenButton2 {
    if (!_screenButton2) {
        _screenButton2 = [[UIButton alloc] init];
        [_screenButton2 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton2 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton2 setTitle:@"1200-1500" forState:UIControlStateNormal];
        [_screenButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton2.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton2 addTarget:self action:@selector(screenButton2Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton2;
}

- (UIButton *)screenButton3 {
    if (!_screenButton3) {
        _screenButton3 = [[UIButton alloc] init];
        [_screenButton3 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton3 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton3 setTitle:@"1500-2000" forState:UIControlStateNormal];
        [_screenButton3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton3.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton3 addTarget:self action:@selector(screenButton3Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton3;
}

- (UIButton *)screenButton4 {
    if (!_screenButton4) {
        _screenButton4 = [[UIButton alloc] init];
        [_screenButton4 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton4 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton4 setTitle:@"2000-3000" forState:UIControlStateNormal];
        [_screenButton4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton4.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton4 addTarget:self action:@selector(screenButton4Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton4;
}

- (UIButton *)screenButton5 {
    if (!_screenButton5) {
        _screenButton5 = [[UIButton alloc] init];
        [_screenButton5 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton5 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton5 setTitle:@"3000以上" forState:UIControlStateNormal];
        [_screenButton5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton5.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton5 addTarget:self action:@selector(screenButton5Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton5;
}

- (UIButton *)screenButton6 {
    if (!_screenButton6) {
        _screenButton6 = [[UIButton alloc] init];
        [_screenButton6 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton6 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton6 setTitle:@"整租" forState:UIControlStateNormal];
        [_screenButton6 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton6.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton6 addTarget:self action:@selector(screenButton6Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton6;
}

- (UIButton *)screenButton7 {
    if (!_screenButton7) {
        _screenButton7 = [[UIButton alloc] init];
        [_screenButton7 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton7 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton7 setTitle:@"合租" forState:UIControlStateNormal];
        [_screenButton7 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton7.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton7 addTarget:self action:@selector(screenButton7Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton7;
}

- (UIButton *)screenButton8 {
    if (!_screenButton8) {
        _screenButton8 = [[UIButton alloc] init];
        [_screenButton8 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton8 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton8 setTitle:@"品牌公寓" forState:UIControlStateNormal];
        [_screenButton8 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton8.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton8 addTarget:self action:@selector(screenButton8Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton8;
}

- (UIButton *)screenButton9 {
    if (!_screenButton9) {
        _screenButton9 = [[UIButton alloc] init];
        [_screenButton9 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton9 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton9 setTitle:@"50以下" forState:UIControlStateNormal];
        [_screenButton9 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton9.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton9 addTarget:self action:@selector(screenButton9Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton9;
}

- (UIButton *)screenButton10 {
    if (!_screenButton10) {
        _screenButton10 = [[UIButton alloc] init];
        [_screenButton10 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton10 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton10 setTitle:@"50-70" forState:UIControlStateNormal];
        [_screenButton10 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton10.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton10 addTarget:self action:@selector(screenButton10Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton10;
}

- (UIButton *)screenButton11 {
    if (!_screenButton11) {
        _screenButton11 = [[UIButton alloc] init];
        [_screenButton11 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton11 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton11 setTitle:@"70-90" forState:UIControlStateNormal];
        [_screenButton11 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton11.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton11 addTarget:self action:@selector(screenButton11Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton11;
}

- (UIButton *)screenButton12 {
    if (!_screenButton12) {
        _screenButton12 = [[UIButton alloc] init];
        [_screenButton12 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton12 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton12 setTitle:@"90-110" forState:UIControlStateNormal];
        [_screenButton12 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton12.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton12 addTarget:self action:@selector(screenButton12Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton12;
}

- (UIButton *)screenButton13 {
    if (!_screenButton13) {
        _screenButton13 = [[UIButton alloc] init];
        [_screenButton13 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton13 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton13 setTitle:@"110-130" forState:UIControlStateNormal];
        [_screenButton13 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton13.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton13 addTarget:self action:@selector(screenButton13Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton13;
}

- (UIButton *)screenButton14 {
    if (!_screenButton14) {
        _screenButton14 = [[UIButton alloc] init];
        [_screenButton14 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton14 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton14 setTitle:@"130-150" forState:UIControlStateNormal];
        [_screenButton14 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton14.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton14 addTarget:self action:@selector(screenButton14Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton14;
}

- (UIButton *)screenButton15 {
    if (!_screenButton15) {
        _screenButton15 = [[UIButton alloc] init];
        [_screenButton15 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton15 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton15 setTitle:@"150-200" forState:UIControlStateNormal];
        [_screenButton15 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton15.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton15 addTarget:self action:@selector(screenButton15Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton15;
}

- (UIButton *)screenButton16 {
    if (!_screenButton16) {
        _screenButton16 = [[UIButton alloc] init];
        [_screenButton16 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton16 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton16 setTitle:@"200以上" forState:UIControlStateNormal];
        [_screenButton16 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton16.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton16 addTarget:self action:@selector(screenButton16Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton16;
}

- (UIButton *)screenButton17 {
    if (!_screenButton17) {
        _screenButton17 = [[UIButton alloc] init];
        [_screenButton17 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton17 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton17 setTitle:@"泊寓" forState:UIControlStateNormal];
        [_screenButton17 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton17.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton17 addTarget:self action:@selector(screenButton17Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton17;
}

- (UIButton *)screenButton18 {
    if (!_screenButton18) {
        _screenButton18 = [[UIButton alloc] init];
        [_screenButton18 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton18 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton18 setTitle:@"魔方" forState:UIControlStateNormal];
        [_screenButton18 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton18.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton18 addTarget:self action:@selector(screenButton18Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton18;
}

- (UIButton *)screenButton19 {
    if (!_screenButton19) {
        _screenButton19 = [[UIButton alloc] init];
        [_screenButton19 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton19 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton19 setTitle:@"爱上租" forState:UIControlStateNormal];
        [_screenButton19 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton19.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton19 addTarget:self action:@selector(screenButton19Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton19;
}

- (UIButton *)screenButton20 {
    if (!_screenButton20) {
        _screenButton20 = [[UIButton alloc] init];
        [_screenButton20 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton20 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton20 setTitle:@"红璞" forState:UIControlStateNormal];
        [_screenButton20 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton20.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton20 addTarget:self action:@selector(screenButton20Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton20;
}

- (UIButton *)screenButton21 {
    if (!_screenButton21) {
        _screenButton21 = [[UIButton alloc] init];
        [_screenButton21 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton21 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton21 setTitle:@"群岛" forState:UIControlStateNormal];
        [_screenButton21 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton21.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton21 addTarget:self action:@selector(screenButton21Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton21;
}

- (UIButton *)screenButton22 {
    if (!_screenButton22) {
        _screenButton22 = [[UIButton alloc] init];
        [_screenButton22 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton22 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton22 setTitle:@"冠寓" forState:UIControlStateNormal];
        [_screenButton22 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton22.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton22 addTarget:self action:@selector(screenButton22Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton22;
}

- (UIButton *)screenButton23 {
    if (!_screenButton23) {
        _screenButton23 = [[UIButton alloc] init];
        [_screenButton23 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton23 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton23 setTitle:@"麦家" forState:UIControlStateNormal];
        [_screenButton23 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton23.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton23 addTarget:self action:@selector(screenButton23Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton23;
}

- (UIButton *)screenButton24 {
    if (!_screenButton24) {
        _screenButton24 = [[UIButton alloc] init];
        [_screenButton24 setBackgroundImage:[self createImageWithColor:[UIColor colorWithWhite:0.9 alpha:1]] forState:UIControlStateNormal];
        [_screenButton24 setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:65/256.0 green:106/256.0 blue:225/256.0 alpha:1]] forState:UIControlStateSelected];
        [_screenButton24 setTitle:@"自如" forState:UIControlStateNormal];
        [_screenButton24 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_screenButton24.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_screenButton24 addTarget:self action:@selector(screenButton24Action) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenButton24;
}

- (UITextField *)screenTextField1 {
    if (!_screenTextField1) {
        _screenTextField1 = [[UITextField alloc] init];
        _screenTextField1.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        _screenTextField1.delegate = self;
        _screenTextField1.placeholder = @"最低价格";
    }
    return _screenTextField1;
}

- (UITextField *)screenTextField2 {
    if (!_screenTextField2) {
        _screenTextField2 = [[UITextField alloc] init];
        _screenTextField2.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        _screenTextField2.delegate = self;
        _screenTextField2.placeholder = @"最高价格";
    }
    return _screenTextField2;
}

#pragma mark - public

- (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 70.0f, 30.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - subway

- (void)subwayWithLine:(NSInteger )line{
    self.mapView.zoomLevel = (zoomLevelmax + zoomLevelmin) * 0.5+0.0314;
    if (line == 11) {
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(30.290878,120.183435);
        [self requestSubwayDataWtihLine:line];
    } else if (line == 12){
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(30.278153,120.170951);
        [self requestSubwayDataWtihLine:line];
    } else if (line == 1){
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(30.278153,120.170951);
        [self requestSubwayDataWtihLine:line];
    }else if (line == 2){
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(30.270222,120.187772);
        [self requestSubwayDataWtihLine:line];
    } else if (line == 4){
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(30.236847,120.204085);
        [self requestSubwayDataWtihLine:line];
    }
    
    
}
/////

//request subway data
- (void)requestSubwayDataWtihLine:(NSInteger )line{
    NSURL *url = [NSURL URLWithString:@"http://jia3.tmsf.com/hzf/hzf_subway.jspx"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            weakSelf.subArr = [[NSArray alloc] initWithArray:[dict objectForKey:@"list"]];
            
            NSMutableArray * mutableArr1 = [[NSMutableArray alloc] init];
            NSMutableArray * mutableArr11 = [[NSMutableArray alloc] init];
            NSMutableArray * mutableArr12 = [[NSMutableArray alloc] init];
            NSMutableArray * mutableArr2 = [[NSMutableArray alloc] init];
            NSMutableArray * mutableArr4 = [[NSMutableArray alloc] init];
            
            for (NSDictionary * dic in weakSelf.subArr) {
                if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"psubid"]] isEqualToString:@"1"]) {
                    [mutableArr11 addObject:dic];
                    [mutableArr12 addObject:dic];
                    [mutableArr1 addObject:dic];
                    
                } else if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"psubid"]] isEqualToString:@"2"]) {
                    [mutableArr2 addObject:dic];
                }else if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"psubid"]] isEqualToString:@"4"]) {
                    [mutableArr4 addObject:dic];
                }
            }
            
            
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"乔司南"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"乔司"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"翁梅"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"余杭高铁站"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"南苑"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr11) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"临平"]) {
                    [mutableArr11 removeObject:dic];
                    break;
                }
            }
            
            //
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"下沙西"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"金沙湖"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"高沙路"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"文泽路"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"文海南路"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"云水"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            for (NSDictionary * dic in mutableArr12) {
                if ([[dic objectForKey:@"subname"] isEqualToString:@"下沙江滨"]) {
                    [mutableArr12 removeObject:dic];
                    break;
                }
            }
            
            self.subwayData = [[NSMutableDictionary alloc] init];
            [self.subwayData setValue:mutableArr11 forKey:@"11"];
            [self.subwayData setValue:mutableArr12 forKey:@"12"];
            [self.subwayData setValue:mutableArr2 forKey:@"2"];
            [self.subwayData setValue:mutableArr4 forKey:@"4"];
            [self.subwayData setValue:mutableArr1 forKey:@"1"];
            
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.mapView removeAnnotations:self.mapView.annotations];
//            });
            
        

            if (line == 11) {
//                [mutableArr11[0] objectForKey:@"prjy"];
//                [mutableArr11[0] objectForKey:@"prjx"];
//                [mutableArr11[0] objectForKey:@"subname"];
                for (NSDictionary * dic in mutableArr11) {
                    double a = [[dic objectForKey:@"prjy"] doubleValue];
                    double b =  [[dic objectForKey:@"prjx"] doubleValue];
                    [self requestSubwayWithCoordinate:CLLocationCoordinate2DMake(a, b) name:[dic objectForKey:@"subname"]];
                }
            }else if (line == 12){
                for (NSDictionary * dic in mutableArr12) {
                    double a = [[dic objectForKey:@"prjy"] doubleValue];
                    double b =  [[dic objectForKey:@"prjx"] doubleValue];
                    [self requestSubwayWithCoordinate:CLLocationCoordinate2DMake(a, b) name:[dic objectForKey:@"subname"]];
                }
            } else if (line == 1){
                for (NSDictionary * dic in mutableArr1) {
                    double a = [[dic objectForKey:@"prjy"] doubleValue];
                    double b =  [[dic objectForKey:@"prjx"] doubleValue];
                    [self requestSubwayWithCoordinate:CLLocationCoordinate2DMake(a, b) name:[dic objectForKey:@"subname"]];
                }
            }else if (line == 2){
                for (NSDictionary * dic in mutableArr2) {
                    double a = [[dic objectForKey:@"prjy"] doubleValue];
                    double b =  [[dic objectForKey:@"prjx"] doubleValue];
                    [self requestSubwayWithCoordinate:CLLocationCoordinate2DMake(a, b) name:[dic objectForKey:@"subname"]];
                }
            }  else if (line == 4){
                for (NSDictionary * dic in mutableArr4) {
                    double a = [[dic objectForKey:@"prjy"] doubleValue];
                    double b =  [[dic objectForKey:@"prjx"] doubleValue];
                    [self requestSubwayWithCoordinate:CLLocationCoordinate2DMake(a, b) name:[dic objectForKey:@"subname"]];
                }
            }
            
        }
    }];
    [dataTask resume];
}

- (void)requestSubwayWithCoordinate:(CLLocationCoordinate2D )coordinate name:(NSString *)name{
    
    NSString * distance = @"1";
    NSString * fanglingzoom= @"";
    NSString * lat= [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString * lng= [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString * maprentjzmjzoom = @""; //价格
    NSString * maprenttypezoom = @""; //类型
    NSString * maprentzjjezoom = @""; //面积
    NSString * maprentppmczoom = @""; //品牌
    NSString * mapfwcxzoom= @"";
    NSString * maphousetypezoom= @"";
    NSString * mapjzmjzoom= @"";
    NSString * mappricezoom= @"";
    NSString * mapratezoom= @"";
    NSString * mapszlczoom= @"";
    NSString * mapzxbzzoom= @"";
    NSString * neLat= [NSString stringWithFormat:@"%f",coordinate.latitude+0.03];
    NSString * neLng= [NSString stringWithFormat:@"%f",coordinate.longitude+0.03];
    NSString * rp= @"30";
    NSString * swLat= [NSString stringWithFormat:@"%f",coordinate.latitude-0.03];
    NSString * swLng= [NSString stringWithFormat:@"%f",coordinate.longitude-0.03];
    
    NSString * distance1 = [NSString stringWithFormat:@"distance=%@",distance]; //距离
    NSString * fanglingzoom1 = [NSString stringWithFormat:@"&fanglingzoom=%@",fanglingzoom];
    NSString * lat1 = [NSString stringWithFormat:@"&lat=%@",lat]; // 中心纬度
    NSString * lng1 = [NSString stringWithFormat:@"&lng=%@",lng]; // 中心经度
    NSString * mapfwcxzoom1 = [NSString stringWithFormat:@"&mapfwcxzoom=%@",mapfwcxzoom];
    NSString * maphousetypezoom1 = [NSString stringWithFormat:@"&maphousetypezoom=%@",maphousetypezoom];
    NSString * mapjzmjzoom1 = [NSString stringWithFormat:@"&mapjzmjzoom=%@",mapjzmjzoom];
    NSString * mappricezoom1 = [NSString stringWithFormat:@"&mappricezoom=%@",mappricezoom];
    NSString * mapratezoom1 = [NSString stringWithFormat:@"&mapratezoom=%@",mapratezoom];
    NSString * mapszlczoom1 = [NSString stringWithFormat:@"&mapszlczoom=%@",mapszlczoom];
    NSString * mapzxbzzoom1 = [NSString stringWithFormat:@"&mapzxbzzoom=%@",mapzxbzzoom];
    NSString * neLat1 = [NSString stringWithFormat:@"&neLat=%@",neLat]; //东北纬度
    NSString * neLng1 = [NSString stringWithFormat:@"&neLng=%@",neLng]; //东北经度
    NSString * rp1 = [NSString stringWithFormat:@"&rp=%@",rp];
    NSString * swLat1 = [NSString stringWithFormat:@"&swLat=%@",swLat]; //西南纬度
    NSString * swLng1 = [NSString stringWithFormat:@"&swLng=%@",swLng]; //西南经度
    
    NSString * maprentjzmjzoom1 = [NSString stringWithFormat:@"&maprentjzmjzoom=%@",maprentjzmjzoom]; //价格
    NSString * maprenttypezoom1 = [NSString stringWithFormat:@"&maprenttypezoom=%@",maprenttypezoom]; ///类型
    NSString * maprentzjjezoom1 = [NSString stringWithFormat:@"&maprentzjjezoom=%@",maprentzjjezoom];  //面积
    NSString * maprentppmczoom1 = [NSString stringWithFormat:@"&maprentppmczoom=%@",maprentppmczoom]; ///品牌
    
    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",distance1,fanglingzoom1,lat1,lng1,mapfwcxzoom1,maphousetypezoom1,mapjzmjzoom1,mappricezoom1,mapratezoom1,mapszlczoom1,mapzxbzzoom1,neLat1,neLng1,rp1,swLat1,swLng1,maprentjzmjzoom1,maprentzjjezoom1,maprenttypezoom1,maprentppmczoom1];
    
    NSString * unicodeStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * url = [NSString stringWithFormat:@"%@?%@",@"http://m.howzf.com/hzf/esf_communitylist.jspx",unicodeStr];
    NSLog(@"%@",url);
    NSURL *url1 = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url1];
    NSURLSession *session = [NSURLSession sharedSession];
    NSLog(@"开始请求数据");
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"获取到数据");
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"解析完成");
            
            
            long num = 0;
            NSArray * tempArr = [[NSArray alloc] initWithArray:[dict objectForKey:@"list"]];
            for (NSDictionary * dic in tempArr) {
                NSString * count = [NSString stringWithFormat:@"%@",[dic objectForKey:@"czcount"]];
                num = num+[count longLongValue];
            }
            
            NSLog(@"num == %ld",num);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showPaopaoWithType:@"4" withData:@[@{ @"prjy":[NSString stringWithFormat:@"%f",coordinate.latitude],
                                                                @"prjx":[NSString stringWithFormat:@"%f",coordinate.longitude],
                                                                @"subwayname":name,
                                                                @"czcount":[NSString stringWithFormat:@"%ld",num]}]];
                
            });
        
            
        }
    }];
    
    [dataTask resume];
}

- (void)showAlertWithCount:(long) count{
    UILabel * label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"为您找到了%ld套房源。",count];
    label.backgroundColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.equalTo(@40);
    }];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [label removeFromSuperview];
    });
}
@end
