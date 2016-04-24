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
@property (strong, nonatomic) NSMutableArray *tipViews;
@property (assign, nonatomic) CGFloat curMaxHeight;
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
        self.showBaseLine = YES;
        self.animateDuration = 2.f;
        
        self.barLayers = @[].mutableCopy;
        self.barBgLayers = @[].mutableCopy;
        self.baseLineLayers = @[].mutableCopy;
        self.xLabelLayers = @[].mutableCopy;
        self.tipViews = @[].mutableCopy;
        
        self.curMaxHeight = -1;
        self.tag = 99999;
        
    }
    return self;
}

- (void)reloadData {
    [self removeLayers];
    [self drawBaseLine];
    [self drawBarLayers];
}

- (void)setNeedFitBarHeight {
    NSArray *visibleLayers = [self visibleBarLayers];
    NSMutableArray *visibleYValues = [NSMutableArray array];
    [visibleLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        [visibleYValues addObject:layer.name];//save name as yValue
    }];
    CGFloat maxHeight = [self maxYFromData:visibleYValues];
    self.curMaxHeight = maxHeight;
    [self showFitHeightAnimate];

}

- (NSArray*)visibleBarLayers {
    CGSize winSize = [UIScreen mainScreen].applicationFrame.size;
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    CALayer *superLayer = window.layer;
    CGFloat visibleWidth = self.frame.size.width;
    if (self.bounds.size.width > winSize.width) {
        visibleWidth = winSize.width;
    }
    CGRect visibleRect = (CGRect){self.frame.origin, {visibleWidth, CGRectGetHeight(self.frame)}};
    NSPredicate *predictate = [NSPredicate predicateWithBlock:^BOOL(CALayer *barLayer, NSDictionary *bindings) {
        CGPoint visiblePoint = [barLayer.superlayer convertPoint:barLayer.frame.origin toLayer:superLayer];
        return CGRectContainsPoint(visibleRect, visiblePoint);
    }];
    return [self.barLayers filteredArrayUsingPredicate:predictate];
}

- (void)removeLayers {
    for (NSInteger i = self.xLabelLayers.count-1; i >= 0; i--) {
        CALayer *layer = self.xLabelLayers[i];
        [layer removeFromSuperlayer];
    }
    [self.xLabelLayers removeAllObjects];
    
    for (NSInteger i = self.baseLineLayers.count-1; i >= 0; i--) {
        CALayer *layer = self.baseLineLayers[i];
        [layer removeFromSuperlayer];
    }
    [self.baseLineLayers removeAllObjects];
    
    for (NSInteger i = self.barBgLayers.count-1; i >= 0; i--) {
        CALayer *layer = self.barBgLayers[i];
        [layer removeFromSuperlayer];
    }
    [self.barBgLayers removeAllObjects];
    
    for (NSInteger i = self.barLayers.count-1; i >= 0; i--) {
        CALayer *layer = self.barLayers[i];
        [layer removeFromSuperlayer];
    }
    [self.barLayers removeAllObjects];
    
    for (NSInteger i = self.tipViews.count-1; i >= 0; i--) {
        UIView *tipView = self.tipViews[i];
        [tipView removeFromSuperview];
    }
    [self.tipViews removeAllObjects];
    
}

- (UIView *)descriptLabelViewForIndex:(NSInteger)idx {
    if (self.barDelegate
        && [self.barDelegate respondsToSelector:@selector(viewTipsForBarViewYAxisAtIndex:)]) {
        return [self viewWithTag:1000 + idx];
    }
    return nil;
}

- (CGFloat)maxYFromData:(NSArray *)data {
    NSArray *tempArray = [data sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 floatValue] > [obj2 floatValue];
    }];
    return [tempArray.lastObject floatValue];
}

- (CGFloat)dynamicHeight:(CGFloat)height FromMax: (CGFloat)maxHeight {
    CGFloat dynamicHeight = ( height / maxHeight ) * ( self.bounds.size.height - self.paddingInset.top - self.paddingInset.bottom) * .9f;
    if (dynamicHeight > self.bounds.size.height - self.paddingInset.top - self.paddingInset.bottom) {
        dynamicHeight = self.bounds.size.height - self.paddingInset.top - self.paddingInset.bottom;
    }
    return dynamicHeight;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.barDelegate
        || ![self.barDelegate respondsToSelector:@selector(barView:didTapBarAtIndex:)]) {
        return;
    }
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    __weak YNBarView *weakSelf = self;
    [self.barBgLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        __strong YNBarView *strongSelf = weakSelf;
        if (CGRectContainsPoint(layer.frame, touchPoint)) {
            [self.barDelegate barView:strongSelf didTapBarAtIndex:idx];
            *stop = YES;
        }
    }];
}

