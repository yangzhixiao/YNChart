//
//  YNBarView.m
//  YNChart
//
//  Created by yangzhixiao on 16/4/24.
//  Copyright (c) 2016年 yangzhixiao. All rights reserved.
//

#import "YNBarView.h"

#define YNRGB(r,g,b) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1]

@interface YNBarView()
@end

@implementation YNBarView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.axisLineColor = YNRGB(230, 230, 230);
        self.xAxisData = @[@"1月", @"2月", @"3月", @"4月", @"5月"];
        self.yAxisData = @[@"100", @"800", @"300", @"600", @"500"];
        self.xLabelColor = YNRGB(178, 178, 178);
        self.barBackGroundColor = YNRGB(247, 247, 247);
        self.barForgroundColor = YNRGB(255, 230, 22);
        self.barWidth = 10;
        self.paddingLeft = 20;
        self.paddingBottom = 20;
    }
    return self;
}

- (void)reloadData {
//    [self setNeedsDisplay];
}

- (CGFloat)maxYFromData:(NSArray *)data {
    NSArray *tempArray = [data sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 floatValue] > [obj2 floatValue];
    }];
    return [tempArray.lastObject floatValue];
}

- (CGFloat)dynamicHeight:(CGFloat)height FromMax: (CGFloat)maxHeight {
    return ( height / maxHeight ) * ( self.bounds.size.height - self.paddingBottom * 2) * .9f;
}

- (void)drawRect:(CGRect)rect {
    
    NSLog(@"layers: %@", @(self.layer.sublayers.count));
    
    __weak YNBarView *weakSelf = self;
    
    CGFloat paddingLeft = self.paddingLeft;
    CGFloat paddingBottom = self.paddingBottom;
    
    CGFloat maxY = [self maxYFromData:self.yAxisData];
    
    //x轴
    CALayer *xAxisLine = [CALayer layer];
    xAxisLine.frame = CGRectMake(paddingLeft, rect.size.height-paddingBottom, rect.size.width-paddingLeft * 2, 0.5f);
    xAxisLine.borderWidth = 0.5f;
    xAxisLine.borderColor = self.axisLineColor.CGColor;
    [self.layer addSublayer:xAxisLine];
    
    //y轴
    CALayer *yAxisLine = [CALayer layer];
    yAxisLine.frame = CGRectMake(paddingLeft, paddingBottom, 0.5f, rect.size.height-paddingBottom * 2);
    yAxisLine.borderWidth = 0.5f;
    yAxisLine.borderColor = self.axisLineColor.CGColor;
    [self.layer addSublayer:yAxisLine];
    
    //x data
    CGFloat barEachWidth = (rect.size.width - paddingLeft * 2) / self.xAxisData.count;
    [self.xAxisData enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL *stop) {
        __strong YNBarView *strongSelf = weakSelf;
        CGFloat yValue = [strongSelf.yAxisData[idx] floatValue];
        
        //x text label
        CGRect labelFrame = CGRectMake(paddingLeft + barEachWidth * idx, xAxisLine.frame.origin.y + 12, barEachWidth, 12);
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.frame = labelFrame;
        textLayer.string = text;
        textLayer.fontSize = 10.f;
        textLayer.foregroundColor = strongSelf.xLabelColor.CGColor;
        textLayer.alignmentMode = kCAAlignmentCenter;
        [strongSelf.layer addSublayer:textLayer];
        
        //bar background layer
        CGRect xBarBgFrame = CGRectMake(paddingLeft + barEachWidth * idx + barEachWidth / 2.f - strongSelf.barWidth / 2.f,
                                        paddingBottom,
                                        strongSelf.barWidth,
                                        rect.size.height-paddingBottom * 2);
        CALayer *xBarBgLayer = [CALayer layer];
        xBarBgLayer.frame = xBarBgFrame;
        xBarBgLayer.backgroundColor = strongSelf.barBackGroundColor.CGColor;
        xBarBgLayer.masksToBounds = YES;
        [strongSelf.layer addSublayer:xBarBgLayer];
        
        //bar layer
        CGFloat barHeight = [strongSelf dynamicHeight:yValue FromMax:maxY];
        CALayer *xBarLayer = [CALayer layer];
        xBarLayer.anchorPoint = CGPointMake(0, 0);
        xBarLayer.bounds = CGRectMake(0, 0, strongSelf.barWidth, barHeight);
        xBarLayer.position = CGPointMake(0, xBarBgFrame.size.height);
        xBarLayer.backgroundColor = strongSelf.barForgroundColor.CGColor;
        [xBarBgLayer addSublayer:xBarLayer];

        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"position"];
        ani.toValue = [NSValue valueWithCGPoint:CGPointMake(0, xBarBgFrame.size.height - barHeight)];
        ani.duration = 2.f;
        ani.removedOnCompletion = NO;
        ani.fillMode = kCAFillModeForwards;
        ani.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
        [xBarLayer addAnimation:ani forKey:nil];
        
    }];
    
}


@end
