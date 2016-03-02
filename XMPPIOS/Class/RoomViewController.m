//
//  RoomViewController.m
//  XMPPIOS
//
//  Created by my on 14-5-14.
//  Copyright (c) 2014年 Dawn_wdf. All rights reserved.
//

#import "RoomViewController.h"
#import "ConfigRoomViewController.h"
#import "MemberInRoomTableViewController.h"

@interface RoomViewController ()
{
    MemberInRoomTableViewController *memberVC;
}
@end

@implementation RoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.roomName;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    memberVC = [storyboard instantiateViewControllerWithIdentifier:@"member"];
    NSLog(@"%@",[_xmppRoom roomSubject]);
    self.roomSubjectTextField.text = [_xmppRoom roomSubject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getRoomInformation:(id)sender {
    [_xmppRoom fetchConfigurationForm];
}

- (IBAction)getMemberList:(id)sender {
    memberVC.xmppRoom = self.xmppRoom;
    [self.navigationController pushViewController:memberVC animated:YES];

    [_xmppRoom fetchModeratorsList];
    [_xmppRoom fetchMembersList];
    [_xmppRoom fetchBanList];
}
- (void)configurateRoomWithData:(NSXMLElement *)element
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    ConfigRoomViewController *config = [storyboard instantiateViewControllerWithIdentifier:@"config"];
    config.configElement = element;
    config.xmppRoom = self.xmppRoom;
    [config parserConfigElement];
    [self.navigationController pushViewController:config animated:YES];
}
- (void)listMemberWithData:(NSArray *)array type:(memberType)type
{
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSXMLElement *element in array) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSXMLElement *attr in element.attributes) {
            [dic setObject:attr.stringValue forKey:attr.name];
        }
        [resultArray addObject:dic];
    }
    [memberVC  addItems:resultArray type:type];
 
}

- (IBAction)changeRoomSubject:(id)sender {
    [_xmppRoom changeRoomSubject:self.roomSubjectTextField.text];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
