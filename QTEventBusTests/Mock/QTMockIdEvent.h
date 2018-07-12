//
//  QTMockIdEvent.h
//  QTEventBusTests
//
//  Created by Leo on 2018/2/24.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTEventTypes.h"

@interface QTMockIdEvent : NSObject<QTEvent>

@property (assign, nonatomic,readonly) NSInteger value;

+ (instancetype)eventWithValue:(NSInteger)value domain:(NSString *)domain;

@end
