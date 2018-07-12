//
//  QTBasicTests.m
//  QTEventBusTests
//
//  Created by Leo on 2018/2/24.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QTEventBus.h"
#import "QTMockEvent.h"
#import "QTMockIdEvent.h"

@interface QTBasicTests : XCTestCase

@property (strong, nonatomic) QTEventBus * eventBus;

@end

@implementation QTBasicTests

- (void)setUp {
    [super setUp];
    _eventBus = [[QTEventBus alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    _eventBus = nil;
}

- (void)testNormalEvent{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Normal test"];
    id<QTEventToken> token;
    token = [self.eventBus.on(QTMockEvent.class) next:^(QTMockEvent * event) {
        XCTAssert(event.value == 1);
        [token dispose];
        [expectation fulfill];
    }];
    QTMockEvent * event = [QTMockEvent eventWithValue:1];
    [self.eventBus dispatch:event];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testIdEvent{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Normal test"];
    NSString * type = @"unqiue_id_1";
    id<QTEventToken> token;
    token = [self.eventBus.on(QTMockIdEvent.class).ofType(type) next:^(QTMockEvent * event) {
        XCTAssert(event.value == 1);
        [token dispose];
        [expectation fulfill];
    }];
    QTMockIdEvent * event = [QTMockIdEvent eventWithValue:1 domain:type];
    [self.eventBus dispatch:event];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testAttachEvent{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Attach test"];
    NSString * _id = @"unqiue_id_1";
    @autoreleasepool{
        //强制释放object
        NSObject * object = [[NSObject alloc] init];
        [self.eventBus.on([QTMockIdEvent class]).ofType(_id).freeWith(object) next:^(QTMockIdEvent * event) {
            XCTAssert(event.value == 1 && [event.eventType isEqualToString:_id]);
        }];
        QTMockIdEvent * event = [QTMockIdEvent eventWithValue:1 domain:_id];
        [self.eventBus dispatch:event];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //Should not receive this event
        QTMockIdEvent * event = [QTMockIdEvent eventWithValue:2 domain:_id];
        [self.eventBus dispatch:event];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testNilAttachEvent{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Normal test"];
    id<QTEventToken> token;
    token = [self.eventBus.on(QTMockEvent.class).freeWith(nil) next:^(QTMockEvent * event) {
        XCTAssert(event.value == 1);
        [token dispose];
        [expectation fulfill];
    }];
    QTMockEvent * event = [QTMockEvent eventWithValue:1];
    [self.eventBus dispatch:event];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testDomainSpecificEvent{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Domain event"];
    NSString * _id = @"unqiue_id_1";
    id<QTEventToken> token;
    token = [self.eventBus.on(QTMockIdEvent.class).ofType(_id).freeWith(self) next:^(QTMockIdEvent * event) {
        XCTAssert(event.value == 1 && [event.eventType isEqualToString:_id]);
        [expectation fulfill];
    }];
    QTMockIdEvent * event = [QTMockIdEvent eventWithValue:1 domain:_id];
    [self.eventBus dispatch:event];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testManualDispose{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Domain event"];
    NSString * _id = @"unqiue_id_1";
    id<QTEventToken> token = [self.eventBus.on(QTMockIdEvent.class).ofType(_id).freeWith(self) next:^(QTMockIdEvent * event) {
        XCTAssert(false,"Should not receive event");
    }];
    [token dispose];
    QTMockIdEvent * event = [QTMockIdEvent eventWithValue:1 domain:_id];
    [self.eventBus dispatch:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        
    }];
}


@end
