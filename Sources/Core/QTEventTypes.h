//
//  QTEventTypes.h
//  QTEventBus
//
//  Created by Leo on 2018/6/1.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QTEvent<NSObject>

@optional


/**
 事件的名称
 
 @note: 有些类在运行时是子类，用这个强制返回父类
 */
+ (Class)eventClass;

/**
 事件的二级类型
 */
- (NSString *)eventSubType;

@end

@protocol QTEventToken<NSObject>

/**
 释放当前的监听
 */
- (void)dispose;

@end

/**
 提供一套DSL监听
 */
@interface QTEventSubscriberMaker<Value> : NSObject

typedef void (^QTEventNextBlock)(Value event) NS_SWIFT_UNAVAILABLE("");

/**
 事件触发的回调
 */
- (id<QTEventToken>)next:(QTEventNextBlock)hander;

/**
 监听的队列，设置了监听队列后，副作用事件的监听会变成异步
 */
- (QTEventSubscriberMaker<Value> *)atQueue:(dispatch_queue_t)queue;

/**
 在对象释放的时候，释放监听
 */
- (QTEventSubscriberMaker<Value> *)freeWith:(id)object;

/**
 二级事件，这个操作符可以多次使用
 
 举个例子：[QTEventBus shared].on(QTJsonEvent.class).ofSubType(@"Login").ofSubType(@"Logout")
 
 表示同时监听QTJsonEvent下面的id为Login和Logout事件
 */
- (QTEventSubscriberMaker<Value> *)ofSubType:(NSString *)subType;


#pragma mark - 点语法扩展

@property (readonly, nonatomic) QTEventSubscriberMaker<Value> *(^atQueue)(dispatch_queue_t);

@property (readonly, nonatomic) QTEventSubscriberMaker<Value> *(^ofSubType)(NSString *);

@property (readonly, nonatomic) QTEventSubscriberMaker<Value> *(^freeWith)(id);

//@property (readonly, nonatomic) id<QTEventToken>(^next)(QTEventNextBlock block);

@end

