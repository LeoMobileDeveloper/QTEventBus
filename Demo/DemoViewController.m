//
//  DemoViewController.m
//  Demo
//
//  Created by Leo on 2018/7/23.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "DemoViewController.h"
#import "QTEventBus.h"
#import "DemoEvent.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [QTSub(self, DemoEvent) next:^(DemoEvent *event) {
        NSLog(@"%ld",event.count);
    }];
    [QTSubNoti(self, @"name") next:^(NSNotification *event) {
        NSLog(@"%@",@"Receive Notification");
    }];
}


- (IBAction)dispatchNotification:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"name" object:nil];
}
- (IBAction)dispatchEvent:(id)sender {
    static long _count = 1;
    DemoEvent * event = [[DemoEvent alloc] init];
    event.count = _count;
    _count ++;
    [[QTEventBus shared] dispatch:event];
}

- (void)dealloc{
    NSLog(@"Dealloc: %@",NSStringFromClass(self.class));
}
@end
