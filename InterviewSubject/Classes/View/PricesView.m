//
//  PricesView.m
//  InterviewSubject
//
//  Created by apple on 16/5/23.
//  Copyright © 2016年 QSP. All rights reserved.
//

#import "PricesView.h"

#define SPACING                 8.0
#define Margin_L                SPACING
#define Margin_T                SPACING
#define Margin_R                SPACING
#define Margin_B                Margin_L
#define Self_Width              self.frame.size.width
#define Self_Height             self.frame.size.height
#define X_Lenth                 (Self_Width - Margin_L - Margin_R)
#define Y_Lenth                 (Self_Height - Margin_T - Margin_B)
#define Origin_Point            CGPointMake(Margin_L, Self_Height - Margin_B)
#define Basic_Color             [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]
#define Axes_Line_Whith         1
//#define Show_Count              20
#define Point_R                 2
#define Increase_Color          [UIColor redColor]
#define Drop_Color              [UIColor greenColor]
#define Text_Color              [UIColor blackColor]
#define Text_Font               [UIFont systemFontOfSize:8]

@interface PricesView ()

/**
 *  当前显示的股票日价数据
 */
@property (strong,nonatomic) NSArray *currentShowData;
/**
 *  当前显示的股票日价之前的日价数据
 */
@property (strong,nonatomic) NSMutableArray *frontCurrentData;
/**
 *  当前显示的股票日价之后的日价数据
 */
@property (strong,nonatomic) NSMutableArray *backCurrentData;
/**
 *  价格最高的数据模型
 */
@property (strong,nonatomic) DayPriceModel *maxDayPrice;
/**
 *  价格最低的数据模型
 */
@property (strong,nonatomic) DayPriceModel *minDayPrice;

@end

@implementation PricesView

#pragma amrk - 属性方法
- (void)setPriceData:(PriceData *)priceData
{
    if (priceData) {
        _priceData = priceData;
        if (priceData.dayPrices.count <= self.showCount) {
            self.currentShowData = priceData.dayPrices;
        }
        else
        {
            self.currentShowData = [NSArray arrayWithArray:[priceData.dayPrices subarrayWithRange:NSMakeRange(priceData.dayPrices.count - self.showCount, self.showCount)]];
            self.frontCurrentData = [NSMutableArray arrayWithArray:[priceData.dayPrices subarrayWithRange:NSMakeRange(0, priceData.dayPrices.count - self.showCount)]];
        }
    }
}
- (void)setCurrentShowData:(NSArray *)currentShowData
{
    if (currentShowData && currentShowData.count > 0) {
        _currentShowData = currentShowData;
        self.maxDayPrice = nil;
        self.minDayPrice = nil;
        for (DayPriceModel *dayPrice in currentShowData) {
            if (self.maxDayPrice == nil || [self.maxDayPrice.price floatValue] < [dayPrice.price floatValue]) {
                self.maxDayPrice = dayPrice;
            }
            else if (self.minDayPrice == nil || [self.minDayPrice.price floatValue] > [dayPrice.price floatValue])
            {
                self.minDayPrice = dayPrice;
            }
        }
        
        [self setNeedsDisplay];
    }
}
- (NSMutableArray *)frontCurrentData
{
    if (_frontCurrentData == nil) {
        _frontCurrentData = [NSMutableArray arrayWithCapacity:1];
    }
    
    return _frontCurrentData;
}
- (NSMutableArray *)backCurrentData
{
    if (_backCurrentData == nil) {
        _backCurrentData = [NSMutableArray arrayWithCapacity:1];
    }
    
    return _backCurrentData;
}
- (void)setShowCount:(int)showCount
{
    if (showCount > 0 && showCount != _showCount) {
        _showCount = showCount;
        
        if (self.currentShowData) {
            if (showCount < self.currentShowData.count) {
                NSInteger differenceCount = self.currentShowData.count - showCount;
                NSArray *changeArr = [self.currentShowData subarrayWithRange:NSMakeRange(self.currentShowData.count - differenceCount, differenceCount)];
                NSMutableArray *mChangeArr = [NSMutableArray arrayWithArray:changeArr];
                [mChangeArr addObjectsFromArray:self.backCurrentData];
                self.backCurrentData = mChangeArr;
                NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.currentShowData];
                [mArr removeObjectsInArray:changeArr];
                self.currentShowData = [NSArray arrayWithArray:mArr];
            }
            else if (showCount > self.currentShowData.count)
            {
                NSInteger differenceCount = showCount - self.currentShowData.count;
                if (self.backCurrentData.count >= differenceCount) {
                    NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.currentShowData];
                    NSArray *changeArr = [self.backCurrentData subarrayWithRange:NSMakeRange(0, differenceCount)];
                    [mArr addObjectsFromArray:changeArr];
                    self.currentShowData = [NSArray arrayWithArray:mArr];
                    [self.backCurrentData removeObjectsInArray:changeArr];
                }
                else
                {
                    NSInteger backDifferenceCount = self.backCurrentData.count;
                    if (backDifferenceCount > 0) {
                        NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.currentShowData];
                        [mArr addObjectsFromArray:self.backCurrentData];
                        self.currentShowData = [NSArray arrayWithArray:mArr];
                        [self.backCurrentData removeAllObjects];
                    }
                    
                    NSInteger frontDifferenceCount = differenceCount - backDifferenceCount;
                    frontDifferenceCount = frontDifferenceCount <= self.frontCurrentData.count ? frontDifferenceCount : self.frontCurrentData.count;
                    if (frontDifferenceCount > 0) {
                        NSArray *changeArr = [self.frontCurrentData subarrayWithRange:NSMakeRange(self.frontCurrentData.count - frontDifferenceCount, frontDifferenceCount)];
                        NSMutableArray *mArr = [NSMutableArray arrayWithArray:changeArr];
                        [mArr addObjectsFromArray:self.currentShowData];
                        self.currentShowData = [NSArray arrayWithArray:mArr];
                        [self.frontCurrentData removeObjectsInArray:changeArr];
                    }
                }
            }
            else{}
        }
    }
}

