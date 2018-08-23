//
//  QTNotificationTests.m
//  QTEventBusTests
//
//  Created by Leo on 2018/2/24.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QTEventBus.h"

NSString * const MockNotificationName = @"MockNotificationName";

@interface QTNotificationTests : XCTestCase

@property (strong, nonatomic) QTEventBus * eventBus;

@property (assign, nonatomic) BOOL receiveNoti1;
@property (assign, nonatomic) BOOL receiveNoti2;

@end

@implementation QTNotificationTests

- (void)setUp {
    [super setUp];
    _eventBus = [[QTEventBus alloc] init];
    _receiveNoti1 = NO;
    _receiveNoti2 = NO;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    _eventBus = nil;
}

- (void)testNormal {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Attach test"];
    @autoreleasepool{
        NSObject * object = [[NSObject alloc] init];
        [QTSubNoti(object, MockNotificationName) next:^(NSNotification * _Nullable event) {
            XCTAssert([event.object integerValue] == 1);
            self.receiveNoti1 = YES;
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:MockNotificationName
                                                            object:@(1)];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //这个通知应该收不到
        [[NSNotificationCenter defaultCenter] postNotificationName:MockNotificationName
                                                            object:@(2)];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(self.receiveNoti1);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testManualDispose{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Attach test"];
    id<QTEventToken> token;
    token = [self.eventBus.on(NSNotification.class).ofSubType(MockNotificationName) next:^(NSNotification * notification){
        self.receiveNoti2 = YES;
        XCTAssert([notification.object integerValue] == 1);
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:MockNotificationName
                                                        object:@(1)];
    [token dispose];
    //这个通知应该收不到
    [[NSNotificationCenter defaultCenter] postNotificationName:MockNotificationName
                                                        object:@(2)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(self.receiveNoti2);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
}

@end
