//
//  QTMockContainerValue.m
//  QTEventBusTests
//
//  Created by Leo on 2018/2/24.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTMockContainerValue.h"

@interface QTMockContainerValue()

@property (copy, nonatomic) NSString * uniqueId;

@end

@implementation QTMockContainerValue

- (instancetype)initWithUniqueId:(NSString *)uniqueId{
    if (self = [super init]) {
        _uniqueId = uniqueId;
    }
    return self;
}

+ (instancetype)mockInstanceWithId:(NSString *)uniqueId{
    return [[QTMockContainerValue alloc] initWithUniqueId:uniqueId];
}

- (NSString *)valueUniqueId{
    return self.uniqueId;
}

@end
