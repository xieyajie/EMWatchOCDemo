//
//  HomeViewController.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/1.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "HomeViewController.h"

#import "EaseMob.h"
#import "DXEMIMHelper.h"
#import "ConversationsViewController.h"
#import "FriendsViewController.h"
#import "GroupsViewController.h"
#import "UIViewController+HUD.h"

@interface HomeViewController ()<EMChatManagerDelegate>

@property (strong, nonatomic) ConversationsViewController *conversationsController;

@property (strong, nonatomic) FriendsViewController *friendController;

@property (strong, nonatomic) GroupsViewController *groupsController;

@property (strong, nonatomic) UIBarButtonItem *loginItem;

@end

@implementation HomeViewController

@synthesize conversationsController = _conversationsController;
@synthesize friendController = _friendController;
@synthesize groupsController = _groupsController;

@synthesize loginItem = _loginItem;

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        [loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
        _loginItem = [[UIBarButtonItem alloc] initWithCustomView:loginButton];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self _setupSubviews];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadChange:) name:KNOTIFICATION_CHANGE_UNREAD object:nil];
    
    [self unreadChange:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - layouts

-(void)_unSelectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:14], UITextAttributeFont,[UIColor grayColor],UITextAttributeTextColor,
                                        nil] forState:UIControlStateNormal];
}

-(void)_selectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:14],
                                        UITextAttributeFont,[UIColor colorWithRed:28 / 255.0 green:168 / 255.0 blue:219 / 255.0 alpha:1.0],UITextAttributeTextColor,
                                        nil] forState:UIControlStateSelected];
}

- (void)_setupSubviews
{
    self.title = @"会话";
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _conversationsController = [[ConversationsViewController alloc] init];
    _conversationsController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"会话" image:nil tag:0];
    [_conversationsController.tabBarItem setImage:[UIImage imageNamed:@"tabbar_chats"]];
    [self _unSelectedTapTabBarItems:_conversationsController.tabBarItem];
    [self _selectedTapTabBarItems:_conversationsController.tabBarItem];
    
    _friendController = [[FriendsViewController alloc] initWithNibName:nil bundle:nil];
    _friendController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"好友" image:nil tag:1];
    [_friendController.tabBarItem setImage:[UIImage imageNamed:@"tabbar_contacts"]];
    _friendController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self _unSelectedTapTabBarItems:_friendController.tabBarItem];
    [self _selectedTapTabBarItems:_friendController.tabBarItem];
    
    _groupsController = [[GroupsViewController alloc] init];
    _groupsController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"群组" image:nil tag:2];
    [_groupsController.tabBarItem setImage:[UIImage imageNamed:@"tabbar_setting"]];
    [self _unSelectedTapTabBarItems:_groupsController.tabBarItem];
    [self _selectedTapTabBarItems:_groupsController.tabBarItem];
    
    self.viewControllers = @[_conversationsController, _friendController, _groupsController];
    [self _selectedTapTabBarItems:_conversationsController.tabBarItem];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = @"会话";
    }else if (item.tag == 1){
        self.title = @"好友";
    }else if (item.tag == 2){
        self.title = @"群组";
    }
}

#pragma mark - NSNotification

- (void)unreadChange:(NSNotification *)notification
{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (_conversationsController) {
        if (unreadCount > 0) {
            _conversationsController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _conversationsController.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

#pragma mark - other

- (void)loginAction:(id)sender
{
    [self.navigationItem setLeftBarButtonItem:nil];
    BOOL isLogin = [[EaseMob sharedInstance].chatManager isLoggedIn];
    if (!isLogin) {
        [self showHudInView:self.view hint:@"正在登录..."];
        [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:KDEFAULT_USERNAME password:KDEFAULT_PASSWORD withCompletion:^(NSString *username, NSString *password, EMError *error) {
            if (error) {
                if (error.errorCode == EMErrorServerDuplicatedAccount || !error) {
                    EMError *loginError = nil;
                    [[EaseMob sharedInstance].chatManager loginWithUsername:KDEFAULT_USERNAME password:KDEFAULT_PASSWORD error:&loginError];
                    if (loginError && loginError.errorCode != EMErrorServerTooManyOperations) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"登录失败,请重新登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                        [self.navigationItem setLeftBarButtonItem:_loginItem];
                    }
                }
                else{
                    [self.navigationItem setLeftBarButtonItem:_loginItem];
                }
            }
            [self hideHud];
        } onQueue:nil];
    }
}

@end
