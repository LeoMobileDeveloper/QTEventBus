//
//  QTAppDelegate.h
//  QTEventBus
//
//  Created by Leo on 2018/7/25.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QTAppDelegate : UIResponder<UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/// 默认在debug模式下打印所有的模块方法调用和耗时
- (BOOL)shouldModuleMetrics;

@end
