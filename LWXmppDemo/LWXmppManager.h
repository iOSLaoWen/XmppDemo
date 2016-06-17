//
//  LWXmppManager.h
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/12.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPRoster.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPvCardTemp.h"//必须加这个，否则上传头像编译不过
#import "XMPPvCardTempModule.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPMessageArchivingCoredataStorage.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPRoom.h"

@interface LWXmppManager : NSObject

+ (instancetype)sharedInstance;
- (void)loginWithName:(NSString *)name andPassword:(NSString *)password;
- (void)registerWithName:(NSString *)name andPassword:(NSString *)password;
- (void)goOnline;
- (void)configRoomWithJID:(XMPPJID *)roomJid andNickName:(NSString *)nickName;

@property (nonatomic, strong, readonly)XMPPStream *xmppStream;

@property (nonatomic, strong, readonly)XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly)XMPPRosterCoreDataStorage *rosterStorage;
@property (nonatomic, strong, readonly)NSManagedObjectContext *rosterManagedObjectContext;

@property (nonatomic, strong)XMPPvCardTempModule *vCardTempModule;
@property (nonatomic, strong)XMPPvCardAvatarModule *vCardAvatarModule;

@property (nonatomic, strong)XMPPMessageArchivingCoreDataStorage *messageArchvingStorage;
@property (nonatomic, strong)XMPPMessageArchiving *messageArchiving;

@property (nonatomic, strong)XMPPRoomCoreDataStorage *roomStorage;
@property (nonatomic, strong)XMPPRoom *room;

@end
