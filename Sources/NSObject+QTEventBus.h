//
//  NSObject+QTEventBus.h
//  QTEventBus
//
//  Created by Leo on 2018/6/1.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTDisposeBag.h"
#import "QTEventTypes.h"

@class QTEventBus;
@class QTAppEvent;
@class QTJsonEvent;
@interface NSObject (QTEventBus)

/**
 在EventBus单例shared上监听指定类型的事件，并且跟随self一起取消监听
 */
- (QTEventSubscriberMaker *)subscribe:(Class)eventClass;

/**
 在bus上监听指定类型的事件，并且跟随self一起取消监听
 */
- (QTEventSubscriberMaker *)subscribe:(Class)eventClass on:(QTEventBus *)bus;

/**
 释放池
 */
@property (strong, nonatomic, readonly) QTDisposeBag * eb_disposeBag;;

@end

@interface NSObject(EventBus_JSON)

/**
 监听一个JSONEvent，并且self释放的时候自动取消订阅
 */
- (QTEventSubscriberMaker<QTJsonEvent *> *)subscribeJSON:(NSString *)name;

@end

@interface NSObject(EventBus_Notification)

/**
 监听通知
 */
- (QTEventSubscriberMaker<NSNotification *> *)subscribeNotification:(NSString *)name;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppDidBecomeActive;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppDidEnterBackground;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppDidFinishLaunching;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppDidReceiveMemoryWarning;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeUserDidTakeScreenshot;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppWillEnterForground;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppWillResignActive;

- (QTEventSubscriberMaker<NSNotification *> *)subscribeAppWillTerminate;

@end
