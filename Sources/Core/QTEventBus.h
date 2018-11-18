//
//  QTEventBus.h
//  QTRadio
//
//  Created by Leo on 2018/2/7.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTEventTypes.h"
#import "QTJsonEvent.h"
#import "NSNotification+QTEvent.h"
#import "NSObject+QTEventBus.h"
#import "NSString+QTEevnt.h"

//监听全局总线，监听的生命周期和object一样
#define QTSub(_object_,_className_) ((QTEventSubscriberMaker<_className_ *> *)[_object_ subscribeSharedBus:[_className_ class]])
#define QTSubName(_object_,_name_) ([_object_ subscribeSharedBusOfName:_name_])
//监听全局总线，异步在主线程监听
#define QTSubMain(_object_,_className_) ([QTSub(_object_, _className_) atQueue:dispatch_get_main_queue()])
//全局总线监听NSNotification
#define QTSubNoti(_object_,_name_) ((QTEventSubscriberMaker<NSNotification *> *)[_object_ subscribeNotification:_name_])
//全局总线监听QTJsonEvent
#define QTSubJSON(_object_,_name_) ((QTEventSubscriberMaker<QTJsonEvent *> *)[_object_ subscribeSharedBusOfJSON:_name_])

@class QTEventSubscriberMaker;

/**
 事件总线，负责转发事件，
 支持同步/异步派发，同步/异步监听
 */
@interface QTEventBus<EventType> : NSObject

/**
 单例
 */
@property (class,readonly) QTEventBus * shared;

/**
 注册监听事件,点语法
 
 如果需要监听系统的通知，请监听NSNotification这个类，如果要监听通用的事件，请监听QTJsonEvent
 */
@property (readonly, nonatomic) QTEventSubscriberMaker<EventType> *(^on)(Class eventClass);

/**
 注册监听事件
 
 如果需要监听系统的通知，请监听NSNotification这个类，如果要监听通用的事件，请监听QTJsonEvent
 */
- (QTEventSubscriberMaker<EventType> *)on:(Class)eventClass;

/**
 发布Event,等待event执行结束
 */
- (void)dispatch:(id<QTEvent>)event;

/**
 异步到eventbus内部queue上dispath
 */
- (void)dispatchOnBusQueue:(id<QTEvent>)event;

/**
 异步到主线程dispatch
 */
- (void)dispatchOnMain:(id<QTEvent>)event;

@end


