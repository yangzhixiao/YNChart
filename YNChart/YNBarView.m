//
//  YNBarView.m
//  YNChart
//
//  Created by yangzhixiao on 16/4/24.
//  Copyright (c) 2016年 yangzhixiao. All rights reserved.
//

#import "YNBarView.h"

#define YNRGB(r,g,b) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1]
#define YNRGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:(a)]

@interface YNBarView()
@property (strong, nonatomic) NSMutableArray *barLayers;
@property (strong, nonatomic) NSMutableArray *barBgLayers;
@property (strong, nonatomic) NSMutableArray *baseLineLayers;
@property (strong, nonatomic) NSMutableArray *xLabelLayers;
@end

@implementation YNBarView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.axisLineColor = YNRGB(230, 230, 230);
        self.xLabelColor = YNRGB(178, 178, 178);
        self.barBackGroundColor = YNRGBA(255, 255, 255, .2f);
        self.barForgroundColor = YNRGB(255, 255, 255);
        self.barWidth = 10;
        self.paddingInset = UIEdgeInsetsMake(10, 20, 20, 10);
        self.barCornerRadius = 5.f;
        self.barSpaceWidth = 0;
        self.xLabelHidden = NO;
        self.backGroundLayerHidden = NO;
        self.showBarAnimate = YES;
        
        self.barLayers = @[].mutableCopy;
        self.barBgLayers = @[].mutableCopy;
        self.baseLineLayers = @[].mutableCopy;
        self.xLabelLayers = @[].mutableCopy;
        
    }
    return self;
}

- (void)reloadData {
    [self removeLayers];
    [self drawBaseLine];
    [self drawBarLayers];
}

- (void)removeLayers {
    for (NSInteger i = self.xLabelLayers.count-1; i >= 0; i--) {
        CALayer *layer = self.xLabelLayers[i];
        [layer removeFromSuperlayer];
    }
    for (NSInteger i = self.baseLineLayers.count-1; i >= 0; i--) {
        CALayer *layer = self.baseLineLayers[i];
        [layer removeFromSuperlayer];
    }
    for (NSInteger i = self.barBgLayers.count-1; i >= 0; i--) {
        CALayer *layer = self.barBgLayers[i];
        [layer removeFromSuperlayer];
    }
    for (NSInteger i = self.barLayers.count-1; i >= 0; i--) {
        CALayer *layer = self.barLayers[i];
        [layer removeFromSuperlayer];
    }
    
}

- (CGFloat)maxYFromData:(NSArray *)data {
    NSArray *tempArray = [data sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 floatValue] > [obj2 floatValue];
    }];
    return [tempArray.lastObject floatValue];
}

- (CGFloat)dynamicHeight:(CGFloat)height FromMax: (CGFloat)maxHeight {
    return ( height / maxHeight ) * ( self.bounds.size.height - self.paddingInset.top - self.paddingInset.bottom) * .9f;
}

- (void)drawBaseLine {
    CGRect rect = self.bounds;
    //x轴
    CALayer *xAxisLine = [CALayer layer];
    xAxisLine.frame = CGRectMake(self.paddingInset.left,
                                 rect.size.height-self.paddingInset.bottom,
                                 rect.size.width-self.paddingInset.left-self.paddingInset.right,
                                 0.5f);
    xAxisLine.borderWidth = 0.5f;
    xAxisLine.borderColor = self.axisLineColor.CGColor;
    [self.layer addSublayer:xAxisLine];
    
    //y轴
    CALayer *yAxisLine = [CALayer layer];
    yAxisLine.frame = CGRectMake(self.paddingInset.left,
                                 self.paddingInset.top,
                                 0.5f,
                                 rect.size.height-self.paddingInset.top-self.paddingInset.bottom);
    yAxisLine.borderWidth = 0.5f;
    yAxisLine.borderColor = self.axisLineColor.CGColor;
    [self.layer addSublayer:yAxisLine];
    
    [self.baseLineLayers addObject:xAxisLine];
    [self.baseLineLayers addObject:yAxisLine];
}

