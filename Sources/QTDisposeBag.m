//
//  QTDisposeBag.m
//  QTEventBus
//
//  Created by Leo on 2018/6/4.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import "QTDisposeBag.h"

@interface QTDisposeBag()

@property (strong, nonatomic) NSMutableArray<id<QTEventToken>> * tokens;

@end

@implementation QTDisposeBag

- (NSMutableArray<id<QTEventToken>> *)tokens{
    if (!_tokens) {
        _tokens = [[NSMutableArray alloc] init];
    }
    return _tokens;
}

- (void)addToken:(id<QTEventToken>)token{
    @synchronized(self) {
        [self.tokens addObject:token];
    }
}

- (void)dealloc{
    @synchronized(self) {
        for (id<QTEventToken> token in self.tokens) {
            if ([token respondsToSelector:@selector(dispose)]) {
                [token dispose];
            }
        }
    }
}

@end
