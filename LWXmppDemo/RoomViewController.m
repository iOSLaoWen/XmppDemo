//
//  RoomViewController.m
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/15.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import "RoomViewController.h"
#import "LWXmppManager.h"
#import "RoomOccupantsViewController.h"

@interface RoomViewController ()<XMPPRoomDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *textMessage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.topLayoutGuide
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //TODO:修改聊天室接口，根据参数（jid和昵称）创建并加入聊天室，并维护一个数组（已创建的聊天室列表）
    //加入聊天室
    XMPPJID *roomJid = [XMPPJID jidWithString:@"lwgroup@conference.wen.local"];
    //XMPPJID *roomJid = [XMPPJID jidWithUser:@"LWgroup" domain:@"	conference.wen.local" resource:nil];
    [[LWXmppManager sharedInstance] configRoomWithJID:roomJid andNickName:@"hello"];
    XMPPRoom *room = [LWXmppManager sharedInstance].room;
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    [self scrollToBottom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    NSLog(@"join room");
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    if ([message isMessageWithBody]) {
        NSLog(@"收到消息:%@", message.body);
    }
}

//有人加入聊天室
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    NSLog(@"%@进入聊天室", occupantJID.resource);//这里resource才是用户名
    //TODO:如何获取进入聊天室的人的昵称
}

//有人离开聊天室
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    NSLog(@"%@离开聊天室", occupantJID.resource);
}

- (IBAction)onBtnSendClicked:(UIButton *)sender {
    XMPPRoom *room = [LWXmppManager sharedInstance].room;
    [room sendMessageWithBody:_textMessage.text];
}

- (NSFetchedResultsController *)resultsController {
    if (_resultsController == nil) {
        NSString *entityName = NSStringFromClass([XMPPRoomMessageCoreDataStorageObject class]);
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:entityName];
        NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"localTimestamp" ascending:YES];
        request.sortDescriptors = @[sd1];
        NSManagedObjectContext *context = [LWXmppManager sharedInstance].roomStorage.mainThreadManagedObjectContext;
        _resultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        [_resultsController performFetch:nil];
    }
    return _resultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];//TODO:什么时候用indexPath什么时候用newIndexPath
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    [self scrollToBottom];
}

- (void)scrollToBottom {
    NSArray *sections = self.resultsController.sections;
    id<NSFetchedResultsSectionInfo> sectionInfo = sections[0];
    NSInteger numberOfRows = [sectionInfo numberOfObjects];
    if (numberOfRows > 0) {
        NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:numberOfRows-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastRowIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.resultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"roomChatCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    XMPPRoomMessageCoreDataStorageObject *roomMessage = [self.resultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = roomMessage.body;
    cell.detailTextLabel.text = roomMessage.isFromMe ? @"我" : roomMessage.nickname;
    return cell;
}

//TODO:改成侧滑看成员列表
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomOccupantsViewController *occupantVC = [[RoomOccupantsViewController alloc]init];
    [self.navigationController pushViewController:occupantVC animated:YES];
}

@end