- (void)drawXLabel:(NSInteger)idx text:(NSString *)text {
    CGRect rect = self.bounds;
    CGRect labelFrame = CGRectMake(self.paddingInset.left + self.barSpaceWidth * idx,
                                   rect.size.height-self.paddingInset.bottom + 5,
                                   self.barSpaceWidth,
                                   12);
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = labelFrame;
    textLayer.string = text;
    textLayer.fontSize = 10.f;
    textLayer.foregroundColor = self.xLabelColor.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    [self.layer addSublayer:textLayer];
    
    [self.xLabelLayers addObject:textLayer];
}

- (void)drawBarLayers {
    
    __weak YNBarView *weakSelf = self;
    
    CGFloat maxY = [self maxYFromData:self.yAxisData];
    CGRect rect = self.bounds;
    
    //x data
    if (self.barSpaceWidth == 0) {
        self.barSpaceWidth = (rect.size.width - self.paddingInset.left - self.paddingInset.right) / self.xAxisData.count;
    }
    
    [self.xAxisData enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL *stop) {
        __strong YNBarView *strongSelf = weakSelf;
        CGFloat yValue = [strongSelf.yAxisData[idx] floatValue];
        
        //x text label
        if (!strongSelf.xLabelHidden) {
            [strongSelf drawXLabel:idx text:text];
        }
        
        //bar background layer
        CGRect xBarBgFrame = CGRectMake(strongSelf.paddingInset.left + self.barSpaceWidth * idx + self.barSpaceWidth / 2.f - strongSelf.barWidth / 2.f,
                                        strongSelf.paddingInset.top,
                                        strongSelf.barWidth,
                                        rect.size.height-strongSelf.paddingInset.top-strongSelf.paddingInset.bottom);
        if (!strongSelf.backGroundLayerHidden) {
            CALayer *xBarBgLayer = [CALayer layer];
            xBarBgLayer.frame = xBarBgFrame;
            xBarBgLayer.backgroundColor = strongSelf.barBackGroundColor.CGColor;
            xBarBgLayer.masksToBounds = YES;
            xBarBgLayer.cornerRadius = strongSelf.barCornerRadius;
            [strongSelf.layer addSublayer:xBarBgLayer];
            [self.barBgLayers addObject:xBarBgLayer];
        }
        
        //bar wrap layer
        CALayer *xBarWrapLayer = [CALayer layer];
        xBarWrapLayer.frame = xBarBgFrame;
        xBarWrapLayer.backgroundColor = [UIColor clearColor].CGColor;
        xBarWrapLayer.masksToBounds = YES;
        xBarWrapLayer.cornerRadius = strongSelf.barCornerRadius;
        [strongSelf.layer addSublayer:xBarWrapLayer];
        
        //bar layer
        CGFloat barHeight = [strongSelf dynamicHeight:yValue FromMax:maxY];
        CALayer *xBarLayer = [CALayer layer];
        xBarLayer.anchorPoint = CGPointMake(0, 0);
        xBarLayer.bounds = CGRectMake(0, 0, strongSelf.barWidth, barHeight);
        xBarLayer.position = CGPointMake(0, xBarBgFrame.size.height);
        xBarLayer.backgroundColor = strongSelf.barForgroundColor.CGColor;
        xBarLayer.cornerRadius = strongSelf.barCornerRadius;
        [xBarWrapLayer addSublayer:xBarLayer];
        
        [self.barLayers addObject:xBarWrapLayer];

        if (strongSelf.showBarAnimate) {
            CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"position"];
            ani.toValue = [NSValue valueWithCGPoint:CGPointMake(0, xBarBgFrame.size.height - barHeight)];
            ani.duration = 2.f;
            ani.removedOnCompletion = NO;
            ani.fillMode = kCAFillModeForwards;
            ani.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
            [xBarLayer addAnimation:ani forKey:nil];
        }
        
    }];
    
}

@end
