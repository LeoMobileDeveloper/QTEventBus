//
//  NSNotification+QTEvent.m
//  QTEventBus
//
//  Created by Leo on 2018/6/1.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "NSNotification+QTEvent.h"

@implementation NSNotification (QTEvent)

- (NSString *)eventType{
    return self.name;
}

@end
