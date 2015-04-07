//
//  ConversationsViewController.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/5.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "ConversationsViewController.h"

#import "DXEMIMHelper.h"
#import "ConversationCell.h"
#import "ChatViewController.h"
#import "NSDate+Category.h"
#import "ConvertToCommonEmoticonsHelper.h"

@interface ConversationsViewController ()

@property (strong, nonatomic) NSMutableArray *conversations;

@end

@implementation ConversationsViewController

@synthesize conversations = _conversations;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _conversations = [NSMutableArray array];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadChange:) name:KNOTIFICATION_CHANGE_UNREAD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationChange:) name:KNOTIFICATION_CHANGE_CONVERSATION object:nil];
    
    [self loadAllConversations];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_conversations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"ConversationCell";
    ConversationCell *cell = (ConversationCell *)[tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[ConversationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    EMConversation *conversation = [_conversations objectAtIndex:indexPath.row];
    cell.name = conversation.chatter;
    if (!conversation.isGroup) {
        cell.placeholderImage = [UIImage imageNamed:@"friendHead.png"];
    }
    else{
        cell.placeholderImage = [UIImage imageNamed:@"groupHead.png"];
    }
    cell.detailMsg = [self _subTitleMessageByConversation:conversation];
    cell.time = [self _lastMessageTimeByConversation:conversation];
    cell.unreadCount = conversation.unreadMessagesCount;
    if (indexPath.row % 2 == 1) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:246 / 255.0 green:246 / 255.0 blue:246 / 255.0 alpha:1.0];
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [ConversationCell tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMConversation *conversation = [_conversations objectAtIndex:indexPath.row];
    
    NSString *title = conversation.chatter;
    if (conversation.isGroup) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *group in groupArray) {
            if ([group.groupId isEqualToString:conversation.chatter]) {
                title = group.groupSubject;
                break;
            }
        }
    }
    
    ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:conversation.chatter isGroup:conversation.isGroup];
    chatController.title = title;
    [self.navigationController pushViewController:chatController animated:YES];
}

#pragma mark - helper

// 得到最后消息时间
-(NSString *)_lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到最后消息文字或者类型
-(NSString *)_subTitleMessageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                ret = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                ret = didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
                ret = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case eMessageBodyType_Location: {
                ret = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case eMessageBodyType_Video: {
                ret = NSLocalizedString(@"message.vidio1", @"[vidio]");
            } break;
            default: {
            } break;
        }
    }
    
    return ret;
}

#pragma mark - NSNotification

- (void)unreadChange:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)conversationChange:(NSNotification *)notification
{
    [self loadAllConversations];
    [self.tableView reloadData];
}

#pragma mark - data

- (void)loadAllConversations
{
    [_conversations removeAllObjects];
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    NSArray* sorte = [conversations sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2){
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return(NSComparisonResult)NSOrderedAscending;
                          }else {
                              return(NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    
    [_conversations addObjectsFromArray:sorte];
}

@end
