//
//  DemoEvent.h
//  Demo
//
//  Created by Leo on 2018/7/23.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTEventBus.h"

@interface DemoEvent : NSObject<QTEvent>

@property (assign, nonatomic) long count;

@end
