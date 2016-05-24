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

//+ (instancetype)pricesView:(PriceData *)priceData;
//- (instancetype)initWithPriceData:(PriceData *)priceData;

@end
