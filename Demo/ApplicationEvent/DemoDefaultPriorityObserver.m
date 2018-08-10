//
//  DemoDefaultPriorityObserver.m
//  Demo
//
//  Created by Leo on 2018/8/10.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "DemoDefaultPriorityObserver.h"
#import "QTEventBus+UIApplication.h"

QTAppEventObserverReg(DemoDefaultPriorityObserver, QTAppEventPriorityDefault)

@interface DemoDefaultPriorityObserver()<QTAppEventObserver>

@end

@implementation DemoDefaultPriorityObserver

+ (id<QTAppEventObserver>)observerInstance{
    return [[DemoDefaultPriorityObserver alloc] init];
}

- (void)appDidFinishLuanch:(QTAppDidLaunchEvent *)event{
    NSLog(@"DemoDefaultPriorityObserver: appDidFinishLuanch");
}

@end
