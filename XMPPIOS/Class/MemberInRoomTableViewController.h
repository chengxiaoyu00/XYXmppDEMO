//
//  MemberInRoomTableViewController.h
//  XMPPIOS
//
//  Created by my on 14-5-16.
//  Copyright (c) 2014年 Dawn_wdf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPRoom.h"

@interface MemberInRoomTableViewController : UITableViewController
@property (nonatomic, strong) XMPPRoom *xmppRoom;
- (void)addItems:(NSArray *)array type:(memberType)type;

@end
