//
//  UserService.m
//  Demo
//
//  Created by Leo on 2018/8/9.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "UserService.h"
#import "QTEventBus+UIApplication.h"

QTAppEventObserverReg(UserService, QTAppEventPriorityHigh)

@interface UserService()<QTAppEventObserver>

@end

@implementation UserService

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    static UserService * _instance;
    dispatch_once(&onceToken, ^{
        _instance = [[UserService alloc] init];
    });
    return _instance;
}

- (void)registerEventObserver{
    [QTSub(self, QTAppLifeCircleEvent) next:^(QTAppLifeCircleEvent *event) {
        NSLog(@"UserService: %@",event.type);
    }];
}

+ (id<QTAppEventObserver>)observerInstance {
    return [UserService shared];
}

- (void)appDidFinishLuanch:(QTAppDidLaunchEvent *)event{
    NSLog(@"UserService: appDidFinishLuanch");
    [[UserService shared] registerEventObserver];
}

- (void)appObserverRegistered:(QTAppObserverRegisteredEvent *)event{
    NSLog(@"UserService: All app Observers registered");
}

@end
