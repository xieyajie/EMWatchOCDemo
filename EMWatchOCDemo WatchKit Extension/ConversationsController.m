//
//  ConversationsController.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/1.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "ConversationsController.h"

#import "RowType2Controller.h"

@interface ConversationsController()

@end


@implementation ConversationsController

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
    NSDictionary *conversation = [self.dataSoure objectAtIndex:rowIndex];
    NSString *string = [conversation objectForKey:@"chatter"];
    BOOL isGroup = [[conversation objectForKey:@"isGroup"] boolValue];
    [self pushControllerWithName:@"ChatController" context:@{@"chatter":string, @"isGroup":[NSNumber numberWithBool:isGroup]}];
}

#pragma mark - data

- (void)loadData
{
    [self.dataSoure removeAllObjects];
    [WKInterfaceController openParentApplication:@{@"action":@"fetchConversations"} reply:^(NSDictionary *replyInfo, NSError *error) {
        NSArray *conversations = [replyInfo objectForKey:@"conversations"];
        [self.dataSoure addObjectsFromArray:conversations];
        NSInteger count = [self.dataSoure count];
        [self.table setNumberOfRows:[self.dataSoure count] withRowType:@"RowType2Controller"];
        for (int i = 0; i < count; i++) {
            RowType2Controller *rowController = [self.table rowControllerAtIndex:i];
            
            NSDictionary *conversation = [self.dataSoure objectAtIndex:i];
            NSString *string = [conversation objectForKey:@"chatter"];
            //            [rowController.imageView setImage:[UIImage imageNamed:@"friendHead"]];
            [rowController.titleLabel setText:string];
        }
    }];
}

@end



