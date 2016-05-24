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

/**
 *  屏幕的位置大小
 */
#define Screen_Frame                    [UIScreen mainScreen].bounds
/**
 *  屏幕的宽
 */
#define Screen_Width                    Screen_Frame.size.width
/**
 *  屏幕的高
 */
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
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 自定义方法
/**
 *  设置UI
 */
- (void)settingUi
{
    self.view.backgroundColor = [UIColor blackColor];
    
    UILabel *label = [[UILabel alloc] init];
    CGFloat Y = [UIApplication sharedApplication].statusBarFrame.size.height;
    label.frame = CGRectMake(0, Y, Screen_Width, Screen_Height - Y - Screen_Width);
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.text = @"说明：\n    1.拖动手势可以查看左右的数据\n    2.捏合手势可以缩放显示内容\n    3.长按手势可以显示与隐藏十字架，并且显示时十字架跟随手势移动";
    [self.view addSubview:label];
    
    PricesView *pView = [PricesView pricesView:self.priceData];
    pView.frame = CGRectMake(0, Screen_Height - Screen_Width, Screen_Width, Screen_Width);
    [self.view addSubview:pView];
    self.pricesView = pView;
}

@end
