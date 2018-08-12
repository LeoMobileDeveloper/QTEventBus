//
//  PayService.m
//  Demo
//
//  Created by Leo on 2018/8/10.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "PayService.h"
#import "QTEventBus+UIApplication.h"

QTAppEventObserverReg(PayService, QTAppEventPriorityDefault)

@interface PayService()<QTAppEventObserver>

@end

@implementation PayService

+ (id<QTAppEventObserver>)observerInstance{
    return [[PayService alloc] init];
}

- (void)appDidFinishLuanch:(QTAppDidLaunchEvent *)event{
    NSLog(@"PayService: appDidFinishLuanch");
}

@end
