//
//  ViewController.m
//  XMPPIOS
//
//  Created by Mac Pro on 13-8-21.
//  Copyright (c) 2013年 Dawn_wdf. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "XMPPRoomMemoryStorage.h"
#import "RoomViewController.h"
//#import "FriendsListViewController.h"
@interface RoomBtn : UIButton
@property (nonatomic, strong) NSString *jidStr;
@end
@implementation RoomBtn

@end
@interface ViewController ()<XMPPRoomStorage>
{
    XMPPRoomCoreDataStorage * _storage;
    XMPPRoom * _xmppRoom;
}
//@property (nonatomic, strong) XMPPRoomCoreDataStorage *roomStroage;
@property (nonatomic, strong) XMPPRoom *xmppRoom;
@property (nonatomic, strong) RoomViewController *roomVC;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _storage = [[XMPPRoomCoreDataStorage alloc] init];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    _roomVC = [storyboard instantiateViewControllerWithIdentifier:@"roomV"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - my methods
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
-(BOOL)allInformationReady{
    if (self.hostTextField.text && self.portTextField.text && self.myNameTextField.text && self.passwordTextField.text) {
        [[[self appDelegate] xmppStream] setHostName:self.hostTextField.text];
        [[[self appDelegate] xmppStream] setHostPort:self.portTextField.text.integerValue];
//        NSString*str=@"96E79218965EB72C92A549DD5A330112";
//        [[[self appDelegate] xmppStream] setHostPort:str.integerValue];
        [[NSUserDefaults standardUserDefaults]setObject:self.hostTextField.text forKey:kHost];
//        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@@%@/XMPPIOS",self.myNameTextField.text,self.hostTextField.text] forKey:kMyJID];
        [[NSUserDefaults standardUserDefaults]setObject:@"95013770013443@im.95013vh.com/IOS-vPhone" forKey:kMyJID];
        [[NSUserDefaults standardUserDefaults]setObject:@"96E79218965EB72C92A549DD5A330112"forKey:kPS];
        return YES;
    }
    [[self appDelegate] showAlertView:@"信息不完整"];
    return NO;
}
- (void)prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender
{
    if (![[[self appDelegate] xmppStream] isConnected]) {
        [[self appDelegate] showAlertView:@"not connected yet!!"];
    }
//    if ([segue.destinationViewController isKindOfClass:[FriendsListViewController class]]) {
//        FriendsListViewController *friends = segue.destinationViewController;
//        friends.xmppStream = self.xmppStream;
//    }
}
#pragma mark - IBAction
- (IBAction)connectToOpenfire:(id)sender {
    if (![self allInformationReady]) {
        return;
    }
//    [[self appDelegate]setIsRegistration:NO];
    [[self appDelegate]myConnect];
}

- (IBAction)registrationInBand:(id)sender {
    if (![self allInformationReady]) {
        return;
    }
    if ([[[self appDelegate] xmppStream] isConnected] && [[[self appDelegate]xmppStream] supportsInBandRegistration]) {
        NSError *error ;
        [[self appDelegate].xmppStream setMyJID:[XMPPJID jidWithUser:self.myNameTextField.text domain:self.hostTextField.text resource:@"XMPPIOS"]];
//        [[self appDelegate]setIsRegistration:YES];
        if (![[self appDelegate].xmppStream registerWithPassword:self.passwordTextField.text error:&error]) {
            [[self appDelegate] showAlertView:[NSString stringWithFormat:@"%@",error.description]];
        }
    }
}

- (IBAction)createRoom:(id)sender {
    
    XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@conference.%@",self.chatroom.text,self.hostTextField.text]];

    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_storage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    [_xmppRoom activate:[self appDelegate].xmppStream];
    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoom joinRoomUsingNickname:@"abc" history:nil];


}

- (IBAction)login:(id)sender {
    if ([[self appDelegate].xmppStream isConnected]) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:kPS]) {
            NSError *error ;
            if (![[self appDelegate].xmppStream authenticateWithPassword:[[NSUserDefaults standardUserDefaults]objectForKey:kPS] error:&error]) {
                NSLog(@"error authenticate : %@",error.description);
            }
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请先链接" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
   
}

- (IBAction)logout:(id)sender {
    [[self appDelegate].xmppStream disconnectAfterSending];
}

