//
//  UserService.m
//  Demo
//
//  Created by Leo on 2018/8/9.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "UserService.h"
#import "QTEventBus+AppModule.h"

QTAppModuleRegister(UserService, QTAppEventPriorityHigh)

@interface UserService()<QTAppModule>

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

+ (id<QTAppModule>)moduleInstance {
    return [UserService shared];
}

- (void)appDidFinishLaunch:(QTAppDidLaunchEvent *)event{
    NSLog(@"UserService: appDidFinishLaunch");
    [[UserService shared] registerEventObserver];
}

- (void)appAllModuleInit:(QTAppAllModuleInitEvent *)event{
    NSLog(@"UserService: All app Module init");
}

@end
