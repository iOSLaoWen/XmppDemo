//
//  AddNewFriendViewController.m
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/15.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import "AddNewFriendViewController.h"
#import "LWXmppManager.h"

@interface AddNewFriendViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textFriendName;
@property (weak, nonatomic) IBOutlet UITextField *textRemark;

@end

@implementation AddNewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//TODO:检查输入是否合法
- (BOOL)checkInput {
    return YES;
}

- (IBAction)onBtnAddNewFriendClicked:(UIButton *)sender {
    if (![self checkInput]) {
        return;
    }
    
    LWXmppManager *xmppManager = [LWXmppManager sharedInstance];
    NSString *friendName = _textFriendName.text;
    XMPPJID *jid = [XMPPJID jidWithUser:friendName domain:@"wen.local" resource:nil];//TODO:domain提取出来
    NSString *remark = _textRemark.text;
    if (remark.length < 1) {//如果备注（昵称）为空则显示用户列表会出问题。
        remark = jid.bare;//备注（昵称）为空时用jid做为备注，这样用户列表与spark一致
    }
    [xmppManager.xmppRoster addUser:jid withNickname:remark];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
