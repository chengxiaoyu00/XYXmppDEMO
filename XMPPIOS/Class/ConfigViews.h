//
//  ConfigViews.h
//  XMPPIOS
//
//  Created by my on 14-5-15.
//  Copyright (c) 2014年 Dawn_wdf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigRoomViewController.h"
typedef  void(^callbackblock)(id);
@interface ConfigViews : UIView<UITextFieldDelegate>
{
    callbackblock _block;
}
@property (nonatomic, strong) NSMutableDictionary *dataDic;
@property (nonatomic, strong) ConfigRoomViewController *configVC;
- (id)initWithFrame:(CGRect)frame data:(NSDictionary *)data callbackBlock:(callbackblock)block;
- (void)createViewWithData:(NSDictionary *)data;

@end
