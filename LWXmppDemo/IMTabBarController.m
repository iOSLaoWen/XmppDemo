//
//  IMTabBarController.m
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/13.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import "IMTabBarController.h"
#import "RosterViewController.h"
#import "MessageViewController.h"
#import "RoomViewController.h"

@interface IMTabBarController ()

@end

@implementation IMTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customTabBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customTabBar {
    //历史消息
    MessageViewController *messageVC = [[MessageViewController alloc]init];
    UINavigationController *messageNav = [[UINavigationController alloc]initWithRootViewController:messageVC];
    messageNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"消息" image:nil selectedImage:nil];
    
    //花名册
    RosterViewController *rosterVC = [[RosterViewController alloc]init];
    UINavigationController *rosterNav = [[UINavigationController alloc]initWithRootViewController:rosterVC];
    rosterNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"通讯录" image:nil selectedImage:nil];
    
    //聊天室
    RoomViewController *roomVC = [[RoomViewController alloc]init];
    UINavigationController *roomNav = [[UINavigationController alloc]initWithRootViewController:roomVC];
    roomNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"聊天室" image:nil selectedImage:nil];
    
    self.viewControllers = @[messageNav, rosterNav, roomNav];
}

@end
