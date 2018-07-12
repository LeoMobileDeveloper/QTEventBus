//
//  QTEventBusCollection.h
//  QTRadio
//
//  Created by Leo on 2018/2/7.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QTEventBusContainerValue<NSObject>

/**
 值的唯一标识符
 */
- (NSString *)valueUniqueId;

@end

/**
 保存监听者的容器，key映射到一个数组
 线程安全,
 插入,删除 O(1)
 */
@interface QTEventBusCollection<ValueType:id<QTEventBusContainerValue>> : NSObject

/**
 在key对应的集合中，增加一个对象
 */
- (void)addObject:(ValueType)object forKey:(NSString *)key;

/**
 删除key对应集合中的一个唯一对象，返回这个key对应的是否为空
 */
- (BOOL)removeUniqueId:(NSString *)uniqueId ofKey:(NSString *)key;

/**
 返回一组值，注意返回的是指针的浅拷贝
 */
- (NSArray<ValueType> *)objectsForKey:(NSString *)key;

@end
