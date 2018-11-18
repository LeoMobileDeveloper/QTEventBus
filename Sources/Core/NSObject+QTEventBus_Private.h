//
//  NSObject+QTEventBus_Private.h
//  Demo
//
//  Created by Leo on 2018/11/18.
//  Copyright © 2018 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTDisposeBag.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (QTEventBus_Private)

/**
 释放池
 */
@property (strong, nonatomic, readonly) QTDisposeBag * eb_disposeBag;

@end

NS_ASSUME_NONNULL_END