#pragma mark - 系统方法
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [Basic_Color setStroke];
    CGContextSaveGState(context);
    
    [self drawAxesX:context];
    [self drawAxesY:context];
    [self drawOriginPoint:context];
    [self drawDayPrices:context];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.showCount = 20;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:pan];
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
        [self addGestureRecognizer:longGesture];
    }
    
    return self;
}

#pragma mark - 触摸手势方法
- (void)panAction:(UIPanGestureRecognizer *)sender
{
    CGFloat margin = Self_Height/(float)self.showCount;
    CGPoint point = [sender translationInView:self];
    if (sender.state == UIGestureRecognizerStateBegan) {//开始拖动
        if (point.x > 0) {
            [self dragChangeArrData:YES];
        }
        else
        {
            [self dragChangeArrData:NO];
        }
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {//正在拖动
        if (point.x > margin) {
            [self dragChangeArrData:YES];
            [sender setTranslation:CGPointZero inView:self];
        }
        else if (point.x < -margin)
        {
            [self dragChangeArrData:NO];
            [sender setTranslation:CGPointZero inView:self];
        }
    }
}
- (void)longAction:(UILongPressGestureRecognizer *)sender
{
    
}
/**
 *  拖曳改变数组中的数据
 *
 *  @param isRingt 是否往右拖曳
 */
- (void)dragChangeArrData:(BOOL)isRingt
{
    if (isRingt) {//往右边拖
        if (self.frontCurrentData && self.frontCurrentData.count > 0) {//如果前边有数据
            NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.currentShowData];
            [self.backCurrentData insertObject:[self.currentShowData lastObject] atIndex:0];
            [mArr removeLastObject];
            [mArr insertObject:[self.frontCurrentData lastObject] atIndex:0];
            [self.frontCurrentData removeLastObject];
            self.currentShowData = [NSArray arrayWithArray:mArr];
        }
    }
    else//往左边拖
    {
        if (self.backCurrentData && self.backCurrentData.count > 0) {//如果后边有数据
            NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.currentShowData];
            [self.frontCurrentData addObject:[self.currentShowData firstObject]];
            [mArr removeObjectAtIndex:0];
            [mArr addObject:[self.backCurrentData firstObject]];
            [self.backCurrentData removeObjectAtIndex:0];
            self.currentShowData = [NSArray arrayWithArray:mArr];
        }
    }
}

