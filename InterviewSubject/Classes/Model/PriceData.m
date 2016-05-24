//
//  PriceData.m
//  InterviewSubject
//
//  Created by apple on 16/5/23.
//  Copyright © 2016年 QSP. All rights reserved.
//

#import "PriceData.h"

@implementation PriceData

#pragma mark - 属性方法
- (NSArray *)dayPrices
{
    if (_dayPrices == nil) {
        NSArray *arr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DataList" ofType:@"plist"]];
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in arr) {
            DayPriceModel *model = [DayPriceModel dayPriceModel:dic];
            [mArr addObject:model];
        }
        
        _dayPrices = [NSArray arrayWithArray:mArr];
    }
    
    return _dayPrices;
}

@end



/**
 *  股票每日数据模型
 */
#import "DayPriceModel.h"

@implementation DayPriceModel

+ (instancetype)dayPriceModel:(NSDictionary *)infoDic
{
    return [[self alloc] initWithInfo:infoDic];
}
- (instancetype)initWithInfo:(NSDictionary *)infoDic
{
    static NSString *lastPrice;
    if (self = [super init]) {
        self.date = infoDic[@"date"];
        self.price = infoDic[@"price"];
        if (lastPrice && [lastPrice floatValue] < [infoDic[@"price"] floatValue]) {
            self.type = DayPriceModelIncrease;
        }
        else if (lastPrice && [lastPrice floatValue] > [infoDic[@"price"] floatValue])
        {
            self.type = DayPriceModelDrop;
        }
        else
        {
            self.type = DayPriceModelDefalt;
        }
        lastPrice = infoDic[@"price"];
    }
    
    return self;
}

@end