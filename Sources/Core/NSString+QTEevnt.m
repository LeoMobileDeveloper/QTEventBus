//
//  NSString+QTEevnt.m
//  QTEventBus
//
//  Created by Leo on 2018/11/9.
//  Copyright © 2018 Leo Huang. All rights reserved.
//

#import "NSString+QTEevnt.h"

@implementation NSString (QTEevnt)

- (NSString *)eventSubType{
    return [self copy];
}

+ (Class)eventClass{
    return [NSString class];
}

@end
