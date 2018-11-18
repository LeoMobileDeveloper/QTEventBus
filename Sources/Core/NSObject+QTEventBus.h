//
//  NSObject+QTEventBus.h
//  QTEventBus
//
//  Created by Leo on 2018/6/1.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTEventTypes.h"

@class QTEventBus;
@class QTJsonEvent;
@interface NSObject (QTEventBus)

/**
 在EventBus单例shared上监听指定类型的事件，并且跟随self一起取消监听
 */
- (QTEventSubscriberMaker *)subscribeSharedBus:(Class)eventClass;

/**
 在EventBus单例子监听指定字符串事件
 */
- (QTEventSubscriberMaker<NSString *> *)subscribeSharedBusOfName:(NSString *)eventName;

/**
 在bus上监听指定类型的事件，并且跟随self一起取消监听
 */
- (QTEventSubscriberMaker *)subscribe:(Class)eventClass on:(QTEventBus *)bus;

/**
 在bus上监听指定字符串时间
 */
- (QTEventSubscriberMaker<NSString *> *)subscribeName:(NSString *)eventName on:(QTEventBus *)bus;

@end

@interface NSObject(EventBus_JSON)

/**
 监听一个JSONEvent，并且self释放的时候自动取消订阅
 */
- (QTEventSubscriberMaker<QTJsonEvent *> *)subscribeSharedBusOfJSON:(NSString *)name;

@end

@interface NSObject(EventBus_Notification)

/**
 监听通知
 */
- (QTEventSubscriberMaker<NSNotification *> *)subscribeNotification:(NSString *)name;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppDidBecomeActive;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppDidEnterBackground;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppDidReceiveMemoryWarning;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeUserDidTakeScreenshot;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppWillEnterForground;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppWillResignActive;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppWillTerminate;

@end

@interface NSObject(QTEventBus_Deprecated)

/**
 在EventBus单例子监听指定字符串事件
 */
- (QTEventSubscriberMaker<NSString *> *)subscribeName:(NSString *)eventName DEPRECATED_MSG_ATTRIBUTE("Use subscribeSharedBusOfName: method instead.");

/**
 在EventBus单例shared上监听指定类型的事件，并且跟随self一起取消监听
 */
- (QTEventSubscriberMaker *)subscribe:(Class)eventClass DEPRECATED_MSG_ATTRIBUTE("Use subscribeSharedBus: method instead.");

- (QTEventSubscriberMaker<QTJsonEvent *> *)subscribeJSON:(NSString *)name DEPRECATED_MSG_ATTRIBUTE("Use subscribeSharedBusOfJSON: method instead.");
@end
