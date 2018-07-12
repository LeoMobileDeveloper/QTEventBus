//
//  QTEventBus.m
//  QTRadio
//
//  Created by Leo on 2018/2/7.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTEventBus.h"
#import <objc/runtime.h>
#import "QTEventBusCollection.h"
#import "NSNotification+QTEvent.h"
#import <pthread.h>
#import "NSObject+QTEventBus.h"

static inline NSString * __generateUnqiueKey(Class class,NSString * eventType){
    if (eventType) {
        return [NSString stringWithFormat:@"%@_of_%@",eventType,NSStringFromClass(class)];
    }else{
        return NSStringFromClass(class);
    }
}

/**
 内存中保存的监听者
 */
@interface QTEventSubscriberMaker()

- (instancetype)initWithEventBus:(QTEventBus *)eventBus
                      eventClass:(Class)eventClass;

@property (strong, nonatomic) Class eventClass;

@property (strong, nonatomic) NSObject * lifeTimeTracker;

@property (strong, nonatomic) dispatch_queue_t queue;

@property (strong, nonatomic) NSMutableArray * eventTypes;

@property (strong, nonatomic) QTEventBus * eventBus;

@property (copy, nonatomic) void(^hander)(__kindof NSObject *);

@end


/**
 保存的监听者信息
 */
@interface _QTEventSubscriber: NSObject<QTEventBusContainerValue>

@property (strong, nonatomic) Class eventClass;

@property (copy, nonatomic) void (^handler)(__kindof NSObject *);

@property (strong, nonatomic) dispatch_queue_t queue;

@property (copy, nonatomic) NSString * uniqueId;

@end

@implementation _QTEventSubscriber

- (NSString *)valueUniqueId{
    return self.uniqueId;
}

@end

/**
 返回可以取消的token
 */
@interface _QTEventToken: NSObject<QTEventToken>

@property (copy, nonatomic) NSString * uniqueId;

@property (copy, nonatomic) void(^onDispose)(NSString * uniqueId);

@property (assign, nonatomic) BOOL isDisposed;

@end

@implementation _QTEventToken

- (instancetype)initWithKey:(NSString *)uniqueId{
    if (self = [super init]) {
        _uniqueId = uniqueId;
        _isDisposed = NO;
    }
    return self;
}

- (void)dispose{
    @synchronized(self){
        if (_isDisposed) {
            return;
        }
        _isDisposed = YES;
    }
    if (self.onDispose) {
        self.onDispose(self.uniqueId);
    }
}
@end

/**
 组合token
 */
@interface _QTComposeToken: NSObject <QTEventToken>

- (instancetype)initWithTokens:(NSArray<_QTEventToken *> *)tokens;

@property (assign, nonatomic) BOOL isDisposed;

@property (strong, nonatomic) NSArray<_QTEventToken *> * tokens;

@end

@implementation _QTComposeToken

- (instancetype)initWithTokens:(NSArray<_QTEventToken *> *)tokens{
    if (self = [super init]) {
        _tokens = tokens;
        _isDisposed = NO;
    }
    return self;
}

- (void)dispose{
    @synchronized(self){
        if (_isDisposed) {
            return;
        }
        _isDisposed = YES;
    }
    for (_QTEventToken * token in self.tokens) {
        [token dispose];
    }
}

@end


@interface QTEventBus()

@property (copy, nonatomic) NSString * prefix;

@property (strong, nonatomic) QTEventBusCollection * collection;

@property (strong, nonatomic) dispatch_queue_t publishQueue;

@end

@implementation QTEventBus

+ (instancetype)shared{
    static QTEventBus * _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[QTEventBus alloc] init];
    });
    return _instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _prefix = @([[NSDate date] timeIntervalSince1970]).stringValue;
        _collection = [[QTEventBusCollection alloc] init];
        _publishQueue = dispatch_queue_create("com.eventbus.publish.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Normal Event

- (id<QTEventToken>)_createNewSubscriber:(QTEventSubscriberMaker *)maker{
    if (!maker.hander) {
        return nil;
    }
    if (maker.eventTypes.count == 0) {//一级事件
        _QTEventToken * token = [self _addSubscriberWithMaker:maker eventType:nil];
        return token;
    }
    NSMutableArray * tokens = [[NSMutableArray alloc] init];
    for (NSString * eventType in maker.eventTypes) {
        _QTEventToken * token = [self _addSubscriberWithMaker:maker eventType:eventType];
        [tokens addObject:token];
    }
    _QTComposeToken * token = [[_QTComposeToken alloc] initWithTokens:tokens];
    return token;
}

- (_QTEventToken *)_addSubscriberWithMaker:(QTEventSubscriberMaker *)maker eventType:(NSString *)eventType{
    __weak typeof(self) weakSelf = self;
    NSString * eventKey = __generateUnqiueKey(maker.eventClass, eventType);
    NSString * groupId = [self.prefix stringByAppendingString:eventKey];
    NSString * uniqueId = [groupId stringByAppendingString:@([NSDate date].timeIntervalSince1970).stringValue];
    _QTEventToken * token = [[_QTEventToken alloc] initWithKey:uniqueId];
    BOOL isCFNotifiction = [maker.eventClass isKindOfClass:[NSNotification class]];
    if (eventType && isCFNotifiction) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:eventType object:nil];
    }
    token.onDispose = ^(NSString *uniqueId) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        BOOL empty = [strongSelf.collection removeUniqueId:uniqueId ofKey:groupId];
        if (empty && isCFNotifiction) {
            @try{
                [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:eventType object:nil];
            }@catch(NSException * exception){
            }
        }
    };
    //创建监听者
    _QTEventSubscriber * subscriber = [[_QTEventSubscriber alloc] init];
    subscriber.queue = maker.queue;
    subscriber.handler = maker.hander;
    subscriber.uniqueId = uniqueId;
    if (maker.lifeTimeTracker) {
        [maker.lifeTimeTracker.eb_disposeBag addToken:token];
    }
    [self.collection addObject:subscriber forKey:groupId];
    return token;
}

