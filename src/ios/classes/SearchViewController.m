//
//  SearchViewController.m
//  mapHouse
//
//  Created by duy on 2019/6/3.
//  Copyright © 2019 duy. All rights reserved.
//

#import "SearchViewController.h"
#import "Masonry.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface SearchViewController () <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) UIButton * closeButton;

@property (nonatomic, strong) UITableView * tableview;

@property (nonatomic, strong) NSArray * listArr;
@property (nonatomic, strong) NSMutableArray * matchArr;

@property (nonatomic, strong) UIView * headView;

@property (nonatomic, strong) NSDictionary * data;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view. backgroundColor = [UIColor whiteColor];
    [self.navigationItem setHidesBackButton:YES];
    self.matchArr = [[NSMutableArray alloc] init];
    [self.navigationController.navigationBar addSubview:self.closeButton];
    [self.navigationController.navigationBar addSubview:self.textField];
    
    [self.textField becomeFirstResponder];
    
    [self.view addSubview:self.tableview];
    
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.left.right.equalTo(self.view);
    }];
    
    [self requestData];
    
    self.tableview.tableHeaderView = self.headView;

}

-(void)requestData{
    NSString * url = @"http://m.howzf.com/hzf/hzf_keywordlist.jspx";
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
            NSLog(@"解析完成");
            
            
            NSArray * arr1 = [[NSArray alloc] initWithArray:[dict objectForKey:@"arealist"]];
            NSArray * arr2 = [[NSArray alloc] initWithArray:[dict objectForKey:@"communitylist"]];
            NSArray * arr3 = [[NSArray alloc] initWithArray:[dict objectForKey:@"subwaylist"]];

            NSMutableArray * mutableArr1 = [[NSMutableArray alloc] init];
            for (NSDictionary * dic in arr1) {
                NSMutableDictionary * mutableArrTemp = [[NSMutableDictionary alloc] initWithDictionary:dic];
                if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"pareaid"]] isEqualToString:@"33"] ) {
                    [mutableArrTemp setObject:@"chengqu" forKey:@"type"];
                } else {
                    [mutableArrTemp setObject:@"shangquan" forKey:@"type"];
                }
                [mutableArr1 addObject:mutableArrTemp];
            }
            
            
            for (NSDictionary * dic in arr3) {
                NSMutableDictionary * mutableArrTemp = [[NSMutableDictionary alloc] initWithDictionary:dic];
                if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"psubid"]] isEqualToString:@"0"] ) {
                    [mutableArrTemp setObject:@"xianlu" forKey:@"type"];
                } else {
                    [mutableArrTemp setObject:@"zhandian" forKey:@"type"];
                }
                [mutableArr1 addObject:mutableArrTemp];
            }
            
            for (NSDictionary * dic in arr2) {
                NSMutableDictionary * mutableArrTemp = [[NSMutableDictionary alloc] initWithDictionary:dic];
                [mutableArrTemp setObject:@"shequ" forKey:@"type"];
                [mutableArr1 addObject:mutableArrTemp];
            }
            
            weakSelf.listArr = [[NSArray alloc] initWithArray:mutableArr1];
        
        }
    }];
    
    //5.执行任务
    [dataTask resume];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBar.hidden = NO;
    [self.closeButton removeFromSuperview];
    [self.textField removeFromSuperview];
}

