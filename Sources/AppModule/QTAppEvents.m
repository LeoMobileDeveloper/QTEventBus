//
//  QTApplicationEvents.m
//  QTEventBus
//
//  Created by Leo on 2018/7/25.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTAppEvents.h"

#define __DEFAULT_IMP__(class) @implementation class\
@end

#define __STRING_PROP__(name) + (NSString *)name{\
return NSStringFromSelector(_cmd);\
}

__DEFAULT_IMP__(QTAppEvent)

__DEFAULT_IMP__(QTAppDidLaunchEvent)
__DEFAULT_IMP__(QTAppAllModuleInitEvent)

@implementation QTAppLifeCircleEvent

__STRING_PROP__(didBecomeActive)
__STRING_PROP__(willResignActive)
__STRING_PROP__(didEnterBackground)
__STRING_PROP__(willEnterForeground)
__STRING_PROP__(willTerminate)

- (NSString *)eventSubType{
    return self.type;
}

@end

@implementation QTAppProtectedDataEvent

__STRING_PROP__(willBecomeUnavailable);
__STRING_PROP__(didBecomeAvailable);

- (NSString *)eventSubType{
    return self.type;
}

@end

__DEFAULT_IMP__(QTAppDidReceiveLocalNotificationEvent)
__DEFAULT_IMP__(QTAppHandleBackgroundSessionEvent)
__DEFAULT_IMP__(QTAppDidRegisterRemoteNotificationEvent)
__DEFAULT_IMP__(QTAppWillContinueUserActivityEvent)
__DEFAULT_IMP__(QTAppContinueUserActivityEvent)
__DEFAULT_IMP__(QTAppDidUpdateUserActivityEvent)
__DEFAULT_IMP__(QTAppDidFailToContinueUserActivityEvent)
__DEFAULT_IMP__(QTAppPerformActionForShortcutItemEvent)
__DEFAULT_IMP__(QTAppHandleWatchKitExtensionRequestEvent)
__DEFAULT_IMP__(QTAppOpenURLEvent)
__DEFAULT_IMP__(QTAppHandleIntentEvent)
__DEFAULT_IMP__(QTAPPDidRegisterUserNotificationSettingsEvent)
__DEFAULT_IMP__(QTAppHandleActionForLocalNotificationEvent)
__DEFAULT_IMP__(QTAppHandleActionForRemoteNotificationEvent)
__DEFAULT_IMP__(QTAppDidReceiveMemoryWarningEvent)
__DEFAULT_IMP__(QTAppSignificantTimeChangeEvent)
__DEFAULT_IMP__(QTAppDidReceiveRemoteNotificationEvent)
