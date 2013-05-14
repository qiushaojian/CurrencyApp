//
//  LDMainViewController.m
//  CurrencyApp
//
//  Created by Cash on 13-5-12.
//  Copyright (c) 2013年 LYFORD INTERNATIONAL TRADING PORT PTY.LTD. All rights reserved.
//

//#import "LDMainViewController.h"
//
//#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//
//
//@interface LDMainViewController ()
//
//@end
//
//@implementation LDMainViewController
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
////      self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480+(iPhone5?88:0))];
//    }
//    return self;
//}
//
//- (id)init
//{
//  self = [super init];
//  if (self) {
////    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480+(iPhone5?88:0))];
//  }
//  return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//  self.view.backgroundColor = [UIColor redColor];
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//@end

#import "LDMainViewController.h"
#import "LDHeadCell.h"
#import "LDCurrencyCell.h"
#import "LDNavigationBar.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface LDMainViewController ()



@end

@implementation LDMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    //读入CurrencyKyes备用
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"CurrencyKeys" withExtension:@"plist"];
    NSArray *plistArray = [NSArray arrayWithContentsOfURL:plistURL];
    self.curKeysArray = plistArray;
    
    self.navBar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    
//    NSLog(@"%f, %@", self.view.frame.size.height-44, NSStringFromCGRect(self.view.frame));
    
//    CGFloat f = self.view.frame.size.height-44;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 504) style:UITableViewStylePlain];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView setBackgroundColor:RGBA(220, 211, 204, 1.0)];
    self.contentView = tableView;
    [tableView release];
    
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self.view setBackgroundColor:[UIColor grayColor]];
  
  if (self.navBar) {
    [self.view addSubview:self.navBar];
  }
  
  if (self.contentView) {
    [self.view addSubview:self.contentView];
  }
  
  //  UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  //  [titleButton addTarget:self action:@selector(linkLdport:) forControlEvents:UIControlEventTouchUpInside];
  //  self.navBar.topItem.titleView = titleButton;
  //  [titleButton release];
  
  //  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
  //  [view setBackgroundColor:[UIColor grayColor]];
  //
  //  UILabel *labelTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
  //  labelTop.textColor = [UIColor whiteColor];
  //  labelTop.backgroundColor = [UIColor clearColor];
  //  labelTop.textAlignment = NSTextAlignmentCenter;
  //  labelTop.text = @"总行交易员的外汇知识和交易技巧";
  //  [view addSubview:labelTop];
  //  [labelTop release];
  //
  //  UILabel *labelBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 20)];
  //  labelBottom.textColor = [UIColor whiteColor];
  //  labelBottom.backgroundColor = [UIColor clearColor];
  //  labelBottom.textAlignment = NSTextAlignmentCenter;
  //  labelBottom.text = @"立体式思维解析外汇市场";
  //  [view addSubview:labelBottom];
  //  [labelBottom release];
  
  //  UIButton *headerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
  //  [headerButton addTarget:self action:@selector(linkLdport:) forControlEvents:UIControlEventTouchUpInside];
  //  [view addSubview:headerButton];
  //  [headerButton release];
  
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
  [view setBackgroundColor:[UIColor grayColor]];
  
  UILabel *labelTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
  labelTop.textColor = [UIColor whiteColor];
  labelTop.backgroundColor = [UIColor clearColor];
  labelTop.textAlignment = NSTextAlignmentCenter;
  labelTop.font = [UIFont fontWithName:@"Verdana" size:[UIFont systemFontSize]];
  labelTop.text = @"Updated 10 Apr 2013 04:59:00 GMT";
  [view addSubview:labelTop];
  [labelTop release];
  
  self.topView = view;
  [view release];
  
  /* GCD方式实现 */
  [self refreshInBackground];
  
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}


/**
 * 更新数据并发出重绘tableview消息
 */
