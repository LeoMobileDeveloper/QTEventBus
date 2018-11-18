//
//  UIResponder+QTEventBus.h
//  QTEventBus
//
//  Created by Leo on 2018/11/18.
//  Copyright © 2018 Leo Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QTEventBus.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (QTEventBus)

/**
 沿着响应链，找到第一个isDispatcherProvider提供的EventBus
 */
@property (readonly, nullable, nonatomic) QTEventBus * eventDispatcher;

/**
 是否作为响应链上一个EventBust的提供者
 
 @note UIViewController这个值默认为YES，其他为NO
 */
@property (nonatomic, assign, getter=isDispatcherProvider) BOOL dispatcherProvider;

@end

NS_ASSUME_NONNULL_END
