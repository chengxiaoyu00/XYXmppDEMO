//
//  RoomViewController.h
//  XMPPIOS
//
//  Created by my on 14-5-14.
//  Copyright (c) 2014年 Dawn_wdf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPRoom.h"
@interface RoomViewController : UIViewController
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) XMPPRoom *xmppRoom;
@property (weak, nonatomic) IBOutlet UITextField *roomSubjectTextField;
- (IBAction)getRoomInformation:(id)sender;
- (IBAction)getMemberList:(id)sender;
- (void)configurateRoomWithData:(NSXMLElement *)element;
- (void)listMemberWithData:(NSArray *)array type:(memberType)type;
- (IBAction)changeRoomSubject:(id)sender;

@end
