//
//  QTModuleManager.m
//  QTEventBus
//
//  Created by Leo on 2018/7/26.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTAppEventManager.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <mach-o/ldsyms.h>
#import <mach-o/getsect.h>
#import "QTAppEvents.h"

#ifndef __LP64__
#define section_ section
#define mach_header_ mach_header
#else
#define section_ section_64
#define mach_header_ mach_header_64
#endif

@interface _QTAppEventObserverMetaData: NSObject

@property (assign, nonatomic) NSInteger priority;
@property (nonatomic) Class<QTAppEventObserver> cls;

@end

@implementation _QTAppEventObserverMetaData

@end

static NSArray<_QTAppEventObserverMetaData *> * observers_in_dyld(const struct mach_header * mhp){
    NSMutableArray<_QTAppEventObserverMetaData *> * result = [[NSMutableArray alloc] init];
    const struct mach_header_* header  = (void*)mhp;
    unsigned long size = 0;
    uintptr_t *data = (uintptr_t *)getsectiondata(header, "__DATA", "__QTEventBus",&size);
    if (data && size > 0) {
        unsigned long count = size / sizeof(struct QTAppObserverInfo);
        struct QTAppObserverInfo *items = (struct QTAppObserverInfo*)data;
        for (int index = 0; index < count; index ++) {
            NSString * classStr = [NSString stringWithUTF8String:items[index].className];
            NSInteger priority = items[index].priority;
            if (!classStr) { continue; }
            _QTAppEventObserverMetaData * metaData = [[_QTAppEventObserverMetaData alloc] init];
            metaData.priority = priority;
            metaData.cls = NSClassFromString(classStr);
            [result addObject:metaData];
        }
    }
    return [result copy];
}

static void dyld_callback(const struct mach_header * mhp, intptr_t slide)
{
    NSArray<_QTAppEventObserverMetaData *> * metadataArray = observers_in_dyld(mhp);
    [metadataArray enumerateObjectsUsingBlock:^(_QTAppEventObserverMetaData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[QTAppEventManager shared] registerAppEventObserver:obj.cls priority:obj.priority];
    }];
}

__attribute__((constructor))
void registerDyldCallback() {
    _dyld_register_func_for_add_image(dyld_callback);
}

@interface QTAppEventManager()

@property (strong, nonatomic) NSMutableArray<_QTAppEventObserverMetaData *> * observers;
@property (assign, nonatomic) BOOL isSorted;

@end

@implementation QTAppEventManager

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    static QTAppEventManager * _instance;
    dispatch_once(&onceToken, ^{
        _instance = [[QTAppEventManager alloc] initPrivate];
    });
    return _instance;
}

- (instancetype)initPrivate{
    if (self = [super init]) {
        _observers = [[NSMutableArray alloc] init];
        _isSorted = NO;
    }
    return self;
}

- (void)registerAppEventObserver:(Class<QTAppEventObserver>)module priority:(long)priority{
    if(!module) return;
    NSAssert([module conformsToProtocol:@protocol(QTAppEventObserver)], @"class must confroms to protocol QTAppEventObserver");
    _QTAppEventObserverMetaData * metaData = [[_QTAppEventObserverMetaData alloc] init];
    metaData.cls = module;
    metaData.priority = priority;
    [self.observers addObject:metaData];
    self.isSorted = NO;
}

- (void)removeAppEventObserver:(Class<QTAppEventObserver>)module{
    if(!module) return;
    NSAssert([module conformsToProtocol:@protocol(QTAppEventObserver)], @"class must confroms to protocol QTAppEventObserver");
    NSMutableArray * result = [NSMutableArray new];
    for (_QTAppEventObserverMetaData * metaData in self.observers) {
        if (metaData.cls == module) {
            continue;
        }
        [result addObject:metaData];
    }
    self.observers = result;
}

- (void)enumerateModulesUsingBlock:(void (^)(__unsafe_unretained Class<QTAppEventObserver>))block{
    if(!block) return;
    if (!self.isSorted) {
        [self.observers sortUsingComparator:^NSComparisonResult(_QTAppEventObserverMetaData *  _Nonnull obj1,
                                                                _QTAppEventObserverMetaData * _Nonnull obj2) {
            return obj1.priority > obj2.priority;
        }];
        self.isSorted = YES;
    }
    [self.observers enumerateObjectsUsingBlock:^(_QTAppEventObserverMetaData * _Nonnull obj,
                                                 NSUInteger idx,
                                                 BOOL * _Nonnull stop) {
        block(obj.cls);

    }];
}

@end
