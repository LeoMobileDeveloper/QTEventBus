//
//  NSObject+QTEventBus_Private.m
//  Demo
//
//  Created by Leo on 2018/11/18.
//  Copyright © 2018 Leo Huang. All rights reserved.
//

#import "NSObject+QTEventBus_Private.h"
#import <objc/runtime.h>

static const char event_bus_disposeContext;

@implementation NSObject (QTEventBus_Private)

- (QTDisposeBag *)eb_disposeBag{
    QTDisposeBag * bag = objc_getAssociatedObject(self, &event_bus_disposeContext);
    if (!bag) {
        bag = [[QTDisposeBag alloc] init];
        objc_setAssociatedObject(self, &event_bus_disposeContext, bag, OBJC_ASSOCIATION_RETAIN);
    }
    return bag;
}

@end
