//
//  QTAppEvent.h
//  QTEventBus
//
//  Created by Leo on 2018/6/1.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 点语法提供全局的事件，其他的应用事件可以基于这个扩展
 */
@interface QTAppEvent : NSObject

@property (class, readonly) NSString * didBecomeActive;

@property (class, readonly) NSString * didEnterBackground;

@property (class, readonly) NSString * didFinishLaunching;

@property (class, readonly) NSString * didReceiveMemoryWarning;

@property (class, readonly) NSString * userDidTakeScreenshot;

@property (class, readonly) NSString * willEnterForground;

@property (class, readonly) NSString * willResignActive;

@property (class, readonly) NSString * willTerminate;

@end
