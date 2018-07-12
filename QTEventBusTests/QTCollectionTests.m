//
//  QTCollectionTests.m
//  QTEventBusTests
//
//  Created by Leo on 2018/2/24.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QTEventBusCollection.h"
#import "QTEventBus.h"
#import "QTMockContainerValue.h"

/**
 测试集合能够正常工作
 */
@interface QTCollectionTests : XCTestCase

@end

@implementation QTCollectionTests

- (void)setUp {
    [super setUp];
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAdd{
    NSString * key = NSStringFromSelector(_cmd);
    QTEventBusCollection * collection = [[QTEventBusCollection alloc] init];
    QTMockContainerValue * value1 = [QTMockContainerValue mockInstanceWithId:@"1"];
    [collection addObject:value1 forKey:key];
    NSArray * values = [collection objectsForKey:key];
    XCTAssert(values.count == 1, @"Count must be 1 here");
}

- (void)testAddRepeatUniqueId{
    NSString * key = NSStringFromSelector(_cmd);
    QTEventBusCollection * collection = [[QTEventBusCollection alloc] init];
    QTMockContainerValue * value1 = [QTMockContainerValue mockInstanceWithId:@"1"];
    [collection addObject:value1 forKey:key];
    [collection addObject:value1 forKey:key];
    NSArray * values = [collection objectsForKey:key];
    XCTAssert(values.count == 1, @"Count must be 1 here");
}

- (void)testMultiKeys{
    QTEventBusCollection * collection = [[QTEventBusCollection alloc] init];
    for (NSInteger i = 0; i < 10; i ++) {
        NSString * key = [NSStringFromSelector(_cmd) stringByAppendingString:@(i).stringValue];
        QTMockContainerValue * value = [QTMockContainerValue mockInstanceWithId:@(i).stringValue];
        [collection addObject:value forKey:key];
        NSArray * values = [collection objectsForKey:key];
        XCTAssert(values.count == 1, @"Count must be 1 here");
    }
}

- (void)testRemove{
    NSString * key = NSStringFromSelector(_cmd);
    NSString * uniqueId = @"1";
    QTEventBusCollection * collection = [[QTEventBusCollection alloc] init];
    QTMockContainerValue * value1 = [QTMockContainerValue mockInstanceWithId:uniqueId];
    [collection addObject:value1 forKey:key];
    NSArray * values = [collection objectsForKey:key];
    XCTAssert(values.count == 1, @"Count must be 1 here");
    [collection removeUniqueId:uniqueId ofKey:key];
    values = [collection objectsForKey:key];
    XCTAssert(values.count == 0, @"Count must be 0 here");
}

- (void)testFetch{
    QTEventBusCollection * collection = [[QTEventBusCollection alloc] init];
    NSInteger total = 100;
    NSString * key = @"1";
    for (NSInteger i = 0; i < total; i ++) {
        QTMockContainerValue * value = [QTMockContainerValue mockInstanceWithId:@(i).stringValue];
        [collection addObject:value forKey:key];
    }
    NSArray * values = [collection objectsForKey:key];
    XCTAssert(values.count == total, @"Count must equal");
}

- (void)testMultiThreading{
    QTEventBusCollection * collection = [[QTEventBusCollection alloc] init];
    XCTestExpectation * expectation = [self expectationWithDescription:@"Test multi threading"];
    dispatch_queue_t queue1 = dispatch_queue_create("com.eventbus.write.1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("com.eventbus.write.2", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t readQueue = dispatch_queue_create("com.eventbus.test.read", DISPATCH_QUEUE_SERIAL);
    NSString * key = @"1";
    dispatch_group_t group = dispatch_group_create();
    for (NSInteger i = 0; i < 10000; i++) {
        NSString * unqiueId = @(i).stringValue;
        QTMockContainerValue * value = [QTMockContainerValue mockInstanceWithId:unqiueId];
        dispatch_group_enter(group);
        dispatch_async(queue1, ^{
            [collection addObject:value forKey:key];
            dispatch_group_leave(group);
        });
        dispatch_group_enter(group);
        dispatch_async(queue2, ^{
            [collection addObject:value forKey:key];
            dispatch_group_leave(group);
        });
        dispatch_async(readQueue, ^{//读
            @autoreleasepool{
                NSArray * values = [collection objectsForKey:key];
                XCTAssert(values.count >= 0);
            }
        });
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSArray * values = [collection objectsForKey:key];
        XCTAssert(values.count == 10000);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
}

@end
