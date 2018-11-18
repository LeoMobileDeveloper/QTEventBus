//
//  NSObject+QTEventBus.m
//  QTEventBus
//
//  Created by Leo on 2018/6/1.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "NSObject+QTEventBus.h"
#import "QTEventBus.h"
#import <UIKit/UIKit.h>
#import "NSString+QTEevnt.h"
#import "NSObject+QTEventBus_Private.h"

@implementation NSObject (QTEventBus)

- (QTEventSubscriberMaker *)subscribeSharedBus:(Class)eventClass{
    return [QTEventBus shared].on(eventClass).freeWith(self);
}

- (QTEventSubscriberMaker *)subscribeSharedBusOfName:(NSString *)eventName{
    NSParameterAssert(eventName != nil);
    return [QTEventBus shared].on(NSString.class).ofSubType(eventName).freeWith(self);
}

- (QTEventSubscriberMaker *)subscribeName:(NSString *)eventName on:(QTEventBus *)bus{
    NSParameterAssert(eventName != nil);
    return bus.on(NSString.class).ofSubType(eventName).freeWith(self);
}

- (QTEventSubscriberMaker *)subscribe:(Class)eventClass on:(QTEventBus *)bus{
    return bus.on(eventClass).freeWith(self);
}

@end

@implementation NSObject(EventBus_JSON)

- (QTEventSubscriberMaker *)subscribeSharedBusOfJSON:(NSString *)name{
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

#pragma mark - Deprecated

@implementation NSObject(QTEventBus_Deprecated)

- (QTEventSubscriberMaker<NSString *> *)subscribeName:(NSString *)eventName{
    return [self subscribeSharedBusOfName:eventName];
}

- (QTEventSubscriberMaker *)subscribe:(Class)eventClass{
    return [self subscribeSharedBus:eventClass];
}

- (QTEventSubscriberMaker<QTJsonEvent *> *)subscribeJSON:(NSString *)name{
    return [self subscribeSharedBusOfJSON:name];
}

@end