#pragma mark - 自定义方法
/**
 *  绘制X轴
 *
 *  @param context 图形上下文
 */
- (void)drawAxesX:(CGContextRef)context
{
    CGContextMoveToPoint(context, Origin_Point.x, Origin_Point.y);
    CGContextSetLineWidth(context, Axes_Line_Whith);
    
    CGPoint endPoint = CGPointMake(Self_Width - Margin_R, Self_Height - Margin_B);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    NSString *specialStr = @"➤";
    UIFont *specialFont = Text_Font;
    NSDictionary *attributes = @{NSFontAttributeName:specialFont,NSForegroundColorAttributeName:Basic_Color};
    CGSize specialSize = [specialStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    [specialStr drawWithRect:CGRectMake(endPoint.x - specialSize.width/2, endPoint.y - specialSize.height/2, specialSize.width, specialSize.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    CGFloat spacing = X_Lenth/(float)self.showCount;
    CGFloat cursorH = 5.0;
    CGFloat X;
    CGFloat beginY;
    CGFloat endY;
    for (int index = 0; index < self.showCount - 1; index++) {
        X = Origin_Point.x + (index + 1)*spacing;
        beginY = Origin_Point.y - cursorH;
        endY = Origin_Point.y;
        
        CGContextMoveToPoint(context, X, beginY);
        CGContextAddLineToPoint(context, X, endY);
        CGContextStrokePath(context);
        
//        if (self.currentShowData.count >= index) {
//            DayPriceModel *dayPrice = self.currentShowData[index];
//            [dayPrice.date drawInRect:CGRectMake(X - spacing/2, endY, spacing, Margin_B) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8],NSForegroundColorAttributeName:Basic_Color}];
//        }
    }
}
/**
 *  绘制Y轴
 *
 *  @param context 图形上下文
 */
- (void)drawAxesY:(CGContextRef)context
{
    CGContextMoveToPoint(context, Origin_Point.x, Origin_Point.y);
    CGContextAddLineToPoint(context, Origin_Point.x + 4, Origin_Point.y - 4);
    CGContextAddLineToPoint(context, Origin_Point.x, Origin_Point.y - 4);
    CGContextStrokePath(context);
    CGContextMoveToPoint(context, Origin_Point.x, Origin_Point.y - 4);
    CGPoint endPoint = CGPointMake(Margin_L, Margin_T);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    
    CGContextSaveGState(context);
    CGContextRotateCTM(context, -M_PI_2);
    CGContextTranslateCTM(context, -Self_Width, 0);
    
    NSString *specialStr = @"➤";
    UIFont *specialFont = Text_Font;
    NSDictionary *attributes = @{NSFontAttributeName:specialFont,NSForegroundColorAttributeName:Basic_Color};
    CGSize specialSize = [specialStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    [specialStr drawWithRect:CGRectMake(Self_Width - Margin_R - specialSize.width/2, Margin_L - specialSize.height/2, specialSize.width, specialSize.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    CGContextRestoreGState(context);
}

/**
 *  绘制原点
 *
 *  @param context 图形上下文
 */
- (void)drawOriginPoint:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, CGRectMake(Origin_Point.x - Point_R, Origin_Point.y - Point_R, 2*Point_R, 2*Point_R));
    [[UIColor redColor] setFill];
    CGContextFillPath(context);
    CGContextRestoreGState(context);
}

/**
 *  绘制日价K线
 *
 *  @param context 图形上下文
 */
- (void)drawDayPrices:(CGContextRef)context
{
    CGContextSaveGState(context);
    
    //价格的相差区域
    CGFloat priceRegin = [self.maxDayPrice.price floatValue] - [self.minDayPrice.price floatValue];
    //Y轴的位置相差区域
    CGFloat YAxesRegin = Y_Lenth/10.0*8.0;
    //最低点的Y方向位置
    CGFloat lowY = Self_Height - Margin_B - Y_Lenth/10;
    //记录上一个点，后面有用
    NSValue *lastPointValue;
    //记录最低点，后面有用
    CGPoint lowPoint;
    //记录最高点，后面有用
    CGPoint heightPoint;
    //记录所有的点，后面有用
    NSMutableArray *pointsArr = [NSMutableArray arrayWithCapacity:1];
    
    //绘制线段
    for (int index = 0; index < self.currentShowData.count; index++) {
        DayPriceModel *dayPrice = self.currentShowData[index];
        CGPoint centPoint = CGPointMake(Margin_L + X_Lenth/(float)self.showCount*index, lowY - ([dayPrice.price floatValue] - [self.minDayPrice.price floatValue])*YAxesRegin/priceRegin);
        if (dayPrice == self.maxDayPrice) {
            heightPoint = centPoint;
        }
        else if(dayPrice == self.minDayPrice)
        {
            lowPoint = centPoint;
        }
        switch (dayPrice.type) {
            case DayPriceModelDrop:
            {
                if (lastPointValue) {
                    [Drop_Color setStroke];
                    CGPoint lastPoint = [lastPointValue CGPointValue];
                    CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
                    CGContextAddLineToPoint(context, centPoint.x, centPoint.y);
                    CGContextStrokePath(context);
                }
            }
                break;
            case DayPriceModelIncrease:
            {
                if (lastPointValue) {
                    [Increase_Color setStroke];
                    CGPoint lastPoint = [lastPointValue CGPointValue];
                    CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
                    CGContextAddLineToPoint(context, centPoint.x, centPoint.y);
                    CGContextStrokePath(context);
                }
            }
                break;
                
            default:
            {
                if (lastPointValue)
                {
                    [Increase_Color setStroke];
                    CGPoint lastPoint = [lastPointValue CGPointValue];
                    CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
                    CGContextAddLineToPoint(context, centPoint.x, centPoint.y);
                    CGContextStrokePath(context);
                }
            }
                break;
        }
        lastPointValue = [NSValue valueWithCGPoint:centPoint];
        [pointsArr addObject:lastPointValue];
    }
    
    //回复与保存图形上下文
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    //绘制最低点，和最高点的值与虚线
    CGContextMoveToPoint(context, lowPoint.x, lowPoint.y);
    CGContextAddLineToPoint(context, Margin_L, lowPoint.y);
    /*
     CGContextRef c：图形上下文,
     CGFloat phase：相位,
     const CGFloat *lengths：虚实相间的像素点（c语言的数组）,
     size_t count：lengths数组中元素个数
     */
    double lengths[] = {3.0};
    CGContextSetLineDash(context, 0, lengths, 1);
    CGContextStrokePath(context);
    NSDictionary *attributes = @{NSFontAttributeName:Text_Font,NSForegroundColorAttributeName:Text_Color};
    [self.minDayPrice.price drawAtPoint:CGPointMake(Margin_L, lowPoint.y) withAttributes:attributes];
    
    CGContextMoveToPoint(context, heightPoint.x, heightPoint.y);
    CGContextAddLineToPoint(context, Margin_L, heightPoint.y);
    CGContextStrokePath(context);
    CGSize maxPriceSize = [self.maxDayPrice.price boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    [self.maxDayPrice.price drawWithRect:CGRectMake(Margin_L, heightPoint.y - maxPriceSize.height, maxPriceSize.width, maxPriceSize.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    //回复与保存图形上下文
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    //绘制圆点，为了使圆点绘制在线的上面，把圆点全部放到后面绘制。
    for (int index = 0; index < pointsArr.count; index++) {
        CGPoint point = [pointsArr[index] CGPointValue];
        CGContextAddEllipseInRect(context, CGRectMake(point.x - Point_R, point.y - Point_R, 2*Point_R, 2*Point_R));
        DayPriceModel *dayPrice = self.currentShowData[index];
        switch (dayPrice.type) {
            case DayPriceModelDrop:
                [Drop_Color setFill];
                break;
            case DayPriceModelIncrease:
                [Increase_Color setFill];
                break;
                
            default:
                [Basic_Color setFill];
                break;
        }
        
        CGContextFillPath(context);
    }
    
    CGContextRestoreGState(context);
}

@end
