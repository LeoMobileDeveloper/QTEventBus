//
//  QTMockContainerValue.h
//  QTEventBusTests
//
//  Created by Leo on 2018/2/24.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTEventBusCollection.h"

@interface QTMockContainerValue : NSObject<QTEventBusContainerValue>

+ (instancetype)mockInstanceWithId:(NSString *)uniqueId;

@end
