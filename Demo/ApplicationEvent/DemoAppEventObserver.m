//
//  DemoAppEventObserver.m
//  Demo
//
//  Created by Leo on 2018/8/9.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "DemoAppEventObserver.h"
#import "QTEventBus+UIApplication.h"

QTAppEventObserverRegister(DemoAppEventObserver, QTAppEventPriorityHigh)

@interface DemoAppEventObserver()<QTAppEventObserver>

@end

@implementation DemoAppEventObserver

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    static DemoAppEventObserver * _instance;
    dispatch_once(&onceToken, ^{
        _instance = [[DemoAppEventObserver alloc] init];
    });
    return _instance;
}

+ (id<QTAppEventObserver>)observerInstance {
    return [DemoAppEventObserver shared];
}

- (void)appDidFinishLuanch:(QTAppDidLaunchEvent *)event{
    NSLog(@"Did Finish Launch");
}

- (void)appLifeCircleChanged:(QTAppLifeCircleEvent *)event{
    NSLog(@"Life Circle Change: %@", event.type);
}

@end
