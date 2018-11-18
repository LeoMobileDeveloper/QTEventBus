//
//  QTJsonEvent.h
//  QTEventBus
//
//  Created by Leo on 2018/7/5.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTEventTypes.h"

/**
 通用的JSON Event，用于松耦合事件传递。
 */
@interface QTJsonEvent : NSObject<QTEvent>

- (instancetype)init NS_UNAVAILABLE;

/**
 事件的唯一id
 */
@property (readonly) NSString * uniqueId;

/**
 事件的数据，只可能为NSDictionary或者NSArray
 */
@property (readonly) id data;

/**
 字典初始化
*/
+ (instancetype)eventWithId:(NSString *)uniqueId jsonObject:(NSDictionary *)data;

/**
 数组初始化
 */
+ (instancetype)eventWithId:(NSString *)uniqueId jsonArray:(NSArray *)data;


@end
