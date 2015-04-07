//
//  GroupsViewController.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/5.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "GroupsViewController.h"

#import "EaseMob.h"
#import "DXEMIMHelper.h"
#import "ChatViewController.h"

@interface GroupsViewController ()

@property (strong, nonatomic) NSMutableArray *groups;

@end

@implementation GroupsViewController

@synthesize groups = _groups;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupsChange:) name:KNOTIFICATION_CHANGE_GROUP object:nil];
    
    _groups = [NSMutableArray array];
    [self loadAllGroups];
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
    return [_groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"GroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    EMGroup *group = [_groups objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"groupHead.png"];
    NSString *title = [group.groupSubject length] > 0 ? group.groupSubject : group.groupId;
    cell.textLabel.text = title;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMGroup *group = [_groups objectAtIndex:indexPath.row];
    
    ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:group.groupId isGroup:YES];
    chatController.title = [group.groupSubject length] > 0 ? group.groupSubject : group.groupId;
    [self.navigationController pushViewController:chatController animated:YES];
}

#pragma mark - NSNotification

- (void)groupsChange:(NSNotification *)notification
{
    [self loadAllGroups];
    [self.tableView reloadData];
}

#pragma mark - data

- (void)loadAllGroups
{
    [_groups removeAllObjects];
    
    NSArray *rooms = [[EaseMob sharedInstance].chatManager groupList];
    [_groups addObjectsFromArray:rooms];
}

@end
