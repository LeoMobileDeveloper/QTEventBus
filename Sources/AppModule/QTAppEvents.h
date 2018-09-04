//
//  QTApplicationEvents.h
//  QTEventBus
//
//  Created by Leo on 2018/7/25.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QTEventTypes.h"
#import <Intents/Intents.h>
#import "QTEventBus.h"

/// 抽象类
@interface QTAppEvent: NSObject

@property (strong, nonatomic) UIApplication * application;

@end

/**
 App启动事件，通常不要直接QTSub这个事件，因为Sub的时候事件已经发生了
 用QTAppModule去注册一个模块，然后在对应的方法里初始化
 
 对应UIApplicationDelegate方法：
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
 */
@interface QTAppDidLaunchEvent: QTAppEvent<QTEvent>

///启动参数
@property (strong, nonatomic) NSDictionary * launchOptions;

@end

@interface QTAppAllModuleInitEvent: QTAppEvent<QTEvent>

@property (strong, nonatomic) NSDictionary * launchOptions;

@end

/**
 App生命周期事件

 分别对应UIApplicationDelegate方法：
 - applicationDidBecomeActive:
 - applicationWillResignActive:
 - applicationDidEnterBackground:
 - applicationWillEnterForeground:
 - applicationWillTerminate:
 */
@interface QTAppLifeCircleEvent: QTAppEvent <QTEvent>

/// 类型
@property (strong, nonatomic) NSString * type;

@property (class, readonly) NSString * didBecomeActive;
@property (class, readonly) NSString * willResignActive;
@property (class, readonly) NSString * didEnterBackground;
@property (class, readonly) NSString * willEnterForeground;
@property (class, readonly) NSString * willTerminate;

@end

/**
 App受保护事件变化方法
 
 分别对应UIApplicationDelegate方法：
 - applicationProtectedDataWillBecomeUnavailable:
 - applicationProtectedDataDidBecomeAvailable:
 */
@interface QTAppProtectedDataEvent: QTAppEvent<QTEvent>

@property (copy, nonatomic) NSString * type;
@property (class, readonly) NSString * willBecomeUnavailable;
@property (class, readonly) NSString * didBecomeAvailable;

@end


/**
 对应UIApplicationDelegate方法：
 - applicationSignificantTimeChange:
 */
@interface QTAppSignificantTimeChangeEvent: QTAppEvent<QTEvent>

@end

/**
 内存警告
 对应UIApplicationDelegate方法：
 - applicationDidReceiveMemoryWarning:
 */
@interface QTAppDidReceiveMemoryWarningEvent: QTAppEvent<QTEvent>

@end


/**
 对应UIApplicationDelegate方法：
 - application:handleEventsForBackgroundURLSession:completionHandler:
 */
@interface QTAppHandleBackgroundSessionEvent: QTAppEvent<QTEvent>
@property (copy  , nonatomic) NSString * identifier;
@property (strong, nonatomic) void (^completionHander)(void);
@end

/**
 对应UIApplicationDelegate方法：
 - application:didRegisterForRemoteNotificationsWithDeviceToken:
 - application:didFailToRegisterForRemoteNotificationsWithError:
 */
@interface QTAppDidRegisterRemoteNotificationEvent: QTAppEvent<QTEvent>

@property (copy  , nonatomic) NSData * deviceToken;
@property (strong, nonatomic) NSError * error;

@end

/**
 对应UIApplicationDelegate方法：
 - application:willContinueUserActivityWithType:
 */
@interface QTAppWillContinueUserActivityEvent: QTAppEvent<QTEvent>
@property (copy  , nonatomic) NSString * userActivityType;
@end

/**
 对应UIApplicationDelegate方法：
 - application:continueUserActivity:restorationHandler:
 */
@interface QTAppContinueUserActivityEvent: QTAppEvent<QTEvent>
@property (strong, nonatomic) NSUserActivity * userActivity;
@property (copy  , nonatomic) void (^restorationHandler)(NSArray *restorableObjects);
@end

/**
 对应UIApplicationDelegate方法：
 - application:didUpdateUserActivity:
 */
@interface QTAppDidUpdateUserActivityEvent: QTAppEvent<QTEvent>
@property (strong, nonatomic) NSUserActivity * userActivity;
@end

/**
 对应UIApplicationDelegate方法：
 - application:didFailToContinueUserActivityWithType:error:
 */
@interface QTAppDidFailToContinueUserActivityEvent: QTAppEvent<QTEvent>
@property (copy  , nonatomic) NSString * userActivityType;
@property (strong, nonatomic) NSError * error;
@end

