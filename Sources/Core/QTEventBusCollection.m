//
//  QTEventBusCollection.m
//  QTRadio
//
//  Created by Leo on 2018/2/7.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTEventBusCollection.h"
#include <pthread.h>

@class _QTEventBusLinkNode;
/**
 链表节点
 */
@interface _QTEventBusLinkNode: NSObject

@property (weak, nonatomic) _QTEventBusLinkNode * previous;

@property (weak, nonatomic) _QTEventBusLinkNode * next;

@property (strong, nonatomic) id value;

@property (copy, nonatomic) NSString * uniqueId;

@end

@implementation _QTEventBusLinkNode

- (instancetype)initWithValue:(id)value uniqueId:(NSString *)uniqueId{
    if (self = [super init]) {
        _value = value;
        _uniqueId = uniqueId;
    }
    return self;
}

@end

/**
 双向链表,非线程安全,使用方式确保了不会有环
 */
@interface _QTEventBusLinkList: NSObject

@property (assign, nonatomic, readonly) BOOL isEmpty;

@property (strong, nonatomic) _QTEventBusLinkNode * head;

@property (strong, nonatomic) _QTEventBusLinkNode * tail;

@property (strong, nonatomic) NSMutableDictionary * registeredNodeTable;

@end

@implementation _QTEventBusLinkList

- (instancetype)initWithNode:(_QTEventBusLinkNode *)node{
    if (self = [super init]) {
        _head = node;
        _tail = node;
        _registeredNodeTable = [NSMutableDictionary new];
        [_registeredNodeTable setObject:node forKey:node.uniqueId];
    }
    return self;
}

- (BOOL)isEmpty{
    return _head == nil;
}

/**
 删除一个节点
 */
- (void)removeNodeForId:(NSString *)uniqueId{
    //不存在
    if (![_registeredNodeTable objectForKey:uniqueId]) {
        return;
    }
    _QTEventBusLinkNode * node = [_registeredNodeTable objectForKey:uniqueId];
    if (node == _head) {
        _head = _head.next;
    }
    if (node == _tail) {
        _tail = _tail.previous;
    }
    _QTEventBusLinkNode * previousNode = node.previous;
    _QTEventBusLinkNode * nextNode = node.next;
    node.next = nil;
    node.previous = nil;
    previousNode.next = nextNode;
    nextNode.previous = previousNode;
    [_registeredNodeTable removeObjectForKey:uniqueId];
}

- (void)appendNode:(_QTEventBusLinkNode *)node{
    if (_head == nil) {
        _head = node;
        _tail = node;
        return;
    }
    _QTEventBusLinkNode * oldNode = [_registeredNodeTable objectForKey:node.uniqueId];
    if (oldNode) {
        [self replaceNode:oldNode withNode:node];
        return;
    }
    _tail.next = node;
    node.previous = _tail;
    _tail = node;
    [_registeredNodeTable setObject:node forKey:node.uniqueId];
}

- (void)replaceNode:(_QTEventBusLinkNode *)old withNode:(_QTEventBusLinkNode *)update{
    update.next = old.next;
    update.previous = old.previous;
    old.previous.next = update;
    old.next.previous = update;
    if ([[old uniqueId] isEqualToString:_head.uniqueId]) {
        _head = update;
    }
    if ([old.uniqueId isEqualToString:_tail.uniqueId]) {
        _tail = update;
    }
    [_registeredNodeTable setObject:update forKey:update.uniqueId];
}

- (NSArray *)toArray{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    _QTEventBusLinkNode * pointer = _head;
    while (pointer != nil) {
        if (pointer.value) {
            [array addObject:pointer.value];
        }
        pointer = pointer.next;
    }
    return [[NSArray alloc] initWithArray:array];
}

@end


@interface QTEventBusCollection(){
    pthread_mutex_t  _accessLock;
}

@property (strong, nonatomic) NSMutableDictionary<NSString *,_QTEventBusLinkList *> * linkListTable;//记录key->链表的头

@end


@implementation QTEventBusCollection

- (instancetype)init{
    if (self = [super init]) {
        _linkListTable = [[NSMutableDictionary alloc] init];
        pthread_mutex_init(&_accessLock, NULL);
    }
    return self;
}

- (void)lockAndDo:(void(^)(void))block{
    @try{
        pthread_mutex_lock(&_accessLock);
        block();
    }@finally{
        pthread_mutex_unlock(&_accessLock);
    }
}

- (id)lockAndFetch:(id(^)(void))block{
    id result;
    @try{
        pthread_mutex_lock(&_accessLock);
        result = block();
    }@finally{
        pthread_mutex_unlock(&_accessLock);
    }
    return result;
}

- (void)addObject:(id<QTEventBusContainerValue>)object forKey:(NSString *)key{
    NSString * nodeUniqueKey = [object valueUniqueId];
    [self lockAndDo:^{
        _QTEventBusLinkList * linkList = [self.linkListTable objectForKey:key];
        _QTEventBusLinkNode * updateNode = [[_QTEventBusLinkNode alloc] initWithValue:object
                                                                             uniqueId:nodeUniqueKey];
        if (!linkList) {
            linkList = [[_QTEventBusLinkList alloc] initWithNode:updateNode];
            [self.linkListTable setObject:linkList forKey:key];
        }else{
            [linkList appendNode:updateNode];
        }
    }];
}

- (BOOL)removeUniqueId:(NSString *)uniqueId ofKey:(NSString *)key{
    NSNumber * result = [self lockAndFetch:^id{
        _QTEventBusLinkList * linkList = [self.linkListTable objectForKey:key];
        [linkList removeNodeForId:uniqueId];
        if (linkList.isEmpty) {
            [self.linkListTable removeObjectForKey:key];
        }
        return @(linkList.isEmpty);
    }];
    return result.boolValue;
}

/**
 返回一组值
 */
- (NSArray *)objectsForKey:(NSString *)key{
     NSArray * arrary = [self lockAndFetch:^id{
         _QTEventBusLinkList * linkList = [self.linkListTable objectForKey:key];
         return linkList.toArray;
    }];
    return arrary;
}

@end
