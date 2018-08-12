//
//  QTModuleManager.m
//  QTEventBus
//
//  Created by Leo on 2018/7/26.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTAppModuleManager.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <mach-o/ldsyms.h>
#import <mach-o/getsect.h>
#import "QTAppEvents.h"


#define QTAssertMain NSAssert([[NSThread currentThread] isMainThread], @"Function must call on main thread");

#ifndef __LP64__
#define section_ section
#define mach_header_ mach_header
#else
#define section_ section_64
#define mach_header_ mach_header_64
#endif

@interface _QTAppModuleMetaData: NSObject

@property (assign, nonatomic) NSInteger priority;
@property (nonatomic) Class<QTAppModule> cls;

@end

@implementation _QTAppModuleMetaData

@end

static NSArray<_QTAppModuleMetaData *> * modules_in_dyld(const struct mach_header * mhp){
    NSMutableArray<_QTAppModuleMetaData *> * result = [[NSMutableArray alloc] init];
    const struct mach_header_* header  = (void*)mhp;
    unsigned long size = 0;
    uintptr_t *data = (uintptr_t *)getsectiondata(header, "__DATA", "__QTEventBus",&size);
    if (data && size > 0) {
        unsigned long count = size / sizeof(struct QTAppModuleInfo);
        struct QTAppModuleInfo *items = (struct QTAppModuleInfo*)data;
        for (int index = 0; index < count; index ++) {
            NSString * classStr = [NSString stringWithUTF8String:items[index].className];
            NSInteger priority = items[index].priority;
            if (!classStr) { continue; }
            _QTAppModuleMetaData * metaData = [[_QTAppModuleMetaData alloc] init];
            metaData.priority = priority;
            metaData.cls = NSClassFromString(classStr);
            [result addObject:metaData];
        }
    }
    return [result copy];
}

static void dyld_callback(const struct mach_header * mhp, intptr_t slide)
{
    NSArray<_QTAppModuleMetaData *> * metadataArray = modules_in_dyld(mhp);
    [metadataArray enumerateObjectsUsingBlock:^(_QTAppModuleMetaData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[QTAppModuleManager shared] registerAppModule:obj.cls priority:obj.priority];
    }];
}

__attribute__((constructor))
void registerDyldCallback() {
    _dyld_register_func_for_add_image(dyld_callback);
}

@interface QTAppModuleManager()

@property (strong, nonatomic) NSMutableArray<_QTAppModuleMetaData *> * modules;
@property (assign, nonatomic) BOOL isSorted;

@end

@implementation QTAppModuleManager

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    static QTAppModuleManager * _instance;
    dispatch_once(&onceToken, ^{
        _instance = [[QTAppModuleManager alloc] initPrivate];
    });
    return _instance;
}

- (instancetype)initPrivate{
    if (self = [super init]) {
        _modules = [[NSMutableArray alloc] init];
        _isSorted = NO;
    }
    return self;
}

- (void)registerAppModule:(Class<QTAppModule>)module priority:(long)priority{
    QTAssertMain;
    if(!module) return;
    NSAssert([module conformsToProtocol:@protocol(QTAppModule)], @"class must confroms to protocol QTAppModule");
    _QTAppModuleMetaData * metaData = [[_QTAppModuleMetaData alloc] init];
    metaData.cls = module;
    metaData.priority = priority;
    [self.modules addObject:metaData];
    self.isSorted = NO;
}

- (void)removeAppModule:(Class<QTAppModule>)module{
    QTAssertMain;
    if(!module) return;
    NSAssert([module conformsToProtocol:@protocol(QTAppModule)], @"class must confroms to protocol QTAppModule");
    NSMutableArray * result = [NSMutableArray new];
    for (_QTAppModuleMetaData * metaData in self.modules) {
        if (metaData.cls == module) {
            continue;
        }
        [result addObject:metaData];
    }
    self.modules = result;
}

- (void)enumerateModulesUsingBlock:(void (^)(__unsafe_unretained Class<QTAppModule>))block{
    QTAssertMain;
    if(!block) return;
    if (!self.isSorted) {
        [self.modules sortUsingComparator:^NSComparisonResult(_QTAppModuleMetaData *  _Nonnull obj1,
                                                                _QTAppModuleMetaData * _Nonnull obj2) {
            return obj1.priority < obj2.priority;
        }];
        self.isSorted = YES;
    }
    [self.modules enumerateObjectsUsingBlock:^(_QTAppModuleMetaData * _Nonnull obj,
                                                 NSUInteger idx,
                                                 BOOL * _Nonnull stop) {
        block(obj.cls);

    }];
}

@end
