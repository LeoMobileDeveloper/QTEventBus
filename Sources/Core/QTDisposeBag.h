//
//  QTDisposeBag.h
//  QTEventBus
//
//  Created by Leo on 2018/6/4.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTEventTypes.h"

@interface QTDisposeBag : NSObject

/**
 增加一个需要释放的token
 */
- (void)addToken:(id<QTEventToken>)token;

@end
