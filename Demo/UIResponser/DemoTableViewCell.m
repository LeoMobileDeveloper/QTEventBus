//
//  DemoTableViewCell.m
//  Demo
//
//  Created by Leo on 2018/11/18.
//  Copyright © 2018 Leo Huang. All rights reserved.
//

#import "DemoTableViewCell.h"

NSString * const Button1ClickedEvent = @"Button1ClickedEvent"; // 不带数据的Event

@implementation Button2ClickEvent

@end

@implementation DemoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)button1Clicked:(id)sender {
    [self.eventDispatcher dispatch:Button1ClickedEvent];
}

- (IBAction)button2Clicked:(id)sender {
    Button2ClickEvent * event = [[Button2ClickEvent alloc] init];
    event.cell = self;
    [self.eventDispatcher dispatch:event];
}

@end
