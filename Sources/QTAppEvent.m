//
//  QTAppEvent.m
//  QTEventBus
//
//  Created by Leo on 2018/6/1.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTAppEvent.h"
#import <UIKit/UIKit.h>

@implementation QTAppEvent

+ (NSString *)didBecomeActive{
    return UIApplicationDidBecomeActiveNotification;
}

+ (NSString *)didEnterBackground{
    return UIApplicationDidEnterBackgroundNotification;
}

+ (NSString *)didFinishLaunching{
    return UIApplicationDidFinishLaunchingNotification;
}

+ (NSString *)didReceiveMemoryWarning{
    return UIApplicationDidReceiveMemoryWarningNotification;
}

+ (NSString *)userDidTakeScreenshot{
    return UIApplicationUserDidTakeScreenshotNotification;
}

+ (NSString *)willEnterForground{
    return UIApplicationWillEnterForegroundNotification;
}

+ (NSString *)willResignActive{
    return UIApplicationWillResignActiveNotification;
}

+ (NSString *)willTerminate{
    return UIApplicationWillTerminateNotification;
}

@end
