//
//  DXEMIMHelper.h
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/2.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EaseMob.h"

#define KNOTIFICATION_CHANGE_UNREAD @"unreadChange"
#define KNOTIFICATION_CHANGE_CONVERSATION @"conversationsChange"
#define KNOTIFICATION_CHANGE_FRIEND @"friendsChange"
#define KNOTIFICATION_CHANGE_GROUP @"groupsChange"

#define KDEFAULT_USERNAME @"awuser0"
#define KDEFAULT_PASSWORD @"123456"

@interface DXEMIMHelper : NSObject<EMChatManagerDelegate>
{
    NSDate *_lastPlaySoundDate;
}

@property (nonatomic) BOOL isFetchGroupsFromServer;

+ (instancetype)shareHelper;

@end
