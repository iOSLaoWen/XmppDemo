//
//  MessageViewController.m
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/13.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import "MessageViewController.h"
#import "LWXmppManager.h"
#import "ChatViewController.h"

@interface MessageViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong)NSFetchedResultsController *resultsController;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"消息";
    
#if 1

#else
    NSManagedObjectContext *context = [LWXmppManager sharedInstance].messageArchvingStorage.mainThreadManagedObjectContext;
    NSString *entityName = NSStringFromClass([XMPPMessageArchiving_Message_CoreDataObject class]);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    request.entity = entity;
    //request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp != %@ and bareJidStr=='spark@wen.local'", [NSDate date]];
    request.predicate = predicate;
    
    NSArray *array = [context executeFetchRequest: request error:nil];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)resultsController {
    if (_resultsController == nil) {
        NSManagedObjectContext *context = [LWXmppManager sharedInstance].messageArchvingStorage.mainThreadManagedObjectContext;
        NSString *entityName = NSStringFromClass([XMPPMessageArchiving_Contact_CoreDataObject class]);
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        request.entity = entity;
        
        NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:NO];//时间降序
        request.sortDescriptors = @[sd1];
        
        _resultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        [_resultsController performFetch:nil];
    }
    return _resultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.resultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"messageCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    XMPPMessageArchiving_Contact_CoreDataObject *contact = [self.resultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = contact.mostRecentMessageBody;
    cell.detailTextLabel.text = contact.bareJidStr;
    
    return cell;
}

//TODO:不显示最近聊天室消息或点组消息时进入聊天室
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.myJID = [LWXmppManager sharedInstance].xmppStream.myJID;
    
    XMPPMessageArchiving_Contact_CoreDataObject *contact = [self.resultsController objectAtIndexPath:indexPath];
    chatVC.targetJID = contact.bareJid;
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
