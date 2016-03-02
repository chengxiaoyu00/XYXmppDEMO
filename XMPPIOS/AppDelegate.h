//
//  AppDelegate.h
//  XMPPIOS
//
//  Created by Mac Pro on 13-8-21.
//  Copyright (c) 2013年 Dawn_wdf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
@protocol ChatDelegate;

typedef void(^callbackBlock)(id);

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    callbackBlock _callbackBlock;

    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPReconnect *xmppReconnect;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
    XMPPMessageArchiving *xmppMessageArchivingModule;
}
//---------------------------------------------------------------------
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchivingModule;

//---------------------------------------------------------------------
@property (nonatomic) BOOL isRegistration;

- (BOOL)myConnect;
- (void)getExistRoomBlock:(callbackBlock)block;
- (void)createReservedRoomWithJID:(NSString *)jid;

- (void)showAlertView:(NSString *)message;

@property (nonatomic,strong) id<ChatDelegate> chatDelegate;

@property (strong, nonatomic) UIWindow *window;

@end

@protocol ChatDelegate <NSObject>

-(void)friendStatusChange:(AppDelegate *)appD Presence:(XMPPPresence *)presence;
-(void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message;

@end