- (IBAction)getExistRoom:(id)sender {
    /*<iq from='hag66@shakespeare.lit/pda'
     id='zb8q41f4'
     to='chat.shakespeare.lit'
     type='get'>
     <query xmlns='http://jabber.org/protocol/disco#items'/>
     </iq>*/
    [[self appDelegate] getExistRoomBlock:^(id result) {
        XMPPIQ *iq = (XMPPIQ *)result;
        NSMutableArray *array = [NSMutableArray array];
        for (DDXMLElement *element in iq.children) {
            if ([element.name isEqualToString:@"query"]) {
                for (DDXMLElement *item in element.children) {
                    if ([item.name isEqualToString:@"item"]) {
                        [array addObject:item.attributes];
                    }
                }
            }
        }
        [self createExistRoomBtnsWith:array];
    }];
    
}
- (void)createExistRoomBtnsWith:(NSArray *)data
{
    float orY = 10;
    [_existRoomScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSArray *array in data) {
        NSString *jidStr = [[array objectAtIndex:0] stringValue];
        NSString *name = [[array objectAtIndex:1] stringValue];
        RoomBtn *btn = [RoomBtn buttonWithType:UIButtonTypeCustom];
        [btn setTitle:[NSString stringWithFormat:@"进入房间:%@ jid:%@",name,jidStr] forState:UIControlStateNormal];
        btn.frame = CGRectMake(10, orY, CGRectGetWidth(_existRoomScrollView.frame) - 20, 40);
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        btn.jidStr = jidStr;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [btn addTarget:self action:@selector(joinRoom:) forControlEvents:UIControlEventTouchUpInside];
        [_existRoomScrollView addSubview:btn];
        orY += 40;
    }
    _existRoomScrollView.contentSize = CGSizeMake(CGRectGetWidth(_existRoomScrollView.frame), orY);

}
- (void)joinRoom:(RoomBtn *)btn
{
    NSLog(@"%@",btn.jidStr);
    if ([_xmppRoom isJoined]) {
        _roomVC.roomName = _xmppRoom.roomJID.user;
        _roomVC.xmppRoom = _xmppRoom;
        [self.navigationController pushViewController:_roomVC animated:YES];
        return;
    }
    if (_xmppRoom == nil) {
        _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_storage jid:[XMPPJID jidWithString:btn.jidStr] dispatchQueue:dispatch_get_main_queue()];
        [_xmppRoom activate:[self appDelegate].xmppStream];
        [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    [_xmppRoom joinRoomUsingNickname:@"abc" history:nil];
}
#pragma mark - xmpproom delegate
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    NSLog(@"%@",sender);
//    [sender fetchConfigurationForm];
    [sender configureRoomUsingOptions:nil];
}
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    NSLog(@"%s",__func__);
    [_roomVC configurateRoomWithData:configForm];
}

- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm
{
    NSLog(@"%@",roomConfigForm);
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    NSLog(@"%@",iqResult);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"seccuss" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    NSLog(@"%@",iqResult);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"failed" message:iqResult.description delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
    
    _roomVC.roomName = sender.roomJID.user;
    _roomVC.xmppRoom = _xmppRoom;
    [self.navigationController pushViewController:_roomVC animated:YES];
}
- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);

}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);

}

/**
 * Invoked when a message is received.
 * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
 **/
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
    NSLog(@"%@",items);
    [_roomVC  listMemberWithData:items type:memberType_ban];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    NSLog(@"%@",items);
    [_roomVC listMemberWithData:items type:memberType_members];

}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);

}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    NSLog(@"%@",items);
    [_roomVC listMemberWithData:items type:memberType_moderators];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);

}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult
{
    NSLog(@"%@",iqResult);
}
- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
}

#pragma mark - XMPPRoom storage
- (BOOL)configureWithParent:(XMPPRoom *)aParent queue:(dispatch_queue_t)queue
{
    return YES;
}

/**
 * Updates and returns the occupant for the given presence element.
 * If the presence type is "available", and the occupant doesn't already exist, then one should be created.
 **/
- (void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room
{
    NSLog(@"%@",presence);
}

/**
 * Stores or otherwise handles the given message element.
 **/
- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room
{
    NSLog(@"%@",message.XMLString);
}
- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room
{
    NSLog(@"%@",message.XMLString);

}

/**
 * Handles leaving the room, which generally means clearing the list of occupants.
 **/
- (void)handleDidLeaveRoom:(XMPPRoom *)room
{
    NSLog(@"%@",room);
}
#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
