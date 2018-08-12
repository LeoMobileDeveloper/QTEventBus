//
//  QTModuleManager.h
//  QTEventBus
//
//  Created by Leo on 2018/7/26.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTAppModule.h"

/// 结构体，用于编译期注册
struct QTAppModuleInfo{
    char * className;
    long priority;
};

#define QTAppEventPriorityHigh LONG_MAX
#define QTAppEventPriorityDefault 0
#define QTAppEventPriorityLow LONG_MIN


/// 注册一个应用生命周期事件监听者
#define QTAppModuleRegister(_class_,_priority_)\
__attribute__((used)) static struct QTAppModuleInfo QTAppModule##_class_ \
__attribute__ ((used, section ("__DATA,__QTEventBus"))) =\
{\
    .className = #_class_,\
    .priority = _priority_,\
};

/// 非线程安全，需要在主线程调用
@interface QTAppModuleManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// 单例
+ (instancetype)shared;

/// 迭代
- (void)enumerateModulesUsingBlock:(void(^)(Class<QTAppModule> module))block;

/// 注册
- (void)registerAppModule:(Class<QTAppModule>)module priority:(long)priority;

/// 删除注册
- (void)removeAppModule:(Class<QTAppModule>)module;

@end