- (QTEventSubscriberMaker<id> *(^)(Class eventClass))on{
    return ^QTEventSubscriberMaker *(Class eventClass){
        return [[QTEventSubscriberMaker alloc] initWithEventBus:self
                                                     eventClass:eventClass];
    };
}

- (QTEventSubscriberMaker<id> *)on:(Class)eventClass{
    return [[QTEventSubscriberMaker alloc] initWithEventBus:self eventClass:eventClass];
}

- (void)receiveNotification:(NSNotification *)notificaion{
    [self dispatch:notificaion];
}

- (void)dispatch:(id<QTEvent>)event{
    if (!event) {
        return;
    }
    NSString * eventType = [event respondsToSelector:@selector(eventType)] ? [event eventType] : nil;
    if (eventType) {
        //二级事件
        NSString * key = __generateUnqiueKey(event.class, eventType);
        [self _publishKey:key event:event];
    }
    //一级事件
    NSString * key = __generateUnqiueKey(event.class, nil);
    [self _publishKey:key event:event];
}

- (void)dispatchOnBusQueue:(id<QTEvent>)event{
    dispatch_async(self.publishQueue, ^{
        [self dispatch:event];
    });
}

- (void)dispatchOnMain:(id<QTEvent>)event{
    if ([NSThread isMainThread]) {
        [self dispatch:event];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dispatch:event];
        });
    }
}

- (void)_publishKey:(NSString *)eventKey event:(NSObject *)event{
    NSString * groupId = [self.prefix stringByAppendingString:eventKey];
    NSArray * subscribers = [self.collection objectsForKey:groupId];
    if (!subscribers || subscribers.count == 0) {
        return;
    }
    for (_QTEventSubscriber * subscriber in subscribers) {
        if (subscriber.queue) { //异步分发
            dispatch_async(subscriber.queue, ^{
                if (subscriber.handler) {
                    subscriber.handler(event);
                }
            });
        }else{ //同步分发
            if (subscriber.handler) {
                subscriber.handler(event);
            }
        }

    }
}

@end

@implementation QTEventSubscriberMaker

- (NSMutableArray *)eventTypes{
    if (!_eventTypes) {
        _eventTypes = [[NSMutableArray alloc] init];
    }
    return _eventTypes;
}

- (instancetype)initWithEventBus:(QTEventBus *)eventBus
                      eventClass:(Class)eventClass{
    if (self = [super init]) {
        _eventBus = eventBus;
        _eventClass = eventClass;
        _queue = nil;
    }
    return self;
}

- (id<QTEventToken>)next:(QTEventNextBlock)hander{
    return self.next(hander);
}

- (QTEventSubscriberMaker *)atQueue:(dispatch_queue_t)queue{
    return self.atQueue(queue);
}

- (QTEventSubscriberMaker *)freeWith:(id)object{
    return self.freeWith(object);
}

- (QTEventSubscriberMaker *)ofType:(NSString *)eventType{
    return self.ofType(eventType);
}

#pragma mark - 点语法

- (QTEventSubscriberMaker<id> *(^)(dispatch_queue_t))atQueue{
    return ^QTEventSubscriberMaker *(dispatch_queue_t queue){
        self.queue = queue;
        return self;
    };
}

- (QTEventSubscriberMaker<id> *(^)(NSString *))ofType{
    return ^QTEventSubscriberMaker *(NSString * eventType){
        if (!eventType) {
            return self;
        }
        @synchronized(self) {
            [self.eventTypes addObject:eventType];
        }
        return self;
    };
}

- (QTEventSubscriberMaker<id> *(^)(id))freeWith{
    return ^QTEventSubscriberMaker *(id lifeTimeTracker){
        self.lifeTimeTracker = lifeTimeTracker;
        return self;
    };
}

- (id<QTEventToken>(^)(void(^)(id event)))next{
    return ^id<QTEventToken>(void(^hander)(__kindof NSObject * event)){
        self.hander = hander;
        return [self.eventBus _createNewSubscriber:self];
    };
}

@end


