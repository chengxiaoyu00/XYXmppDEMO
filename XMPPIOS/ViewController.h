//
//  ViewController.h
//  XMPPIOS
//
//  Created by Mac Pro on 13-8-21.
//  Copyright (c) 2013年 Dawn_wdf. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *hostTextField;
@property (strong, nonatomic) IBOutlet UITextField *portTextField;
@property (strong, nonatomic) IBOutlet UITextField *myNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *chatroom;
@property (weak, nonatomic) IBOutlet UIScrollView *existRoomScrollView;
- (IBAction)connectToOpenfire:(id)sender;
- (IBAction)registrationInBand:(id)sender;
- (IBAction)createRoom:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)getExistRoom:(id)sender;
@end
