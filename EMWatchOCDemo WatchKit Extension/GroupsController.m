//
//  GroupsController.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/1.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "GroupsController.h"

#import "RowType2Controller.h"

@interface GroupsController()

@end


@implementation GroupsController

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

#pragma mark - table

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    NSDictionary *group = [self.dataSoure objectAtIndex:rowIndex];
    NSString *groupId = [group objectForKey:@"groupId"];
    [self pushControllerWithName:@"ChatController" context:@{@"chatter":groupId, @"isGroup":[NSNumber numberWithBool:YES]}];
}

#pragma mark - data

- (void)loadData
{
    [self.dataSoure removeAllObjects];
    [WKInterfaceController openParentApplication:@{@"action":@"fetchGroups"} reply:^(NSDictionary *replyInfo, NSError *error) {
        NSArray *groups = [replyInfo objectForKey:@"groups"];
        [self.dataSoure addObjectsFromArray:groups];
        NSInteger count = [self.dataSoure count];
        [self.table setNumberOfRows:[self.dataSoure count] withRowType:@"RowType2Controller"];
        for (int i = 0; i < count; i++) {
            RowType2Controller *rowController = [self.table rowControllerAtIndex:i];
            
            NSDictionary *group = [self.dataSoure objectAtIndex:i];
            NSString *string = [group objectForKey:@"groupSubject"];
            //            [rowController.imageView setImage:[UIImage imageNamed:@"friendHead"]];
            [rowController.titleLabel setText:string];
        }
    }];
}

@end