#pragma mark -

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.textField.text.length == 0) {
        NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
        NSMutableArray * tempArr = [[NSMutableArray alloc] initWithArray:[user objectForKey:@"searchHistory"]];
        return tempArr.count;
    }
    return self.matchArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    NSMutableArray * tempArr = [[NSMutableArray alloc] initWithArray:[user objectForKey:@"searchHistory"]];
    
    if (self.textField.text.length == 0) {
        cell.textLabel.text = [tempArr[indexPath.row] objectForKey:@"name"];
        if ([[tempArr[indexPath.row] objectForKey:@"type"] isEqualToString:@"zhandian"]) {
            
        } else if([[tempArr[indexPath.row] objectForKey:@"type"] isEqualToString:@"xianlu"]){
            
        }else{
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@套",[tempArr[indexPath.row] objectForKey:@"czcount"]];
        }
    } else {
        cell.textLabel.text = [self.matchArr[indexPath.row] objectForKey:@"name"];
        if ([[self.matchArr[indexPath.row] objectForKey:@"type"] isEqualToString:@"zhandian"]) {
            
        } else if([[self.matchArr[indexPath.row] objectForKey:@"type"] isEqualToString:@"xianlu"]){
            
        }else{
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@套",[self.matchArr[indexPath.row] objectForKey:@"czcount"]];
        }
    }
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (self.textField.text.length == 0) {
        NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
        NSMutableArray * tempArr = [[NSMutableArray alloc] initWithArray:[user objectForKey:@"searchHistory"]];
        self.data = [[NSDictionary alloc] initWithDictionary:tempArr[indexPath.row]];
        
        if ([[self.data objectForKey:@"type"] isEqualToString:@"zhandian"]) {
            if (self.returnValueBlock) {
                self.returnValueBlock(self.data);
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else if ([[self.data objectForKey:@"type"] isEqualToString:@"xianlu"]){
            if (self.returnValueBlock) {
                self.returnValueBlock(self.data);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([[self.data objectForKey:@"type"] isEqualToString:@"shequ"]){
            if (self.returnValueBlock) {
                self.returnValueBlock(self.data);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([[self.data objectForKey:@"type"] isEqualToString:@"shangquan"]){
            if (self.returnValueBlock) {
                self.returnValueBlock(self.data);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([[self.data objectForKey:@"type"] isEqualToString:@"chengqu"]){
            if (self.returnValueBlock) {
                self.returnValueBlock(self.data);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            NSLog(@"bug");
        }
    } else {
        self.data = [[NSDictionary alloc] initWithDictionary:self.matchArr[indexPath.row]];
        
        NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
        NSMutableArray * tempArr = [[NSMutableArray alloc] initWithArray:[user objectForKey:@"searchHistory"]];
        [tempArr addObject:self.data];
        [user setObject:tempArr forKey:@"searchHistory"];
        
        if ([[self.data objectForKey:@"type"] isEqualToString:@"zhandian"]) {
            if (self.returnValueBlock) {
                self.returnValueBlock(self.data);
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else if ([[self.data objectForKey:@"type"] isEqualToString:@"xianlu"]){
            if (self.returnValueBlock) {
                self.returnValueBlock(self.data);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([[self.data objectForKey:@"type"] isEqualToString:@"shequ"]){
            if (self.returnValueBlock) {
                self.returnValueBlock(self.data);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([[self.data objectForKey:@"type"] isEqualToString:@"shangquan"]){
            if (self.returnValueBlock) {
                self.returnValueBlock(self.data);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([[self.data objectForKey:@"type"] isEqualToString:@"chengqu"]){
            if (self.returnValueBlock) {
                self.returnValueBlock(self.data);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            NSLog(@"bug");
        }
    }
    
    
    
}

#pragma mark -
- (void)textFieldEditChanged:(UITextField *)textField
{
    if (textField.text.length ==0) {
        self.tableview.tableHeaderView = self.headView;
    } else {
        self.tableview.tableHeaderView = nil;
    }
    
    // 模糊查询
    self.matchArr = [[NSMutableArray alloc] init];
    
    for (NSDictionary * dic in self.listArr) {
        NSString * matchString1 = [dic objectForKey:@"name"];
        NSString * matchString2 = [dic objectForKey:@"py"];
        NSString * matchString3 = [dic objectForKey:@"py2"];
        
        //        NSLog(@"%@",matchString1);
        
//
        if([matchString1 containsString:textField.text])
        {
            [self.matchArr addObject:dic];
        } else if ([matchString2 containsString:textField.text]){
            [self.matchArr addObject:dic];
        } else if ([matchString3 containsString:textField.text]){
            [self.matchArr addObject:dic];
        }
    }
    [self.tableview reloadData];
}



#pragma mark -
- (void)close{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 5, kWidth-110, 34)];
        _textField.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        _textField.delegate = self;
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入您要搜索的内容"];
        UIImageView * leftPhoneImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (_textField.frame.size.height - 20)*0.5, 40, 20)];
        leftPhoneImgView.image = [UIImage imageNamed:@"4321559360565_.pic_thumb.jpg"];
        leftPhoneImgView.contentMode = UIViewContentModeScaleAspectFit;
        _textField.leftView = leftPhoneImgView;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        [_textField addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];

    }
    return _textField;
}


- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(kWidth-70, 0, 50, 40)];
//        [_closeButton setBackgroundImage:[self createImageWithColor:[UIColor yellowColor]] forState:UIControlStateNormal];
        [_closeButton setTitle:@"取消" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_closeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc] init];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.tableFooterView = [[UIView alloc] init];
    }
    return _tableview;
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

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 50)];
        _headView.backgroundColor = [UIColor whiteColor];
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(kWidth - 60, 15, 30, 30)];
        [btn setImage:[UIImage imageNamed:@"4371559361163_.pic.jpg"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:btn];
        
        UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(25, 5, 80, 40)];
        lab.textColor = [UIColor blackColor];
        lab.text = @"搜索历史";
        [_headView addSubview:lab];
    }
    return _headView;
}

- (void)delete{
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    NSMutableArray * tempArr = nil;
    [user setObject:tempArr forKey:@"searchHistory"];
    [self.tableview reloadData];
}

@end
