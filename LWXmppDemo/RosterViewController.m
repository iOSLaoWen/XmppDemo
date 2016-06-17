//
//  RosterViewController.m
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/12.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import "RosterViewController.h"
#import <CoreData/CoreData.h>
#import "LWXmppManager.h"
#import "ChatViewController.h"
#import "AddNewFriendViewController.h"
#import "MyvCardViewController.h"

@interface RosterViewController ()<NSFetchedResultsControllerDelegate, XMPPRosterDelegate>

@property (nonatomic, strong)NSFetchedResultsController *resultsController;//Todo：改成只读

@end

@implementation RosterViewController
//@synthesize refreshControl = _resultsController;//wjl 没有这个就找不到_resultsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"通讯录";
    //self.hidesBottomBarWhenPushed = YES;
    [self custonNavBar];
    [[LWXmppManager sharedInstance].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)custonNavBar {
    //添加新用户
    UIBarButtonItem *itemAddFriend = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddUser)];
    UIBarButtonItem *itemMyCard = [[UIBarButtonItem alloc]initWithTitle:@"名片" style:UIBarButtonItemStylePlain target:self action:@selector(onBtnMyCardClicked)];
    self.navigationItem.rightBarButtonItems = @[itemAddFriend, itemMyCard];
}

- (NSFetchedResultsController *)resultsController {
    if (_resultsController == nil) {
        NSManagedObjectContext *context = [LWXmppManager sharedInstance].rosterManagedObjectContext;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        request.entity = entity;
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        request.sortDescriptors = @[sd1, sd2];//wjl 必须设置，否则出错
        //request.fetchBatchSize = 10;
        
        _resultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"sectionNum" cacheName:nil];//wjl 弄清参数3的意义
        _resultsController.delegate = self;
        [_resultsController performFetch:nil];//执行查询
    }
    return _resultsController;
}

//数据改变
//TODO:做得更友好一点，而不是整个刷新
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [self.resultsController sections].count;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *allSections = [self.resultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = allSections[section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.resultsController sections][section];
    NSString *sectionName = sectionInfo.name;
    switch (sectionName.intValue) {
        case 0:
            return @"在线";
        case 1:
            return @"离开";
        default:
            return @"离线";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *rosterCellId = @"rosterCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rosterCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:rosterCellId];
    }
    XMPPUserCoreDataStorageObject *user = [self.resultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = user.displayName;
    //cell.detailTextLabel.text = user.sectionName;
    [self showPhotoOnCell:cell ofUser:user];
    return cell;
}

- (void)showPhotoOnCell:(UITableViewCell *)cell ofUser:(XMPPUserCoreDataStorageObject *)user {
    if (user.photo != nil) {
        cell.imageView.image = user.photo;
        NSLog(@"photo <- photo");
    } else {
        XMPPvCardAvatarModule *avatar = [LWXmppManager sharedInstance].vCardAvatarModule;
        NSData *photoData = [avatar photoDataForJID:user.jid];
        if (photoData) {
            NSLog(@"photo <- data");
            cell.imageView.image = [UIImage imageWithData:photoData];
        } else {
            NSLog(@"photo null");
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.myJID = [LWXmppManager sharedInstance].xmppStream.myJID;
    
    XMPPUserCoreDataStorageObject *user = [self.resultsController objectAtIndexPath:indexPath];
    chatVC.targetJID = user.jid;
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

//支持左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPRoster *roster = [LWXmppManager sharedInstance].xmppRoster;
    XMPPUserCoreDataStorageObject *user = [self.resultsController objectAtIndexPath:indexPath];
    XMPPJID *jid = user.jid;
    [roster removeUser:jid];
}

- (void)onAddUser {
    AddNewFriendViewController *addNewFriend = [[AddNewFriendViewController alloc]init];
    [self.navigationController pushViewController:addNewFriend animated:YES];
}

- (void)onBtnMyCardClicked {
    MyvCardViewController *myvCard = [[MyvCardViewController alloc]init];
    [self.navigationController pushViewController:myvCard animated:YES];
}

//收到添加好友请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    
    //TODO:处理不在线时收到好友请求的情况
    //同意并把对方加入花名册
    [sender acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
}

@end
