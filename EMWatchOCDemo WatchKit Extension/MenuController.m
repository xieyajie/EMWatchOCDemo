//
//  MenuController.m
//  EMWatchOCDemo WatchKit Extension
//
//  Created by dhc on 15/4/1.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "MenuController.h"

#import "RowType2Controller.h"

@interface MenuController()

@end


@implementation MenuController

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

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex
{
    return self.dataSoure[rowIndex];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    if ([table numberOfRows] == 1) {
        [WKInterfaceController openParentApplication:@{@"action":@"login"} reply:^(NSDictionary *replyInfo, NSError *error) {
            BOOL isLogined = NO;
            NSError *reError = [replyInfo objectForKey:@"error"];
            NSString *username = [replyInfo objectForKey:@"username"];
            NSString *password = [replyInfo objectForKey:@"password"];
            if (!reError && [username length] > 0 && [password length] > 0) {
                NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.EasemobWatchIM"];
                [sharedDefaults setObject:username forKey:@"username"];
                [sharedDefaults setObject:password forKey:@"password"];
                
                isLogined = YES;
            }
            
            [self refreshDataWithIsLogined:isLogined];
        }];
    }
    else{
        switch (rowIndex) {
            case 0:
            {
                [self pushControllerWithName:@"ConversationsController" context:nil];
            }
                break;
            case 1:
            {
                [self pushControllerWithName:@"FriendsController" context:nil];
            }
                break;
            case 2:
            {
                [self pushControllerWithName:@"GroupsController" context:nil];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - data

- (void)loadData
{
    [WKInterfaceController openParentApplication:@{@"action":@"isLogined"} reply:^(NSDictionary *replyInfo, NSError *error) {
        BOOL isLogined = NO;
        if ([replyInfo count] > 0) {
            isLogined = [[replyInfo objectForKey:@"isLogined"] boolValue];
        }
        
        [self refreshDataWithIsLogined:isLogined];
    }];
}

- (void)refreshDataWithIsLogined:(BOOL)isLogined
{
    if (isLogined) {
        NSDictionary *conversationInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"会话", @"title", nil];
        NSDictionary *friendInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"好友", @"title", nil];
        NSDictionary *groupInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"群组", @"title", nil];
        [self.dataSoure addObject:conversationInfo];
        [self.dataSoure addObject:friendInfo];
        [self.dataSoure addObject:groupInfo];
        
        NSInteger count = [self.dataSoure count];
        [self.table setNumberOfRows:[self.dataSoure count] withRowType:@"RowType2Controller"];
        for (int i = 0; i < count; i++) {
            RowType2Controller *rowController = [self.table rowControllerAtIndex:i];
            
            NSDictionary *dic = self.dataSoure[i];
            NSString *title = dic[@"title"];
            [rowController.titleLabel setText:title];
        }
    }
    else{
        [self.table setNumberOfRows:1 withRowType:@"RowType2Controller"];
        RowType2Controller *rowController = [self.table rowControllerAtIndex:0];
        [rowController.titleLabel setText:@"登录"];
    }
}

@end



