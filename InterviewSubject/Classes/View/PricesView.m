//
//  PricesView.m
//  InterviewSubject
//
//  Created by apple on 16/5/23.
//  Copyright © 2016年 QSP. All rights reserved.
//

#import "PricesView.h"

/**
 *  最基本的间距
 */
#define SPACING                 8.0
/**
 *  绘图区域距离左边的距离
 */
#define Margin_L                SPACING
/**
 *  绘图区域距离上边的距离
 */
#define Margin_T                SPACING
/**
 *  绘图区域距离右边的距离
 */
#define Margin_R                SPACING
/**
 *  绘图区域距离下边的距离
 */
#define Margin_B                Margin_L
/**
 *  自身的宽度
 */
#define Self_Width              self.frame.size.width
/**
 *  自身的高度
 */
#define Self_Height             self.frame.size.height
/**
 *  X轴的长度
 */
#define X_Lenth                 (Self_Width - Margin_L - Margin_R)
/**
 *  Y轴的长度
 */
#define Y_Lenth                 (Self_Height - Margin_T - Margin_B)
/**
 *  原点的坐标
 */
#define Origin_Point            CGPointMake(Margin_L, Self_Height - Margin_B)
/**
 *  最基本的颜色（中灰色）
 */
#define Basic_Color             [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]
/**
 *  游标的间距
 */
#define Cursor_Spacing          (X_Lenth/(float)self.showCount)
/**
 *  游标的高度
 */
#define Cursor_Height           5.0
/**
 *  坐标轴线的宽度
 */
#define Axes_Line_Whith         1
/**
 *  默认显示多少数据
 */
#define Show_Count              20
/**
 *  圆点的半径
 */
#define Point_R                 2
/**
 *  涨日的颜色
 */
#define Increase_Color          [UIColor redColor]
/**
 *  跌日的颜色
 */
#define Drop_Color              [UIColor greenColor]
/**
 *  文字的颜色
 */
#define Text_Color              [UIColor blackColor]
/**
 *  文字的字体
 */
#define Text_Font               [UIFont systemFontOfSize:8]
/**
 *  文字背景颜色
 */
#define Text_Back_Color         [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]
#define Price_Regin_Scale       (8.0/10.0)

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
/**
 *  每天价格所处位置的NSValue值数组
 */
@property (strong, nonatomic) NSArray *pointValues;
/**
 *  十字线交点的NSValue值
 */
@property (strong, nonatomic) NSValue *crossPointValue;
/**
 *  显示的数据数
 */
@property (assign, nonatomic) int showCount;

@end

@implementation PricesView

#pragma mark - 工厂方法
+ (instancetype)pricesView:(PriceData *)priceData
{
    return [[self alloc] initWithPriceData:priceData];
}
- (instancetype)initWithPriceData:(PriceData *)priceData
{
    if (self = [super init]) {
        self.priceData = priceData;
    }
    
    return self;
}

#pragma amrk - 属性方法
- (void)setPriceData:(PriceData *)priceData
{
    //数据是否为空
    if (priceData) {
        _priceData = priceData;
        //数据是否比需要显示的数据量小
        if (priceData.dayPrices.count <= self.showCount) {
            self.currentShowData = priceData.dayPrices;
        }
        else
        {
            //设置当前显示的数据
            self.currentShowData = [NSArray arrayWithArray:[priceData.dayPrices subarrayWithRange:NSMakeRange(priceData.dayPrices.count - self.showCount, self.showCount)]];
            //设置剩余的数据
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
            //不存在最大值或者最大值小于当前值
            if (self.maxDayPrice == nil || [self.maxDayPrice.price floatValue] < [dayPrice.price floatValue]) {
                self.maxDayPrice = dayPrice;
            }
            //不存在最小值或者最小值大于当前值
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
        
        //如果存在当前显示的数据
        if (self.currentShowData) {
            //如果当前需要显示的数据量小于当前数据的量
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
            //如果当前需要显示的数据量大于当前数据的量
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
    if (self.crossPointValue) {
        [self drawCrossLine:context];
    }
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.showCount = Show_Count;
        self.backgroundColor = [UIColor whiteColor];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:pan];
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
        longGesture.minimumPressDuration = 1.0;
        [self addGestureRecognizer:longGesture];
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        [self addGestureRecognizer:pinch];
    }
    
    return self;
}

#pragma mark - 触摸手势方法
/**
 *  拖动手势方法
 */
- (void)panAction:(UIPanGestureRecognizer *)sender
{
    if (self.crossPointValue) {
        NSValue *pointValue = [self searchCrossPoint:[sender locationInView:self]];
        if (pointValue != self.crossPointValue) {
            self.crossPointValue = pointValue;
            [self setNeedsDisplay];
        }
    }
    else
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
}
/**
 *  长按手势方法
 */
- (void)longAction:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (!self.crossPointValue) {
            self.crossPointValue = [self searchCrossPoint:[sender locationInView:self]];
        }
        else
        {
            self.crossPointValue = nil;
        }
        
        [self setNeedsDisplay];
    }
    if (sender.state == UIGestureRecognizerStateChanged) {
        if (self.crossPointValue) {
            NSValue *pointValue = [self searchCrossPoint:[sender locationInView:self]];
            if (pointValue != self.crossPointValue) {
                self.crossPointValue = pointValue;
                [self setNeedsDisplay];
            }
        }
    }
}
/**
 *  捏合手势方法
 */
