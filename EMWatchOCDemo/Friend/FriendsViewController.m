//
//  FriendsViewController.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/5.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "FriendsViewController.h"

#import "EaseMob.h"
#import "DXEMIMHelper.h"
#import "ChatViewController.h"

@interface FriendsViewController ()

@property (strong, nonatomic) NSMutableArray *friends;

@end

@implementation FriendsViewController

@synthesize friends = _friends;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsChange:) name:KNOTIFICATION_CHANGE_FRIEND object:nil];
    
    _friends = [NSMutableArray array];
    [self loadAllFriends];
    self.tableView.tableFooterView = [[UIView alloc] init];
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
    return [_friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"GroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    EMBuddy *friend = [_friends objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"friendHead.png"];
    cell.textLabel.text = friend.username;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMBuddy *friend = [_friends objectAtIndex:indexPath.row];
    ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:friend.username isGroup:NO];
    chatController.title = friend.username;
    [self.navigationController pushViewController:chatController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

#pragma mark - NSNotification

- (void)friendsChange:(NSNotification *)notification
{
    [self loadAllFriends];
    [self.tableView reloadData];
}

#pragma mark - data

- (void)loadAllFriends
{
    [_friends removeAllObjects];
    
    NSArray *buddys = [[EaseMob sharedInstance].chatManager buddyList];
    [_friends addObjectsFromArray:buddys];
}

@end