- (void)drawBaseLine {
    if (!self.showBaseLine) {
        return;
    }
    
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

- (void)drawDescriptionLabel {
    if (self.barDelegate
        && [self.barDelegate respondsToSelector:@selector(viewTipsForBarViewYAxisAtIndex:)]) {
        CGRect rect = self.bounds;
        CGFloat barMaxHeight = rect.size.height - self.paddingInset.top - self.paddingInset.bottom;
        for (NSInteger idx = 0; idx < self.xAxisData.count; idx ++) {
            UIView *view = [self.barDelegate viewTipsForBarViewYAxisAtIndex:idx];
            view.tag = 1000 + idx;
            if ([self viewWithTag:1000 + idx]) {
                [[self viewWithTag:1000 + idx] removeFromSuperview];
            }
            CGFloat yValue = [self.yAxisData[idx] floatValue];
            CGFloat maxY = [self maxYFromData:self.yAxisData];//...
            CGFloat centerX = self.paddingInset.left + self.barSpaceWidth * idx + self.barSpaceWidth / 2.f;
            CGFloat barHeight = [self dynamicHeight:yValue FromMax:maxY];
            CGFloat centerY = barMaxHeight - barHeight - 2;
            view.center = CGPointMake(centerX, centerY);
            [self addSubview:view];
            [self.tipViews addObject:view];
        }
    }
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
        CGRect xBarBgFrame = CGRectMake(strongSelf.paddingInset.left + strongSelf.barSpaceWidth * idx + strongSelf.barSpaceWidth / 2.f - strongSelf.barWidth / 2.f,
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
            [strongSelf.barBgLayers addObject:xBarBgLayer];
        }
        
        //bar wrap layer
        CALayer *xBarWrapLayer = [CALayer layer];
        xBarWrapLayer.frame = xBarBgFrame;
        xBarWrapLayer.backgroundColor = [UIColor clearColor].CGColor;
        xBarWrapLayer.masksToBounds = YES;
        xBarWrapLayer.cornerRadius = strongSelf.barCornerRadius;
        xBarWrapLayer.name = [NSString stringWithFormat:@"%@", @(yValue)];
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
        
        [strongSelf.barLayers addObject:xBarWrapLayer];

        NSTimeInterval duration = strongSelf.animateDuration;
        if (strongSelf.showBarAnimate) {
            CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"position"];
            ani.toValue = [NSValue valueWithCGPoint:CGPointMake(0, xBarBgFrame.size.height - barHeight)];
            ani.duration = duration;
            ani.removedOnCompletion = NO;
            ani.fillMode = kCAFillModeForwards;
            ani.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
            [xBarLayer addAnimation:ani forKey:nil];
            
        } else {
            xBarLayer.position = CGPointMake(0, xBarBgFrame.size.height - barHeight);
        }
        
        //the last one
        if (strongSelf.showBarAnimate && idx == strongSelf.xAxisData.count - 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf drawDescriptionLabel];
            });
        }
        if (!strongSelf.showBarAnimate) {
            [strongSelf drawDescriptionLabel];
        }
    }];
    
}

- (void)showFitHeightAnimate {
    __weak YNBarView *weakSelf = self;
    CGFloat barViewMaxHeight = self.bounds.size.height-self.paddingInset.top-self.paddingInset.bottom;
    
    CGRect rect = self.frame;
    CGFloat barMaxHeight = rect.size.height - weakSelf.paddingInset.top - weakSelf.paddingInset.bottom;
    [self.tipViews enumerateObjectsUsingBlock:^(UIView *tipView, NSUInteger idx, BOOL *stop) {
        CGFloat yValue = [weakSelf.yAxisData[idx] floatValue];
        CGFloat barHeight = [weakSelf dynamicHeight:yValue FromMax:weakSelf.curMaxHeight];
        CGFloat centerY = barMaxHeight - barHeight - 2;
        [UIView animateWithDuration:0.5f animations:^{
            tipView.center = CGPointMake(tipView.center.x, centerY);
        }];
        
    }];
    
    [self.barLayers enumerateObjectsUsingBlock:^(CALayer *wrapLayer, NSUInteger idx, BOOL *stop) {
        CGFloat yValue = [weakSelf.yAxisData[idx] floatValue];
        CGFloat barHeight = [weakSelf dynamicHeight:yValue FromMax:weakSelf.curMaxHeight];
        CALayer *barLayer = wrapLayer.sublayers.firstObject;
        
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"position"];
        ani.toValue = [NSValue valueWithCGPoint:CGPointMake(0, barViewMaxHeight - barHeight)];
        
        CABasicAnimation *ani2 = [CABasicAnimation animationWithKeyPath:@"bounds"];
        ani2.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, weakSelf.barWidth, barHeight)];

        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ani, ani2];
        group.removedOnCompletion = NO;
        group.duration = 0.8f;
        group.fillMode = kCAFillModeForwards;
        [barLayer addAnimation:group forKey:nil];
        
    }];
    
}

@end
