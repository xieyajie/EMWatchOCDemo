//
//  DXEMIMHelper.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/2.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXEMIMHelper.h"

static DXEMIMHelper *helper = nil;

#define kDefaultPlaySoundInterval 3

@implementation DXEMIMHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isFetchGroupsFromServer = NO;
        
        [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    }
    
    return self;
}

+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[DXEMIMHelper alloc] init];
    });

    return helper;
}

- (void)dealloc
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    
    _lastPlaySoundDate = nil;
}

#pragma mark - private chat

- (void)_playSoundAndVibration
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval)
    {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        return;
    }
    
    //保存最后一次响铃时间
    _lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
    // 收到消息时，震动
    [[EaseMob sharedInstance].deviceManager asyncPlayVibration];
}

- (void)_showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = NSLocalizedString(@"message.vidio", @"Vidio");
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        if (message.isGroup) {
            EMGroup *group = [EMGroup groupWithId:message.conversationChatter];
            NSString *groupName = [group.groupSubject length] > 0 ? group.groupSubject : group.groupId;
            title = [NSString stringWithFormat:@"%@", groupName];
        }
        
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    
    notification.alertAction = @"打开";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - EMChatManagerChatDelegate 消息变化

- (void)didUpdateConversationList:(NSArray *)conversationList
{
    if (conversationList == nil) {
        conversationList = [[NSArray alloc] init];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CHANGE_CONVERSATION object:@{@"conversations":conversationList}];
}

// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CHANGE_UNREAD object:nil];
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CHANGE_CONVERSATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CHANGE_UNREAD object:nil];
}

#pragma mark - EMChatManagerBuddyDelegate 好友变化

- (void)didUpdateBuddyList:(NSArray *)buddyList
            changedBuddies:(NSArray *)changedBuddies
                     isAdd:(BOOL)isAdd
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CHANGE_FRIEND object:nil];
}

#pragma mark - EMChatManagerGroupDelegate 群组变化

- (void)didUpdateGroupList:(NSArray *)groupList
                     error:(EMError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CHANGE_GROUP object:nil];
}

@end
