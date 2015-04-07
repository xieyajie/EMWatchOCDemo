//
//  FriendsController.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/1.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "FriendsController.h"

#import "RowType2Controller.h"

@interface FriendsController()

@end


@implementation FriendsController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
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
    self.dataSoure = nil;
}

#pragma mark - table

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    NSString *username = [self.dataSoure objectAtIndex:rowIndex];
    [self pushControllerWithName:@"ChatController" context:@{@"chatter":username, @"isGroup":[NSNumber numberWithBool:NO]}];
}

#pragma mark - data

- (void)loadData
{
    [self.dataSoure removeAllObjects];
    [WKInterfaceController openParentApplication:@{@"action":@"fetchFriends"} reply:^(NSDictionary *replyInfo, NSError *error) {
        NSArray *friends = [replyInfo objectForKey:@"friends"];
        [self.dataSoure addObjectsFromArray:friends];
        NSInteger count = [self.dataSoure count];
        [self.table setNumberOfRows:[self.dataSoure count] withRowType:@"RowType2Controller"];
        for (int i = 0; i < count; i++) {
            RowType2Controller *rowController = [self.table rowControllerAtIndex:i];
            
            NSString *username = [self.dataSoure objectAtIndex:i];
//            [rowController.imageView setImage:[UIImage imageNamed:@"friendHead"]];
            [rowController.titleLabel setText:username];
        }
    }];
}

@end



