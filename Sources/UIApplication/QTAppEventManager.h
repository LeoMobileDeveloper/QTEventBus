//
//  QTModuleManager.h
//  QTEventBus
//
//  Created by Leo on 2018/7/26.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTAppEventObserver.h"

/// 结构体，用于编译期注册
struct QTAppObserverInfo{
    char * className;
    long priority;
};

/// 注册一个应用生命周期事件监听者
#define QTAppEventObserverRegister(_class_,_priority_)\
__attribute__((used)) static struct QTAppObserverInfo QTAppObserver##_class_ \
__attribute__ ((used, section ("__DATA,__QTRouter"))) =\
{\
    .className = "#_class_",\
    .priority = _priority_,\
};

/// 非线程安全
@interface QTAppEventManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// 单例
+ (instancetype)shared;

/// 迭代
- (void)enumerateModulesUsingBlock:(void(^)(Class<QTAppEventObserver> module))block;

/// 注册
- (void)registerAppEventObserver:(Class<QTAppEventObserver>)module priority:(long)priority;

/// 删除注册
- (void)removeAppEventObserver:(Class<QTAppEventObserver>)module;

@end
