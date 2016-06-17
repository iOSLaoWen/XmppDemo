//
//  ChatViewController.m
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/12.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import "ChatViewController.h"
#import "LWXmppManager.h"

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, XMPPStreamDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;

@property (nonatomic, strong)NSFetchedResultsController *messageResults;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.textField.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardDidHideNotification object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
    [self.tableView addGestureRecognizer:tap];
    
    [[LWXmppManager sharedInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self scrollToBottom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.messageResults.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.messageResults.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"chatCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }

    XMPPMessageArchiving_Message_CoreDataObject *messageArchiving = [self.messageResults objectAtIndexPath:indexPath];
    cell.textLabel.text = messageArchiving.body;
    //NSLog(@"bare:%@", messageArchiving.bareJidStr);
    if (messageArchiving.isOutgoing) {
        cell.detailTextLabel.text = @"我";
    } else {
        cell.detailTextLabel.text = messageArchiving.bareJid.user;//todo:显示昵称
    }
    return cell;
}

- (void)onKeyboardShow:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView setAnimationDuration:duration];//TODO:wjl 约束的动画效果
    [UIView beginAnimations:nil context:nil];
    _bottomViewBottomConstraint.constant = keyboardFrame.size.height;
    [UIView commitAnimations];
}

- (void)onKeyboardHide:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView setAnimationDuration:duration];
    [UIView beginAnimations:nil context:nil];
    _bottomViewBottomConstraint.constant = 0;
    [UIView commitAnimations];
}
- (void)onTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (BOOL)checkInput {
    return YES;
}

- (void)sendMesssage {
    if (![self checkInput]) {
        return;
    }
    NSString *text = _textField.text;
    XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:_targetJID];
    [xmppMessage addBody:text];
    [[LWXmppManager sharedInstance].xmppStream sendElement:xmppMessage];
    _textField.text = @"";
}

- (IBAction)onBtnSendClicked:(UIButton *)sender {
    [self sendMesssage];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendMesssage];
    return YES;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody]) {
        NSLog(@"好友说话了:%@", message.body);
    } else {
        NSLog(@"其它消息");
    }
}

- (NSFetchedResultsController *)messageResults {
    if (_messageResults == nil) {
        NSString *entityName = NSStringFromClass([XMPPMessageArchiving_Message_CoreDataObject class]);
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:entityName];
        NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
        request.sortDescriptors = @[sd1];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr==%@", _targetJID.bare];//筛选出当前好友的聊天记录
        request.predicate = predicate;
        NSManagedObjectContext *context = [LWXmppManager sharedInstance].messageArchvingStorage.mainThreadManagedObjectContext;
        _messageResults = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _messageResults.delegate = self;
        [_messageResults performFetch:nil];
    }
    return _messageResults;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete://wjl 不太可能发生吧
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            if (![indexPath isEqual:newIndexPath]) {//有的时候有假移动，所以要判断一下
                [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            }
        case NSFetchedResultsChangeUpdate://不太可能有
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    [self scrollToBottom];
}

- (void)scrollToBottom {
    NSArray *sections = self.messageResults.sections;
    id<NSFetchedResultsSectionInfo> sectionInfo = sections[0];
    NSInteger numberOfRows = [sectionInfo numberOfObjects];
    if (numberOfRows > 0) {
        NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:numberOfRows-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastRowIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

@end
