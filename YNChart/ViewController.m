//
//  ViewController.m
//  YNChart
//
//  Created by yangzhixiao on 16/4/24.
//  Copyright (c) 2016年 yangzhixiao. All rights reserved.
//

#import "ViewController.h"
#import "YNBarView.h"

@interface ViewController ()<YNBarViewDelegate, UIScrollViewDelegate>
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
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    YNBarView *barView = [[YNBarView alloc]init];
    barView.frame = CGRectMake(0, 0, 100 * 12, 300);
    [scrollView addSubview:barView];
    
    self.barView = barView;
    self.barView.xLabelHidden = YES;
    self.barView.showBaseLine = NO;
    self.barView.backgroundColor = YNRGB(22, 169, 189);
    self.barView.barDelegate = self;
    self.barView.paddingInset = UIEdgeInsetsMake(40, 0, 40, 0);
    self.barView.animateDuration = 2.f;
    self.barView.barSpaceWidth = 50;
    
    [self btnMonthClicked:nil];
}

#pragma mark - Private Methods

- (void)setupBottomView {
    [self.bottomView removeFromSuperview];
    
    __weak ViewController *weakSelf = self;
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.tag = 999;
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

#pragma mark - Events Reponse

- (void)onBottomItemTap:(UIButton*)btn {
    if (![btn isKindOfClass:[UIButton class]]) {
        return;
    }
    self.selectedItem.selected = NO;
    btn.selected = YES;
    self.selectedItem = btn;
    
    self.selectedBubble.selected = NO;
    UIButton *btnItem = (UIButton*)[self.barView descriptLabelViewForIndex:btn.tag];
    btnItem.selected = YES;
    self.selectedBubble = btnItem;
}

- (void)onBubbleTap:(UIButton*)btn {
    if (![btn isKindOfClass:[UIButton class]]) {
        return;
    }
    self.selectedBubble.selected = NO;
    btn.selected = YES;
    self.selectedBubble = btn;
    
    self.selectedItem.selected = NO;
    UIButton *btnItem = (UIButton*)[self.bottomView viewWithTag:btn.tag-1000];
    btnItem.selected = YES;
    self.selectedItem = btnItem;
}

- (IBAction)btnYearClicked:(id)sender {
    NSMutableArray *xLabels = [NSMutableArray array];
    NSMutableArray *yValues = [NSMutableArray array];
    for (NSInteger i = 0; i < 12; i++) {
        [xLabels addObject:[NSString stringWithFormat:@"%@月", @(i+1)]];
        [yValues addObject:[NSString stringWithFormat:@"%@", @(arc4random_uniform(1200))]];
    }
    
    self.barView.xAxisData = xLabels.copy;
    self.barView.yAxisData = yValues.copy;
    
    self.scrollView.contentSize = CGSizeMake(self.barView.barSpaceWidth * 12, 300);
    self.barView.frame = CGRectMake(0, 0, self.barView.barSpaceWidth * 12, 300);
    [self.barView reloadData];
    [self setupBottomView];
}

- (IBAction)btnMonthClicked:(id)sender {
    NSMutableArray *xLabels = [NSMutableArray array];
    NSMutableArray *yValues = [NSMutableArray array];
    for (NSInteger i = 0; i < 31; i++) {
        [xLabels addObject:[NSString stringWithFormat:@"%@日", @(i+1)]];
        [yValues addObject:[NSString stringWithFormat:@"%@", @(arc4random_uniform(1200))]];
    }
    
    self.barView.xAxisData = xLabels.copy;
    self.barView.yAxisData = yValues.copy;
    
    self.scrollView.contentSize = CGSizeMake(self.barView.barSpaceWidth * 31, 300);
    self.barView.frame = CGRectMake(0, 0, self.barView.barSpaceWidth * 31, 300);
    
    [self.barView reloadData];
    [self setupBottomView];
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

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self.barView setNeedFitBarHeight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
