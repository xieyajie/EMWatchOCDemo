//
//  DXTableInterfaceController.h
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/1.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface DXTableInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

@property (strong, nonatomic) NSMutableArray *dataSoure;

- (void)loadData;

@end
