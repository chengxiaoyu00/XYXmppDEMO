//
//  FriendsListViewController.h
//  XMPPIOS
//
//  Created by Mac Pro on 13-8-21.
//  Copyright (c) 2013年 Dawn_wdf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface FriendsListViewController : UITableViewController<ChatDelegate>

- (IBAction)addFriend:(id)sender;
@end