/**
 对应UIApplicationDelegate方法：
 - application:performActionForShortcutItem:completionHandler:
 */
API_AVAILABLE(ios(9.0))
@interface QTAppPerformActionForShortcutItemEvent: QTAppEvent<QTEvent>
@property (strong, nonatomic) UIApplicationShortcutItem * shortcutItem;
@property (strong, nonatomic) void (^completionHandler)(BOOL succeeded);
@end

/**
 对应UIApplicationDelegate方法：
 - application:handleWatchKitExtensionRequest:reply:
 */
API_AVAILABLE(ios(8.2))
@interface QTAppHandleWatchKitExtensionRequestEvent: QTAppEvent<QTEvent>
@property (strong, nonatomic) NSDictionary * userInfo;
@property (copy,   nonatomic) void (^reply)(NSDictionary *replyInfo);
@end

/**
 对应UIApplicationDelegate方法：
 - application:handleOpenURL:
 - application:openURL:sourceApplication:annotation:
 - application:openURL:options:
 */
@interface QTAppOpenURLEvent: QTAppEvent<QTEvent>
@property (strong, nonatomic) NSURL * url;
@property (strong, nonatomic) NSDictionary<UIApplicationOpenURLOptionsKey, id> * options API_AVAILABLE(ios(9.0));
@property (strong, nonatomic) NSString * sourceApplication NS_DEPRECATED_IOS(4_2, 9_0);
@property (strong, nonatomic) id annotation NS_DEPRECATED_IOS(4_2, 9_0);
@end

/**
 对应UIApplicationDelegate方法：
 - application:handleIntent:completionHandler:
 */
API_AVAILABLE(ios(10.0))
@interface QTAppHandleIntentEvent: QTAppEvent<QTEvent>
@property (strong, nonatomic) INIntent * intent;
@property (strong, nonatomic) void (^completionHandler)(INIntentResponse *intentResponse);
@end

/**
 对应UIApplicationDelegate方法：
 - application:didRegisterUserNotificationSettings:
 */
NS_DEPRECATED_IOS(8_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenter requestAuthorizationWithOptions:completionHandler:]")
@interface QTAPPDidRegisterUserNotificationSettingsEvent: QTAppEvent<QTEvent>
@property (strong, nonatomic) UIUserNotificationSettings * notificationSettings;
@end

/**
 对应UIApplicationDelegate方法：
 - application:didReceiveLocalNotification:
 */
NS_DEPRECATED_IOS(4_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]") __TVOS_PROHIBITED
@interface QTAppDidReceiveLocalNotificationEvent: QTAppEvent<QTEvent>
@property (strong, nonatomic) UILocalNotification * notification;
@end

/**
 对应UIApplicationDelegate方法：
 
 - application:didReceiveRemoteNotification:
 */
NS_DEPRECATED_IOS(3_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:] for user visible notifications and -[UIApplicationDelegate application:didReceiveRemoteNotification:fetchCompletionHandler:] for silent remote notifications")
@interface QTAppDidReceiveRemoteNotificationEvent: QTAppEvent<QTEvent>
@property (strong, nonatomic) NSDictionary * userInfo;
@end

/**
  对应UIApplicationDelegate方法：
  - application:handleActionWithIdentifier:forLocalNotification:completionHandler:
  - application:handleActionWithIdentifier:forLocalNotification:withResponseInfo:completionHandler:
 */
NS_DEPRECATED_IOS(8_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
@interface QTAppHandleActionForLocalNotificationEvent: QTAppEvent<QTEvent>
@property (strong, nonatomic) NSString * identifier;
@property (strong, nonatomic) UILocalNotification * notification;
@property (copy,   nonatomic) void (^completionHandler)(void);
@property (strong, nonatomic) NSDictionary * responseInfo NS_DEPRECATED_IOS(9_0, 10_0);
@end

/**
 对应UIApplicationDelegate方法：
 - application:handleActionWithIdentifier:forRemoteNotification:completionHandler:
 - application:handleActionWithIdentifier:forRemoteNotification:withResponseInfo:completionHandler:
 */
NS_DEPRECATED_IOS(8_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
@interface QTAppHandleActionForRemoteNotificationEvent: QTAppEvent<QTEvent>
@property (strong, nonatomic) NSString * identifier;
@property (strong, nonatomic) NSDictionary * userInfo;
@property (strong, nonatomic) void (^completionHandler)(void);
@property (strong, nonatomic) NSDictionary * responseInfo NS_DEPRECATED_IOS(9_0, 10_0);
@end





