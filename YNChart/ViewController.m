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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    YNBarView *barView = [[YNBarView alloc]init];
    barView.frame = CGRectMake(20, 50, 320, 300);
    [self.view addSubview:barView];
    
    self.barView = barView;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.barView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
