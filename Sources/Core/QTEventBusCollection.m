//
//  QTEventBusCollection.m
//  QTRadio
//
//  Created by Leo on 2018/2/7.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTEventBusCollection.h"
#include <os/lock.h>

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
    _QTEventBusLinkNode * node = [_registeredNodeTable objectForKey:uniqueId];
    if (!node) {
        return;
    }
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
    if (previousNode) {
        previousNode.next = nextNode;
    }
    if (nextNode) {
        nextNode.previous = previousNode;
    }
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
    return [array copy];
}

@end


@interface QTEventBusCollection(){
    os_unfair_lock_t  _accessLock;
}

@property (strong, nonatomic) NSMutableDictionary<NSString *,_QTEventBusLinkList *> * linkListTable;

@end


@implementation QTEventBusCollection

- (instancetype)init{
    if (self = [super init]) {
        _linkListTable = [[NSMutableDictionary alloc] init];
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

- (id)lockAndFetch:(id(^)(void))block{
    os_unfair_lock_lock(_accessLock);
    @try{
        return block();
    }@finally{
        os_unfair_lock_unlock(_accessLock);
    }
}

- (void)addObject:(id<QTEventBusContainerValue>)object forKey:(NSString *)key{
    NSString * nodeUniqueKey = [object valueUniqueId];
    [self lockAndDo:^{
        _QTEventBusLinkList * linkList = self.linkListTable[key];
        _QTEventBusLinkNode * updateNode = [[_QTEventBusLinkNode alloc] initWithValue:object
                                                                             uniqueId:nodeUniqueKey];
        if (!linkList) {
            linkList = [[_QTEventBusLinkList alloc] initWithNode:updateNode];
            self.linkListTable[key] = linkList;
        } else {
            [linkList appendNode:updateNode];
        }
    }];
}

- (BOOL)removeUniqueId:(NSString *)uniqueId ofKey:(NSString *)key{
    NSNumber * result = [self lockAndFetch:^id{
        _QTEventBusLinkList * linkList = self.linkListTable[key];
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
     NSArray * array = [self lockAndFetch:^id{
         _QTEventBusLinkList * linkList = self.linkListTable[key];
         return [linkList toArray];
    }];
    return array;
}

@end
