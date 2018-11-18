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
#import "QTEventBus+AppModule.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [QTSub(self, DemoEvent) next:^(DemoEvent *event) {
        NSLog(@"%ld",event.count);
    }];
    [QTSubNoti(self, @"name") next:^(NSNotification *event) {
        NSLog(@"%@",@"Block 1 Receive Notification");
    }];
    [QTSubNoti(self, @"name") next:^(NSNotification *event) {
        NSLog(@"%@",@"Block 2 Receive Notification");
    }];
    [QTSub(self, QTAppLifeCircleEvent).ofSubType(QTAppLifeCircleEvent.didEnterBackground)
     next:^(QTAppLifeCircleEvent *event) {
         NSLog(@"DemoViewController: %@",event.type);
    }];
    [QTSubName(self, @"ButtonClickedEvent") next:^(NSString *event) {
        NSLog(@"%@",@"Receive String Event");
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

- (IBAction)dispatchString:(id)sender {
    [[QTEventBus shared] dispatch:@"ButtonClickedEvent"];
}

- (void)dealloc{
    NSLog(@"Dealloc: %@",NSStringFromClass(self.class));
}

@end
