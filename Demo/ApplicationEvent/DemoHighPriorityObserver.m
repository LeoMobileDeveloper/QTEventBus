//
//  DemoHighPriorityObserver.m
//  Demo
//
//  Created by Leo on 2018/8/9.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "DemoHighPriorityObserver.h"
#import "QTEventBus+UIApplication.h"

QTAppEventObserverReg(DemoHighPriorityObserver, QTAppEventPriorityHigh)

@interface DemoHighPriorityObserver()<QTAppEventObserver>

@end

@implementation DemoHighPriorityObserver

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    static DemoHighPriorityObserver * _instance;
    dispatch_once(&onceToken, ^{
        _instance = [[DemoHighPriorityObserver alloc] init];
    });
    return _instance;
}

- (void)registerEventObserver{
    [QTSub(self, QTAppLifeCircleEvent) next:^(QTAppLifeCircleEvent *event) {
        NSLog(@"DemoHighPriorityObserver: %@",event.type);
    }];
}

+ (id<QTAppEventObserver>)observerInstance {
    return [DemoHighPriorityObserver shared];
}

- (void)appDidFinishLuanch:(QTAppDidLaunchEvent *)event{
    NSLog(@"DemoHighPriorityObserver: appDidFinishLuanch");
    [[DemoHighPriorityObserver shared] registerEventObserver];
}

@end
