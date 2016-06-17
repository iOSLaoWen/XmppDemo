//
//  ChatViewController.h
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/12.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWXmppManager.h"

@interface ChatViewController : UIViewController

@property (nonatomic, strong)XMPPJID *myJID;
@property (nonatomic, strong)XMPPJID *targetJID;

@end
