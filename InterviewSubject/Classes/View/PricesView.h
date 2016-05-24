//
//  PricesView.h
//  InterviewSubject
//
//  Created by apple on 16/5/23.
//  Copyright © 2016年 QSP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PriceData.h"

@interface PricesView : UIView

/**
 *  股票日价列表
 */
@property (strong,nonatomic) PriceData *priceData;

/**
 *  类方法获取实例
 *
 *  @param priceData 股票日价列表
 *
 *  @return 该类的实例
 */
+ (instancetype)pricesView:(PriceData *)priceData;
/**
 *  用股票日价列表初始化该实例
 *
 *  @param priceData 股票日价列表
 *
 *  @return 初始化后的实例
 */
- (instancetype)initWithPriceData:(PriceData *)priceData;

@end
