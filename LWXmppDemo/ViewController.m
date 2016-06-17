//
//  ViewController.m
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/12.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import "ViewController.h"
#import "LWXMPPManager.h"
#import "IMTabBarController.h"

@interface ViewController ()<XMPPStreamDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBtnLogin:(UIButton *)sender {
    LWXmppManager *xmppManager = [LWXmppManager sharedInstance];
    [xmppManager.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppManager loginWithName:@"hello" andPassword:@"hello"];
}

- (IBAction)onBtnRegister:(UIButton *)sender {
    [[LWXmppManager sharedInstance]registerWithName:@"hello" andPassword:@"hello"];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    IMTabBarController *imTab = [[IMTabBarController alloc]init];
    self.view.window.rootViewController = imTab;
}

@end
