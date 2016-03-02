//
//  XMPPCore.h
//  XMPPIOS
//
//  Created by xy on 16/2/26.
//  Copyright © 2016年 Dawn_wdf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#define tag_subcribe_alertView 100
@protocol ChatDelegate;
typedef void(^callbackBlock)(id);
@interface XMPPCore : NSObject
{
    callbackBlock _callbackBlock;
    
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPReconnect *xmppReconnect;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
    XMPPMessageArchiving *xmppMessageArchivingModule;
}
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchivingModule;

@property (nonatomic) BOOL isRegistration;

- (BOOL)myConnect;
- (void)getExistRoomBlock:(callbackBlock)block;
- (void)createReservedRoomWithJID:(NSString *)jid;
- (void)showAlertView:(NSString *)message;

@property (nonatomic, strong) id<ChatDelegate>chatDelegate;

@end

@protocol ChatDelegate <NSObject>

-(void)friendStatusChange:(XMPPCore *)appD Presence:(XMPPPresence *)presence;
-(void)getNewMessage:(XMPPCore *)appD Message:(XMPPMessage *)message;

@end