- (void)pinchAction:(UIPinchGestureRecognizer *)sender
{
    if (sender.scale > 1.0 && self.showCount != 10) {
        self.showCount = 10;
    }
    if (sender.scale < 1.0 && self.showCount != 20) {
        self.showCount = 20;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        sender.scale = 1.0;
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
    
    CGFloat X;
    CGFloat beginY;
    CGFloat endY;
    for (int index = 0; index < self.showCount - 1; index++) {
        X = Origin_Point.x + (index + 1)*Cursor_Spacing;
        beginY = Origin_Point.y - Cursor_Height;
        endY = Origin_Point.y;
        
        CGContextMoveToPoint(context, X, beginY);
        CGContextAddLineToPoint(context, X, endY);
        CGContextStrokePath(context);
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
    CGFloat YAxesRegin = Y_Lenth*Price_Regin_Scale;
    //最低点的Y方向位置
    CGFloat lowY = Self_Height - Margin_B - Y_Lenth*((1 - Price_Regin_Scale)/2);
    //记录上一个点，后面有用
    NSValue *lastPointValue;
    //记录最低点，后面有用
    CGPoint lowPoint;
    //记录最高点，后面有用
    CGPoint heightPoint;
    //记录所有的点，后面有用
    NSMutableArray *pointArr = [NSMutableArray arrayWithCapacity:1];
    
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
        [pointArr addObject:lastPointValue];
    }
    self.pointValues = [NSArray arrayWithArray:pointArr];
    
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
    for (int index = 0; index < pointArr.count; index++) {
        CGPoint point = [pointArr[index] CGPointValue];
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
/**
 *  绘制十字线
 *
 *  @param contex 图形上下文
 */
- (void)drawCrossLine:(CGContextRef)contex
{
    CGContextSaveGState(contex);
    
    CGPoint position = [self.crossPointValue CGPointValue];
    CGContextMoveToPoint(contex, Margin_L, position.y);
    CGContextAddLineToPoint(contex, Margin_L + X_Lenth, position.y);
    CGContextStrokePath(contex);
    
    CGContextMoveToPoint(contex, position.x, Margin_T);
    CGContextAddLineToPoint(contex, position.x, Margin_T + Y_Lenth);
    CGContextStrokePath(contex);
    
    DayPriceModel *dayPrice = self.currentShowData[[self.pointValues indexOfObject:self.crossPointValue]];
    NSDictionary *textAttributes = @{NSFontAttributeName:Text_Font,NSForegroundColorAttributeName:[UIColor whiteColor]};
    CGSize textSize = [dayPrice.price boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:textAttributes context:nil].size;
    CGRect textRect = CGRectMake(Margin_L, position.y - textSize.height/2, textSize.width, textSize.height);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:textRect cornerRadius:2];
    [Text_Back_Color setFill];
    [bezierPath fill];
    [dayPrice.price drawWithRect:textRect options:NSStringDrawingUsesLineFragmentOrigin attributes:textAttributes context:nil];
    
    textSize = [dayPrice.date boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:textAttributes context:nil].size;
    CGFloat X = position.x - textSize.width/2;
    if (X < Margin_L) {
        X = Margin_L;
    }
    if (X > Self_Width - Margin_R - textSize.width) {
        X = Self_Width - Margin_R - textSize.width;
    }
    textRect = CGRectMake(X, Self_Height - Margin_B - textSize.height, textSize.width, textSize.height);
    bezierPath = [UIBezierPath bezierPathWithRoundedRect:textRect cornerRadius:2];
    [Text_Back_Color setFill];
    [bezierPath fill];
    [dayPrice.date drawWithRect:textRect options:NSStringDrawingUsesLineFragmentOrigin attributes:textAttributes context:nil];
    
    CGContextRestoreGState(contex);
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
/**
 *  查找十字线的交点
 *
 *  @return 十字线交点
 */
- (NSValue *)searchCrossPoint:(CGPoint)point
{
    int index = round((point.x - Margin_L)/Cursor_Spacing);
    if (index < 0) {
        index = 0;
    }
    if (index > self.pointValues.count - 1) {
        index = (int)self.pointValues.count - 1;
    }
    
    return self.pointValues[index];
}

@end