- (void)refreshInBackground
{
  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    while (true) {
      // 下载数据
      NSString *urlString = [NSString stringWithFormat:@"%@?_=%u", kLDFxall_TopRates_Url, (NSUInteger)[[NSDate date] timeIntervalSince1970]];
      NSURL *url = [NSURL URLWithString:urlString];
      ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
      [request startSynchronous];
      NSError *error = [request error];
      if (!error) {
        self.ratesDict = [[request responseString] objectFromJSONString];
        
        self.ratesDictionary = [self.ratesDict objectForKey:@"rates"];
        [self setValue:[self.ratesDict objectForKey:@"updateDateTime"] forKey:@"updateTimeString"];
        //        self.updateTimeString = [dict objectForKey:@"updateDateTime"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.contentView reloadData];
          [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
        [NSThread sleepForTimeInterval:3];
      }
      else {
        dispatch_async(dispatch_get_main_queue(), ^{
          [MBProgressHUD hideHUDForView:self.view animated:YES];
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                          message:@"连接服务器失败！"
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:@"尝试重连", nil];
          [alert show];
          [alert release];
        });
        break;
      }
    }
  });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  switch (buttonIndex) {
    case 1: //尝试重连
      [self refreshInBackground];
      break;
      
    default: //取消
      break;
  }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  if (self.topView) {
    return self.topView.frame.size.height;
  }
  return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  return self.topView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.curKeysArray.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0) {
    return 40;
  }
  else {
    return 60;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *LDCurrencyCellIdentifier = @"LDCurrencyCellIdentifier";
  static NSString *LDHeadCellIdentifier = @"LDHeadCellIdentifier";
  
  static BOOL nibsRegistered = NO;
  if (!nibsRegistered) {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      [tableView registerNib:[UINib nibWithNibName:@"LDHeadCell_iPhone" bundle:nil]
      forCellReuseIdentifier:LDHeadCellIdentifier];
      
      //      [tableView registerNib:[UINib nibWithNibName:@"LDCurrencyCell_iPhone" bundle:nil]
      //      forCellReuseIdentifier:LDCurrencyCellIdentifier];
    } else {
      [tableView registerNib:[UINib nibWithNibName:@"LDHeadCell_iPad" bundle:nil]
      forCellReuseIdentifier:LDHeadCellIdentifier];
      
      //      [tableView registerNib:[UINib nibWithNibName:@"LDCurrencyCell_iPad" bundle:nil]
      //      forCellReuseIdentifier:LDCurrencyCellIdentifier];
    }
    nibsRegistered = YES;
  }
  
  UITableViewCell *cell;
  
  if (indexPath.row == 0) {
    cell = [tableView dequeueReusableCellWithIdentifier:LDHeadCellIdentifier];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:LDHeadCellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  else {
    cell = [tableView dequeueReusableCellWithIdentifier:LDCurrencyCellIdentifier];
    if (cell == nil) {
      cell = [[[LDCurrencyCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:LDCurrencyCellIdentifier] autorelease];
    }
    
    NSDictionary *curDictionary = [self.ratesDictionary objectForKey:[self.curKeysArray objectAtIndex:indexPath.row - 1]];
    
    LDCurrencyCell *curCell = (LDCurrencyCell *)cell;
    curCell.curKey = [curDictionary objectForKey:@"instrument"];
    curCell.curBid = [curDictionary objectForKey:@"formattedBid"];
    curCell.curOffer = [curDictionary objectForKey:@"formattedAsk"];
    curCell.curChange = [curDictionary objectForKey:@"formattedChange"];
    curCell.curLow = [curDictionary objectForKey:@"formattedLow"];
    curCell.curHigh = [curDictionary objectForKey:@"formattedHigh"];
  }
  
  return cell;
}

- (void)linkLdport:(id)sender
{
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ldport.com/"]];
}

- (IBAction)linkAnalyse:(id)sender
{
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ldport.com/plus/list.php?tid=132"]];
}

@end