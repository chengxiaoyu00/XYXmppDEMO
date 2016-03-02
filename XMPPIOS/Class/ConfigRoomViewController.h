//
//  ConfigRoomViewController.h
//  XMPPIOS
//
//  Created by my on 14-5-15.
//  Copyright (c) 2014年 Dawn_wdf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDXML.h"
#import "XMPPRoom.h"

@class ConfigViews;
@interface ConfigRoomViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSXMLElement *configElement;
@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (nonatomic,strong) ConfigViews *configV;
@property (nonatomic, strong) XMPPRoom *xmppRoom;

- (void)parserConfigElement;
- (void)showPickerViewWithData:(NSDictionary *)data;
- (void)showTableViewWithData:(NSDictionary *)data;

@end
