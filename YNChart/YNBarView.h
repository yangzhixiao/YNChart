//
//  YNBarView.h
//  YNChart
//
//  Created by yangzhixiao on 16/4/24.
//  Copyright (c) 2016年 yangzhixiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YNBarView : UIView
@property (strong, nonatomic) UIColor *axisLineColor;
@property (strong, nonatomic) UIColor *xLabelColor;
@property (strong, nonatomic) UIColor *barBackGroundColor;
@property (strong, nonatomic) UIColor *barForgroundColor;
@property (strong, nonatomic) NSArray *xAxisData;
@property (strong, nonatomic) NSArray *yAxisData;
@property (assign, nonatomic) CGFloat paddingLeft;
@property (assign, nonatomic) CGFloat paddingBottom;
@property (assign, nonatomic) CGFloat barWidth;

- (void)reloadData;

@end
