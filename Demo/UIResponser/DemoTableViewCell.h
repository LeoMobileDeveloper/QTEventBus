//
//  DemoTableViewCell.h
//  Demo
//
//  Created by Leo on 2018/11/18.
//  Copyright © 2018 Leo Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QTEventBus+UIKit.h"

extern NSString * const Button1ClickedEvent; // 不带数据的Event

// 携带数据的Event
@interface Button2ClickEvent : NSObject<QTEvent>

@property (strong, nonatomic) UITableViewCell * cell;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DemoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;

@end

NS_ASSUME_NONNULL_END
