//
//  DXTableInterfaceController.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/1.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXTableInterfaceController.h"


@interface DXTableInterfaceController()

@end


@implementation DXTableInterfaceController

@synthesize table = _table;
@synthesize dataSoure = _dataSoure;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    _dataSoure = [NSMutableArray array];
    [self loadData];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)dealloc
{
    _dataSoure = nil;
}

#pragma mark - public

- (void)loadData
{
    
}

@end



