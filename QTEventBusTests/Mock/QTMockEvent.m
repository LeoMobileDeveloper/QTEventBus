//
//  QTMockEvent.m
//  QTEventBusTests
//
//  Created by Leo on 2018/2/24.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTMockEvent.h"

@interface QTMockEvent()

@property (assign, nonatomic,readwrite) NSInteger value;

@end


@implementation QTMockEvent

+ (instancetype)eventWithValue:(NSInteger)value{
    QTMockEvent * event = [[QTMockEvent alloc] init];
    event.value = value;
    return event;
}

@end
