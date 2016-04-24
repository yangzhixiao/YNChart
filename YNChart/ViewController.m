//
//  ViewController.m
//  YNChart
//
//  Created by yangzhixiao on 16/4/24.
//  Copyright (c) 2016年 yangzhixiao. All rights reserved.
//

#import "ViewController.h"
#import "YNBarView.h"

@interface ViewController ()<YNBarViewDelegate>
@property (strong, nonatomic) YNBarView *barView;
@property (weak, nonatomic) UIButton *selectedBubble;
@property (weak, nonatomic) UIButton *selectedItem;
@property (weak, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIScrollView *scrollView;
@end

#define YNRGB(r,g,b) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1]

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGSize winSize = [UIScreen mainScreen].applicationFrame.size;
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.frame = CGRectMake(0, 50, winSize.width, 300);
    scrollView.contentSize = CGSizeMake(100 * 12, 300);
    [self.view addSubview:scrollView];
    
    YNBarView *barView = [[YNBarView alloc]init];
    barView.frame = CGRectMake(0, 0, 100 * 12, 300);
    [scrollView addSubview:barView];
    
    self.barView = barView;
    self.barView.xLabelHidden = YES;
    self.barView.showBaseLine = NO;
    self.barView.backgroundColor = YNRGB(22, 169, 189);
    self.barView.xAxisData = @[@"1月", @"2月", @"3月", @"4月", @"5月", @"6月",@"7月", @"8月", @"9月", @"10月", @"11月", @"12月"];
    self.barView.yAxisData = @[@"100", @"800", @"300", @"600", @"500", @"1200",@"200", @"700", @"900", @"600", @"500", @"1100"];
    self.barView.barDelegate = self;
    self.barView.paddingInset = UIEdgeInsetsMake(10, 0, 40, 0);
    self.barView.animateDuration = 5.f;
    self.barView.barSpaceWidth = 100;
    [self.barView reloadData];
    
    __weak ViewController *weakSelf = self;
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = YNRGB(247, 247, 247);
    bottomView.frame = CGRectMake(0, self.barView.bounds.size.height - 30, self.barView.bounds.size.width, 30);
    [self.barView.xAxisData enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL *stop) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = idx;
        btn.frame = CGRectMake(idx * weakSelf.barView.barSpaceWidth, 0, weakSelf.barView.barSpaceWidth, 30);
        btn.titleLabel.font = [UIFont systemFontOfSize:11.f];
        if (idx == 3) {
            text = @"本月";
        }
        [btn setTitle:text forState:UIControlStateNormal];
        [btn setTitleColor:YNRGB(102, 102, 102) forState:UIControlStateNormal];
        [btn setTitleColor:YNRGB(249, 59, 59) forState:UIControlStateSelected];
        [btn setTitleColor:YNRGB(249, 59, 59) forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(onBottomItemTap:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:btn];
    }];
    [self.barView addSubview:bottomView];
    self.bottomView = bottomView;
}

- (void)onBottomItemTap:(UIButton*)btn {
    self.selectedItem.selected = NO;
    btn.selected = YES;
    self.selectedItem = btn;
    
    self.selectedBubble.selected = NO;
    UIButton *btnItem = (UIButton*)[self.barView descriptLabelViewForIndex:btn.tag];
    btnItem.selected = YES;
    self.selectedBubble = btnItem;
}

- (void)onBubbleTap:(UIButton*)btn {
    self.selectedBubble.selected = NO;
    btn.selected = YES;
    self.selectedBubble = btn;
    
    self.selectedItem.selected = NO;
    UIButton *btnItem = (UIButton*)[self.bottomView viewWithTag:btn.tag-1000];
    btnItem.selected = YES;
    self.selectedItem = btnItem;
}

#pragma mark - BarView Delegate

- (UIView *)viewTipsForBarViewYAxisAtIndex:(NSInteger)idx {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *yValue = self.barView.yAxisData[idx];
    NSString *text = [NSString stringWithFormat:@"¥%@", yValue];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:10.f];
    btn.bounds = CGRectMake(0, 0, 50, 30);
    btn.layer.cornerRadius = 2.5f;
    [btn setBackgroundImage:[UIImage imageNamed:@"pao"] forState:UIControlStateSelected];
    [btn setBackgroundImage:[UIImage imageNamed:@"pao"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onBubbleTap:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleEdgeInsets = UIEdgeInsetsMake(-3, 0, 0, 0);
    return btn;
}

- (void)barView:(YNBarView *)barView didTapBarAtIndex:(NSInteger)idx {
    [self onBubbleTap:(UIButton *)[barView viewWithTag:idx + 1000]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
