//
//  QTEventBus.m
//  QTRadio
//
//  Created by Leo on 2018/2/7.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTEventBus.h"
#import <os/lock.h>
#import <objc/runtime.h>
#import "NSObject+QTEventBus.h"
#import "QTEventBusCollection.h"
#import "NSNotification+QTEvent.h"
#import "NSObject+QTEventBus_Private.h"

static inline NSString * __generateUniqueKey(Class<QTEvent> cls, NSString * eventType){
    Class targetClass = [cls respondsToSelector:@selector(eventClass)] ? [cls eventClass] : cls;
    if (eventType) {
        return [NSString stringWithFormat:@"%@_of_%@", eventType, NSStringFromClass(targetClass)];
    } else {
        return NSStringFromClass(targetClass);
    }
}

static inline NSString * __generateUniqueId(void) {
    u_int64_t timestamp = (u_int64_t)([[NSDate date] timeIntervalSince1970] * 1000000);
    u_int32_t random = arc4random();
    return [NSString stringWithFormat:@"%llu_%u", timestamp, random];
}

/**
 内存中保存的监听者
 */
@interface QTEventSubscriberMaker()

- (instancetype)initWithEventBus:(QTEventBus *)eventBus
                      eventClass:(Class)eventClass;

@property (strong, nonatomic) Class eventClass;

@property (strong, nonatomic) NSObject * lifeTimeTracker;

@property (assign, nonatomic) dispatch_queue_t queue;

@property (strong, nonatomic) NSMutableArray * eventSubTypes;

@property (strong, nonatomic) QTEventBus * eventBus;

@property (copy, nonatomic) void(^handler)(__kindof NSObject *);

@end


/**
 保存的监听者信息
 */
@interface _QTEventSubscriber: NSObject<QTEventBusContainerValue>

@property (strong, nonatomic) Class eventClass;

@property (copy, nonatomic) void (^handler)(__kindof NSObject *);

@property (assign, nonatomic) dispatch_queue_t queue;

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


@interface QTEventBus(){
    os_unfair_lock_t  _accessLock;
}

@property (copy, nonatomic) NSString * prefix;

@property (strong, nonatomic) QTEventBusCollection * collection;

@property (strong, nonatomic) dispatch_queue_t publishQueue;

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> * notificationTracker;

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
        _notificationTracker = [[NSMutableDictionary alloc] init];
        _accessLock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}

- (void)lockAndDo:(void(^)(void))block{
    os_unfair_lock_lock(_accessLock);
    @try{
        block();
    }@finally{
        os_unfair_lock_unlock(_accessLock);
    }
}

#pragma mark - Normal Event


- (id<QTEventToken>)_createNewSubscriber:(QTEventSubscriberMaker *)maker{
    if (!maker.handler) {
        return nil;
    }
    NSMutableArray * tokens;
    if (maker.eventSubTypes.count == 0) {//一级事件
        _QTEventToken * token = [self _addSubscriberWithMaker:maker eventType:nil];
        return token;
    }
    tokens = [[NSMutableArray alloc] initWithCapacity:maker.eventSubTypes.count];
    for (NSString * eventType in maker.eventSubTypes) {
        _QTEventToken * token = [self _addSubscriberWithMaker:maker eventType:eventType];
        [tokens addObject:token];
    }
    _QTComposeToken * token = [[_QTComposeToken alloc] initWithTokens:tokens];
    return token;
}

- (void)_addNotificationObserverIfNeeded:(NSString *)name{
    if (!name) { return; }
    [self lockAndDo:^{
        NSNumber * count = self.notificationTracker[name];
        if (count && count.integerValue > 0) {
            self.notificationTracker[name] = @(count.integerValue + 1);
            return;
        }
        self.notificationTracker[name] = @(1);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:name object:nil];
    }];
}

- (void)_removeNotificationObserver:(NSString *)name{
    if (!name) { return; }
    [self lockAndDo:^{
        NSNumber * count = self.notificationTracker[name];
        if (count && count.integerValue > 1) {
            self.notificationTracker[name] = @(count.integerValue - 1);
            return;
        }
        [self.notificationTracker removeObjectForKey:name];
        @try{
            [[NSNotificationCenter defaultCenter] removeObserver:self name:name object:nil];
        }@catch(NSException * exception){
        }
    }];
}

- (_QTEventToken *)_addSubscriberWithMaker:(QTEventSubscriberMaker *)maker eventType:(NSString *)eventType{
    __weak typeof(self) weakSelf = self;
    NSString * eventKey = __generateUniqueKey(maker.eventClass, eventType);
    NSString * groupId = [self.prefix stringByAppendingString:eventKey];
    NSString * uniqueId = [groupId stringByAppendingString:__generateUniqueId()];
    _QTEventToken * token = [[_QTEventToken alloc] initWithKey:uniqueId];
    BOOL isNSNotification = (maker.eventClass == [NSNotification class]);
    if (eventType && isNSNotification) {
        [self _addNotificationObserverIfNeeded:eventType];
    }
    token.onDispose = ^(NSString *uniqueId) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        BOOL empty = [strongSelf.collection removeUniqueId:uniqueId ofKey:groupId];
        if (empty && isNSNotification) {
            [strongSelf _removeNotificationObserver:eventType];
        }
    };
    //创建监听者
    _QTEventSubscriber * subscriber = [[_QTEventSubscriber alloc] init];
    subscriber.queue = maker.queue;
    subscriber.handler = maker.handler;
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

- (void)receiveNotification:(NSNotification *)notification{
    [self dispatch:notification];
}

- (void)dispatch:(id<QTEvent>)event{
    if (!event) {
        return;
    }
    NSString * eventSubType = [event respondsToSelector:@selector(eventSubType)] ? [event eventSubType] : nil;
    if (eventSubType) {
        //二级事件
        NSString * key = __generateUniqueKey(event.class, eventSubType);
        [self _publishKey:key event:event];
    }
    //一级事件
    NSString * key = __generateUniqueKey(event.class, nil);
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
        void(^handler)(NSObject *) = subscriber.handler;
        if (!handler) {
            continue;
        }
        if (subscriber.queue) {
            dispatch_async(subscriber.queue, ^{
                handler(event);
            });
        } else {
            handler(event);
        }
    }
}

@end

@implementation QTEventSubscriberMaker

- (NSMutableArray *)eventSubTypes{
    if (!_eventSubTypes) {
        _eventSubTypes = [[NSMutableArray alloc] init];
    }
    return _eventSubTypes;
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

- (id<QTEventToken>)next:(QTEventNextBlock)block{
    return self.next(block);
}

- (QTEventSubscriberMaker *)atQueue:(dispatch_queue_t)queue{
    return self.atQueue(queue);
}

- (QTEventSubscriberMaker *)freeWith:(id)object{
    return self.freeWith(object);
}

- (QTEventSubscriberMaker *)ofSubType:(NSString *)eventType{
    return self.ofSubType(eventType);
}

#pragma mark - 点语法

- (QTEventSubscriberMaker<id> *(^)(dispatch_queue_t))atQueue{
    return ^QTEventSubscriberMaker *(dispatch_queue_t queue){
        self.queue = queue;
        return self;
    };
}

- (QTEventSubscriberMaker<id> *(^)(NSString *))ofSubType{
    return ^QTEventSubscriberMaker *(NSString * eventType){
        if (!eventType) {
            return self;
        }
        @synchronized(self) {
            [self.eventSubTypes addObject:eventType];
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
    return ^id<QTEventToken>(void(^block)(__kindof NSObject * event)){
        self.handler = block;
        return [self.eventBus _createNewSubscriber:self];
    };
}

@end
