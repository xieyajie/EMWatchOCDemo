//
//  AppDelegate.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/1.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "EaseMob.h"
#import "DXEMIMHelper.h"
#import "HomeViewController.h"
#import "ChatSendHelper.h"

@interface AppDelegate ()<EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:163 / 255.0 green:215 / 255.0 blue:203 / 255.0 alpha:1.0]];
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:28 / 255.0 green:168 / 255.0 blue:219 / 255.0 alpha:1.0]];
        [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    }
    
    [DXEMIMHelper shareHelper];
    
#warning SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"chatdemoui_dev";
#else
    apnsCertName = @"chatdemoui";
#endif
    
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"easemob-demo#chatdemoui"
                                       apnsCertName:apnsCertName];
    
    // 登录成功后，自动去取好友列表
    // SDK获取结束后，会回调
    // - (void)didFetchedBuddyList:(NSArray *)buddyList error:(EMError *)error方法。
    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
    
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    HomeViewController *homeController = [[HomeViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:homeController];
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    [homeController loginAction:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //
}

#pragma mark - apple watch

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply
{
    if ([userInfo count] > 0) {
        NSString *actionString = [userInfo objectForKey:@"action"];
        
        EaseMob *easemob = [EaseMob sharedInstance];
        if ([actionString isEqualToString:@"isLogined"]) {
            reply(@{@"isLogined":[NSNumber numberWithBool:[easemob.chatManager isLoggedIn]]});
        }
        else if ([actionString isEqualToString:@"login"]){
            
            if (![easemob.chatManager isLoggedIn]) {
                EMError *error = nil;
                [easemob.chatManager loginWithUsername:@"awuser0" password:@"123456" error:&error];
                if (!error) {
                    reply(@{@"username":@"awuser0", @"password":@"123456"});
                }
                else{
                    NSError *reError = [NSError errorWithDomain:error.description code:error.errorCode userInfo:nil];
                    reply(@{@"error":reError});
                }
            }
            else{
                NSString *username = [[easemob.chatManager loginInfo] objectForKey:kSDKUsername];
                NSString *password = [[easemob.chatManager loginInfo] objectForKey:kSDKPassword];
                if ([username length] > 0 && [password length] > 0) {
                    reply(@{@"username":username, @"password":password});
                }
                else{
                    reply(nil);
                }
            }
        }
        else if ([actionString isEqualToString:@"fetchFriends"])
        {
            NSArray *buddys = [easemob.chatManager buddyList];
            NSMutableArray *usernames = [NSMutableArray array];
            for (EMBuddy *buddy in buddys) {
                [usernames addObject:buddy.username];
            }

            reply(@{@"friends":usernames});
        }
        else if ([actionString isEqualToString:@"fetchGroups"])
        {
            NSArray *groups = nil;
            if (![[DXEMIMHelper shareHelper] isFetchGroupsFromServer]) {
                EMError *groupError = nil;
                groups = [easemob.chatManager fetchMyGroupsListWithError:&groupError];
                [[DXEMIMHelper shareHelper] setIsFetchGroupsFromServer:(groupError ? NO : YES)];
            }
            else{
                groups = [easemob.chatManager groupList];
            }
            NSMutableArray *groupsArray = [NSMutableArray array];
            for (EMGroup *group in groups) {
                NSString *subject = [group.groupSubject length] > 0 ? group.groupSubject : group.groupId;
                NSDictionary *dic = @{@"groupId":group.groupId, @"groupSubject":subject};
                [groupsArray addObject:dic];
            }
            reply(@{@"groups":groupsArray});
        }
        else if ([actionString isEqualToString:@"fetchConversations"])
        {
            NSArray *conversations = [easemob.chatManager conversations];
            NSMutableArray *conversationsArray = [NSMutableArray array];
            for (EMConversation *conversation in conversations) {
                NSDictionary *dic = @{@"chatter":conversation.chatter, @"isGroup":[NSNumber numberWithBool:conversation.isGroup]};
                [conversationsArray addObject:dic];
            }
            reply(@{@"conversations":conversationsArray});
        }
        else if ([actionString isEqualToString:@"fetchMessages"])
        {
            NSMutableArray *messages = [NSMutableArray array];
            NSString *chatter = [userInfo objectForKey:@"chatter"];
            BOOL isGroup = [[userInfo objectForKey:@"isGroup"] boolValue];
            int currentCount = [[userInfo objectForKey:@"count"] intValue];

            if ([chatter length] > 0) {
                NSDictionary *userInfo = [[EaseMob sharedInstance].chatManager loginInfo];
                NSString *loginUser = [userInfo objectForKey:kSDKUsername];
                
                long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
                EMConversation *conversation = [easemob.chatManager conversationForChatter:chatter isGroup:isGroup];
                NSArray *msgs = [conversation loadNumbersOfMessages:currentCount before:timestamp];
                for (EMMessage *message in msgs) {
                    
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:message.messageId forKey:@"messageId"];
                    [dic setObject:[NSNumber numberWithInt:message.deliveryState] forKey:@"state"];
                    
                    BOOL isSender = [loginUser isEqualToString:message.from] ? YES : NO;
                    [dic setObject:[NSNumber numberWithBool:isSender] forKey:@"isSender"];
                    
                    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
                    [dic setObject:[NSNumber numberWithInt:messageBody.messageBodyType] forKey:@"type"];
                    switch (messageBody.messageBodyType) {
                        case eMessageBodyType_Text:
                        {
                            NSString *content = ((EMTextMessageBody *)messageBody).text;
                            if (content == nil) {
                                content = @"";
                            }
                            [dic setObject:content forKey:@"content"];
                        }
                            break;
                        case eMessageBodyType_Image:
                        {
                            EMImageMessageBody *imgMessageBody = (EMImageMessageBody*)messageBody;
                            
//                            NSString *localPath = imgMessageBody.localPath;
//                            if (localPath) {
//                                [dic setObject:localPath forKey:@"localPath"];
//                            }
                            
                            UIImage *thumbnailImage = [UIImage imageWithContentsOfFile:imgMessageBody.thumbnailLocalPath];;
                            if (thumbnailImage) {
                                [dic setObject:UIImageJPEGRepresentation(thumbnailImage, 1) forKey:@"thumbnailImageData"];
                            }
                        }
                            break;
                        case eMessageBodyType_Voice:
                        {
                            EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody *)messageBody;
                            NSNumber *len = [NSNumber numberWithInteger:voiceBody.duration];
                            [dic setObject:len forKey:@"length"];
                            
                            NSString *localPath = voiceBody.localPath;
                            if (localPath) {
                                [dic setObject:localPath forKey:@"localPath"];
                            }
                        }
                            break;
                        default:
                            break;
                    }
                    
                    [messages addObject:dic];
                }
            }
            else{
                chatter = @"";
            }
            
            NSDictionary *userInfo = [[EaseMob sharedInstance].chatManager loginInfo];
            NSString *login = [userInfo objectForKey:kSDKUsername];
            if ([login length] == 0) {
                login = @"";
            }
            reply(@{@"messages":messages, @"chatter":chatter});
        }
        else if ([actionString isEqualToString:@"sendText"])
        {
            NSString *text = [userInfo objectForKey:@"text"];
            NSString *to = [userInfo objectForKey:@"to"];
            BOOL isGroup = [[userInfo objectForKey:@"isGroup"] boolValue];
            
            // 表情映射。
            EMChatText *chatText = [[EMChatText alloc] initWithText:text];
            EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:chatText];
            EMMessage *message = [[EMMessage alloc] initWithReceiver:to bodies:[NSArray arrayWithObject:body]];
            message.requireEncryption = NO;
            message.isGroup = isGroup;
            [easemob.chatManager asyncSendMessage:message progress:nil prepare:^(EMMessage *message, EMError *error) {
                NSError *reError = [NSError errorWithDomain:error.description code:error.errorCode userInfo:nil];
                reply(@{@"error":reError, @"messageId":message.messageId});
            } onQueue:nil completion:^(EMMessage *message, EMError *error) {
                NSError *reError = [NSError errorWithDomain:error.description code:error.errorCode userInfo:nil];
                reply(@{@"error":reError, @"messageId":message.messageId});
            } onQueue:nil];
        }
    }
}

#pragma mark - Easemob

// 注册推送
- (void)registerRemoteNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
//    #if !TARGET_IPHONE_SIMULATOR
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
//    #endif
}

@end
