//
//  ChatViewController.h
//  XMPPIOS
//
//  Created by Mac Pro on 13-8-22.
//  Copyright (c) 2013年 Dawn_wdf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
#import "AppDelegate.h"
#import "ChatVoiceRecorderVC.h"
#import "VoiceConverter.h"

@interface ChatViewController : UIViewController<ChatDelegate,VoiceRecorderBaseVCDelegate>
@property (nonatomic,strong) XMPPUserCoreDataStorageObject *xmppUserObject;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic)  ChatVoiceRecorderVC  *recorderVC;

- (void)sendAudio:(id)sender;
- (IBAction)sendDone:(id)sender;
- (IBAction)cancelDone:(id)sender;
- (IBAction)beginAudio:(id)sender;
- (IBAction)endAudio:(id)sender;
@end
