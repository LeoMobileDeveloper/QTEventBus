//
//  NSObject+QTEventBus.m
//  QTEventBus
//
//  Created by Leo on 2018/6/1.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "NSObject+QTEventBus.h"
#import "QTEventBus.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "NSString+QTEevnt.h"

static const char event_bus_disposeContext;

@implementation NSObject (QTEventBus)

- (QTDisposeBag *)eb_disposeBag{
    QTDisposeBag * bag = objc_getAssociatedObject(self, &event_bus_disposeContext);
    if (!bag) {
        bag = [[QTDisposeBag alloc] init];
        objc_setAssociatedObject(self, &event_bus_disposeContext, bag, OBJC_ASSOCIATION_RETAIN);
    }
    return bag;
}

- (QTEventSubscriberMaker *)subscribeName:(NSString *)eventName{
    NSParameterAssert(eventName != nil);
    return [QTEventBus shared].on(NSString.class).ofSubType(eventName).freeWith(self);
}

- (QTEventSubscriberMaker *)subscribeName:(NSString *)eventName on:(QTEventBus *)bus{
    NSParameterAssert(eventName != nil);
    return bus.on(NSString.class).ofSubType(eventName).freeWith(self);
}

- (QTEventSubscriberMaker *)subscribe:(Class)eventClass{
    return [QTEventBus shared].on(eventClass).freeWith(self);
}

- (QTEventSubscriberMaker *)subscribe:(Class)eventClass on:(QTEventBus *)bus{
    return bus.on(eventClass).freeWith(self);
}

@end


@implementation NSObject(EventBus_JSON)

- (QTEventSubscriberMaker *)subscribeJSON:(NSString *)name{
    return [QTEventBus shared].on(QTJsonEvent.class).freeWith(self).ofSubType(name);
}

@end

@implementation NSObject(EventBus_Notification)
/**
 监听通知
 */
- (QTEventSubscriberMaker<NSNotification *> *)subscribeNotification:(NSString *)name{
    return [QTEventBus shared].on(NSNotification.class).ofSubType(name).freeWith(self);
}

- (QTEventSubscriberMaker *)subscribeAppDidBecomeActive{
    return [self subscribeNotification:UIApplicationDidBecomeActiveNotification];
}

- (QTEventSubscriberMaker *)subscribeAppDidEnterBackground{
    return [self subscribeNotification:UIApplicationDidEnterBackgroundNotification];
}

- (QTEventSubscriberMaker *)subscribeAppDidReceiveMemoryWarning{
    return [self subscribeNotification:UIApplicationDidReceiveMemoryWarningNotification];
}

- (QTEventSubscriberMaker *)subscribeUserDidTakeScreenshot{
    return [self subscribeNotification:UIApplicationUserDidTakeScreenshotNotification];
}

- (QTEventSubscriberMaker *)subscribeAppWillEnterForground{
    return [self subscribeNotification:UIApplicationWillEnterForegroundNotification];
}

- (QTEventSubscriberMaker *)subscribeAppWillResignActive{
    return [self subscribeNotification:UIApplicationWillResignActiveNotification];
}

- (QTEventSubscriberMaker *)subscribeAppWillTerminate{
    return [self subscribeNotification:UIApplicationWillTerminateNotification];
}

@end
