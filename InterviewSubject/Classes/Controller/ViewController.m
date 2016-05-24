//
//  ViewController.m
//  InterviewSubject
//
//  Created by apple on 16/5/23.
//  Copyright © 2016年 QSP. All rights reserved.
//

/**
 1、	当前屏幕默认展示20天的收盘价；
 
 2、	在纵轴上标出当前所画区域的最高价和最低价；
 
 3、	可以左右滑动查看更多的数据；
 
 4、	可以放大至屏幕上显示10天的收盘价；
 
 5、	长按可以在离触点最近的价格点上出现相交于此点的两根线段（十字线），并可跟随手指移动，同时两根线段与横轴纵轴的相交处可以标注出对应的日期和价格。
 */
#import "ViewController.h"
#import "PriceData.h"
#import "PricesView.h"

#define Screen_Frame                    [UIScreen mainScreen].bounds
#define Screen_Width                    Screen_Frame.size.width
#define Screen_Height                   Screen_Frame.size.height

@interface ViewController ()

@property (strong,nonatomic) PriceData *priceData;
@property (weak,nonatomic) PricesView *pricesView;

@end

@implementation ViewController

#pragma mark - 属性方法
- (PriceData *)priceData
{
    if (_priceData == nil) {
        _priceData = [[PriceData alloc] init];
    }
    
    return _priceData;
}

#pragma mark - 控制器周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self settingUi];
}

#pragma mark - 触摸点击方法
- (void)pinchAction:(UIPinchGestureRecognizer *)sender
{
    if (sender.scale > 1.0 && self.pricesView.showCount != 10) {
        self.pricesView.showCount = 10;
    }
    if (sender.scale < 1.0 && self.pricesView.showCount != 20) {
        self.pricesView.showCount = 20;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        sender.scale = 1.0;
    }
}

#pragma mark - 自定义方法
- (void)settingUi
{
    self.view.backgroundColor = [UIColor blackColor];
    
    PricesView *pView = [[PricesView alloc] init];
    pView.frame = CGRectMake(0, (Screen_Height - Screen_Width)/2, Screen_Width, Screen_Width);
    pView.backgroundColor = [UIColor whiteColor];
    pView.priceData = self.priceData;
    [self.view addSubview:pView];
    self.pricesView = pView;
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self.pricesView addGestureRecognizer:pinch];
}

@end
