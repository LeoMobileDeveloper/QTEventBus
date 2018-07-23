//
//  QTMockIdEvent.m
//  QTEventBusTests
//
//  Created by Leo on 2018/2/24.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTMockIdEvent.h"

@interface QTMockIdEvent()

@property(copy, nonatomic) NSString * domain;

@property (assign,nonatomic,readwrite) NSInteger value;

@end

@implementation QTMockIdEvent

+ (instancetype)eventWithValue:(NSInteger)value domain:(NSString *)domain{
    QTMockIdEvent * event = [[QTMockIdEvent alloc] init];
    event.value = value;
    event.domain = domain;
    return event;
}

- (NSString *)eventSubType{
    return self.domain;
}

@end
