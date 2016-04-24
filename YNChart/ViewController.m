//
//  ViewController.m
//  YNChart
//
//  Created by yangzhixiao on 16/4/24.
//  Copyright (c) 2016年 yangzhixiao. All rights reserved.
//

#import "ViewController.h"
#import "YNBarView.h"

@interface ViewController ()
@property (strong, nonatomic) YNBarView *barView;
@end

#define YNRGB(r,g,b) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1]

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    YNBarView *barView = [[YNBarView alloc]init];
    barView.frame = CGRectMake(20, 50, 320, 300);
    [self.view addSubview:barView];
    
    self.barView = barView;
    self.barView.xLabelHidden = YES;
    self.barView.backgroundColor = YNRGB(22, 169, 189);
    self.barView.xAxisData = @[@"1月", @"2月", @"3月", @"4月", @"5月"];
    self.barView.yAxisData = @[@"100", @"800", @"300", @"600", @"500"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.barView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
