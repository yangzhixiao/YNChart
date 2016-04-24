//
//  YNBarView.h
//  YNChart
//
//  Created by yangzhixiao on 16/4/24.
//  Copyright (c) 2016年 yangzhixiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YNBarView;

@protocol YNBarViewDelegate <NSObject>
@optional
- (UIView*)viewTipsForBarViewYAxisAtIndex:(NSInteger)idx;
- (void)barView:(YNBarView*)barView didTapBarAtIndex:(NSInteger)idx;
@end

@interface YNBarView : UIView
@property (strong, nonatomic) UIColor *axisLineColor;
@property (strong, nonatomic) UIColor *xLabelColor;
@property (strong, nonatomic) UIColor *barBackGroundColor;
@property (strong, nonatomic) UIColor *barForgroundColor;
@property (strong, nonatomic) NSArray *xAxisData;
@property (strong, nonatomic) NSArray *yAxisData;
@property (assign, nonatomic) UIEdgeInsets paddingInset;
@property (assign, nonatomic) CGFloat barWidth;
@property (assign, nonatomic) CGFloat barSpaceWidth;
@property (assign, nonatomic) CGFloat barCornerRadius;
@property (assign, nonatomic) NSTimeInterval animateDuration;

@property (assign, nonatomic) BOOL xLabelHidden;
@property (assign, nonatomic) BOOL backGroundLayerHidden;
@property (assign, nonatomic) BOOL showBarAnimate;
@property (assign, nonatomic) BOOL showBaseLine;

@property (assign, nonatomic) id<YNBarViewDelegate> barDelegate;

- (UIView*)descriptLabelViewForIndex:(NSInteger)idx;
- (void)reloadData;

@end
