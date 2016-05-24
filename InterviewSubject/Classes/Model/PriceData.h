//
//  PriceData.h
//  InterviewSubject
//
//  Created by apple on 16/5/23.
//  Copyright © 2016年 QSP. All rights reserved.
//

/**
 *  股票价格数据模型
 */
#import <Foundation/Foundation.h>

@interface PriceData : NSObject


/**
 *  股票日价列表
 */
@property (strong,nonatomic) NSArray *dayPrices;

@end



/**
 *  股票每日数据模型
 */
typedef NS_ENUM(NSInteger, DayPriceModelType){
    DayPriceModelDefalt,//默认，即没涨没跌
    DayPriceModelDrop,//跌
    DayPriceModelIncrease//涨
};
@interface DayPriceModel : NSObject

/**
 *  日期
 */
@property (copy,nonatomic) NSString *date;
/**
 *  价格
 */
@property (copy,nonatomic) NSString *price;
/**
 *  价格涨跌情况
 */
@property (assign,nonatomic) DayPriceModelType type;

+ (instancetype)dayPriceModel:(NSDictionary *)infoDic;
- (instancetype)initWithInfo:(NSDictionary *)infoDic;

@end