//
//  DemoTableViewController.m
//  Demo
//
//  Created by Leo on 2018/11/18.
//  Copyright © 2018 Leo Huang. All rights reserved.
//

#import "DemoTableViewController.h"
#import "DemoTableViewCell.h"

@interface DemoTableViewController ()

@end

@implementation DemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"DemoTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"cell"];
    //弱持有Self，因为self持有EventBus，EventBus持有block
    __weak typeof(self) weakSelf = self;
    
    
    //Cell中Button1点击，采用String来唯一区分
    [[self subscribeName:Button1ClickedEvent on:self.eventDispatcher]
     next:^(NSString *event) {
         NSLog(@"Button 1 clicked");
    }];
    
    //Cell中Button2点击，采用类来区分
    [[self subscribe:Button2ClickEvent.class on:self.eventDispatcher]
     next:^(Button2ClickEvent * event) {
         NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:event.cell];
         NSLog(@"Button 2 in cell %ld clicked",(long)indexPath.row);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DemoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.indexLabel.text = @(indexPath.row).stringValue;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}


@end
