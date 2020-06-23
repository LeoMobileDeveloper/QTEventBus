//
//  PayService.m
//  Demo
//
//  Created by Leo on 2018/8/10.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "PayService.h"
#import "QTEventBus+AppModule.h"

QTAppModuleRegister(PayService, QTAppEventPriorityDefault)

@interface PayService()<QTAppModule>

@end

@implementation PayService

+ (id<QTAppModule>)moduleInstance{
    return [[PayService alloc] init];
}

- (void)appDidFinishLaunch:(QTAppDidLaunchEvent *)event{
    NSLog(@"PayService: appDidFinishLaunch");
}

@end
