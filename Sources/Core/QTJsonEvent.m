//
//  QTJsonEvent.m
//  QTEventBus
//
//  Created by Leo on 2018/7/5.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTJsonEvent.h"

@interface QTJsonEvent()

@property (nonatomic, copy) NSString * uniqueId;

@property (nonatomic, strong) id data;


@end

@implementation QTJsonEvent

- (instancetype)initWithId:(NSString *)unqiueId data:(id)data{
    if (self = [super init]) {
        _data = data;
        _uniqueId = unqiueId;
    }
    return self;
}

+ (instancetype)eventWithId:(NSString *)uniqueId jsonArray:(NSArray *)data{
    NSAssert([data isKindOfClass:[NSArray class]], @"Data must be NSArray");
    return [[self alloc] initWithId:uniqueId data:data];
}

+ (instancetype)eventWithId:(NSString *)uniqueId jsonObject:(NSDictionary *)data{
    NSAssert([data isKindOfClass:[NSDictionary class]], @"Data must be NSDictionary");
    return [[self alloc] initWithId:uniqueId data:data];
}

- (NSString *)eventSubType{
    return self.uniqueId;
}

@end
