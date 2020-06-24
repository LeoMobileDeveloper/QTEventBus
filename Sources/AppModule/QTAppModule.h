//
//  QTAppModule.h
//  QTEventBus
//
//  Created by Leo on 2018/7/31.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#ifndef QTAppModule_h
#define QTAppModule_h

#import "QTAppEvents.h"

@protocol QTAppModule<NSObject>

/// App生命周期事件到来的时候，会调用这个方法生成实例
+ (id<QTAppModule>)moduleInstance;

@optional

#pragma mark - 常用

/// 启动
- (void)appDidFinishLaunch:(QTAppDidLaunchEvent *)event;

/// App全部的模块已初始化
- (void)appAllModuleInit:(QTAppAllModuleInitEvent *)event;

/// 生命周期变化
- (void)appLifeCircleChanged:(QTAppLifeCircleEvent *)event;

/// 处理后台Session
- (void)appHandleBackgroundSession:(QTAppHandleBackgroundSessionEvent *)event;

/// 注册远程通知token
- (void)appDidRegisterRemoteNotification:(QTAppDidRegisterRemoteNotificationEvent*)event;

/// 收到远程推送
- (void)appDidReceiveRemoteNotification:(QTAppDidReceiveRemoteNotificationEvent *)event;

/// 将要继续UserActivity
- (void)appWillContinueUserActivity:(QTAppWillContinueUserActivityEvent *)event;

/// 继续UserActivity
- (void)appContinueUserActivity:(QTAppContinueUserActivityEvent *)event;

/// UserActivity更新
- (void)appDidUpdateUserActivity:(QTAppDidUpdateUserActivityEvent *)event;

/// 继续UserActivity失败
- (void)appDidFailToContinueUserActivity:(QTAppDidFailToContinueUserActivityEvent *)event;

/// 处理3D Touch
- (void)appPerformActionForShortcutItem:(QTAppPerformActionForShortcutItemEvent *)event API_AVAILABLE(ios(9.0));

/// 处理OpenURL
- (void)appOpenURL:(QTAppOpenURLEvent *)event;

/// 处理Siri Intent
- (void)appHandleIntent:(QTAppHandleIntentEvent *)event API_AVAILABLE(ios(10.0));

/// 处理Apple Watch发送来的请求
- (void)appHandleWatchKitExtensionRequest:(QTAppHandleWatchKitExtensionRequestEvent *)event API_AVAILABLE(ios(8.2));

#pragma mark - 不常用

/**
 文档见类QTAppProtectedDataEvent
 */
- (void)appProtectedDataChanged:(QTAppProtectedDataEvent *)event;

/**
 文档见类QTAppSignificantTimeChangeEvent
 */
- (void)appSignificantTimeChange:(QTAppSignificantTimeChangeEvent *)event;

/**
 文档见类QTAppDidReceiveMemoryWarningEvent
 */
- (void)appDidReceiveMemoryWarningEvent:(QTAppDidReceiveMemoryWarningEvent *)event;

/**
 文档见类QTAPPDidRegisterUserNotificationSettingsEvent
 */
- (void)appDidRegisterUserNotificationSettings:(QTAPPDidRegisterUserNotificationSettingsEvent *)event NS_DEPRECATED_IOS(8_0, 10_0);

/**
 文档见类QTAppDidReceiveLocalNotificationEvent
 */
- (void)appDidReceiveLocalNotificaiton:(QTAppDidReceiveLocalNotificationEvent *)event NS_DEPRECATED_IOS(4_0, 10_0);;

/**
 文档见类QTAppHandleActionForLocalNotificationEvent
 */
- (void)appHandleActionForLocalNotification:(QTAppHandleActionForLocalNotificationEvent *)event NS_DEPRECATED_IOS(8_0, 10_0);

/**
 文档见类QTAppHandleActionForRemoteNotificationEvent
 */
- (void)appHandleActionForRemoteNotification:(QTAppHandleActionForRemoteNotificationEvent *)event NS_DEPRECATED_IOS(8_0, 10_0);

@end


#endif /* QTAppModule_h */
