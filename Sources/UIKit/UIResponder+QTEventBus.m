//
//  UIResponder+QTEventBus.m
//  QTEventBus
//
//  Created by Leo on 2018/11/18.
//  Copyright © 2018 Leo Huang. All rights reserved.
//

#import "UIResponder+QTEventBus.h"
#import <objc/runtime.h>

const char _QTResponserPrivateBusKey;
const char _QTResponserProviderKey;


@interface UIResponder(QTEventBus_Private)

@property (strong, nonatomic) QTEventBus * qt_privateBus;

@end


@implementation UIResponder (QTEventBus)

- (QTEventBus *)qt_privateBus{
    QTEventBus * bus = objc_getAssociatedObject(self, &_QTResponserPrivateBusKey);
    if (!bus) {
        bus = [[QTEventBus alloc] init];
        objc_setAssociatedObject(self, &_QTResponserPrivateBusKey, bus, OBJC_ASSOCIATION_RETAIN);
    }
    return bus;
}

- (QTEventBus *)eventDispatcher{
    UIResponder * resp = self;
    do {
        if ([resp isDispatcherProvider]) {
            return resp.qt_privateBus;
        }
        resp = resp.nextResponder;
    } while (resp != nil);
    return nil;
}

- (BOOL)isDispatcherProvider{
    NSNumber * value = objc_getAssociatedObject(self, &_QTResponserProviderKey);
    if (value) {
        return value.boolValue;
    }
    if ([self isKindOfClass:[UIViewController class]]) {
        return YES;
    }
    return NO;
}

- (void)setDispatcherProvider:(BOOL)dispatcherProvider{
    objc_setAssociatedObject(self, &_QTResponserProviderKey, @(dispatcherProvider), OBJC_ASSOCIATION_RETAIN);
}

@end
