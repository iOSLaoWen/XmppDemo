//
//  LWXmppManager.m
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/12.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import "LWXmppManager.h"

@interface LWXmppManager ()<XMPPStreamDelegate, XMPPRosterDelegate, XMPPRoomDelegate>

@end

static LWXmppManager *manager = nil;

@implementation LWXmppManager {
    NSString *_name;
    NSString *_password;
    BOOL _isLogin;
}

+ (instancetype)sharedInstance {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[LWXmppManager alloc]init];
        }
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _xmppStream = [[XMPPStream alloc]init];
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self configRoster];
        [self configvCard];
        [self configMessageArchiving];
    }
    return self;
}

- (void)connectWithName:(NSString *)name andPassword:(NSString *)password {
    if (_xmppStream.isConnected) {
        [_xmppStream disconnect];
    }
    _password = password;
    _xmppStream.hostName = @"wen.local";
    _xmppStream.hostPort = 5222;
    
    XMPPJID *myJid = [XMPPJID jidWithUser:name domain:@"wen.local" resource:@"iPhone"];
    _xmppStream.myJID = myJid;
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:120 error:&error]) {
        NSLog(@"连接出错:%@", error);
    }
}

- (void)loginWithName:(NSString *)name andPassword:(NSString *)password {
    _isLogin = YES;
    [self connectWithName:name andPassword:password];
}

//Todo:自己注册的用户在服务器上看不到，但是能登录？
- (void)registerWithName:(NSString *)name andPassword:(NSString *)password {
    _isLogin = NO;
    [self connectWithName:name andPassword:password];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSError *error = nil;
    if (_isLogin) {//登录
        if(![_xmppStream authenticateWithPassword:_password error:&error]) {
            NSLog(@"认证错误:%@", error);
        }
    } else {//注册
        if (![_xmppStream registerWithPassword:_password error:&error]) {
            NSLog(@"注册错误:%@", error);
        }
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"DidDisconnectWithError:%@", error);
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"认证成功");
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"认证失败:%@", error);
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    NSLog(@"注册失败:%@", error);
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    NSLog(@"注册完成");
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}

#pragma mark 花名册
- (void)configRoster {
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc]init];
    _xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:_rosterStorage];
    _xmppRoster.autoFetchRoster = YES;
    _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    [_xmppRoster activate:_xmppStream];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    NSLog(@"xmppRosterDidEndPopulating");
}

- (NSManagedObjectContext *)rosterManagedObjectContext {
    return [_rosterStorage mainThreadManagedObjectContext];
}

//电子名片
- (void)configvCard {
    XMPPvCardCoreDataStorage *vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];

    _vCardTempModule = [[XMPPvCardTempModule alloc]initWithvCardStorage:vCardStorage];
    _vCardAvatarModule = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:_vCardTempModule];
    [_vCardTempModule activate:_xmppStream];
    [_vCardAvatarModule activate:_xmppStream];
}

//消息归档
- (void)configMessageArchiving {
    _messageArchvingStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _messageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:_messageArchvingStorage];
    [_messageArchiving activate:_xmppStream];
}

//聊天室
- (void)configRoomWithJID:(XMPPJID *)roomJid andNickName:(NSString *)nickName {
    _roomStorage = [XMPPRoomCoreDataStorage sharedInstance];
    _room = [[XMPPRoom alloc]initWithRoomStorage:_roomStorage jid:roomJid];
    //[_room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_room activate:_xmppStream];
    [_room joinRoomUsingNickname:nickName history:nil];
}

@end
