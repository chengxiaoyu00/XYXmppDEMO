//
//  ChatViewController.m
//  XMPPIOS
//
//  Created by Mac Pro on 13-8-22.
//  Copyright (c) 2013年 Dawn_wdf. All rights reserved.
//

#import "ChatViewController.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
@interface ChatViewController ()
{
    BOOL isAudio;
    AVAudioRecorder *recorder;
    NSURL *urlPlay;
    
}
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *toJIDString;
@property (nonatomic, strong) XMPPJID *toJID;
@property (copy, nonatomic) NSString *originWav;         

@end

@implementation ChatViewController
@synthesize xmppUserObject;
@synthesize recorderVC;
@synthesize originWav;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    recorderVC = [[ChatVoiceRecorderVC alloc]init];
    recorderVC.vrbDelegate = self;
    self.dataArray = [[NSMutableArray alloc]init];
    self.title = self.xmppUserObject.displayName;
    self.toJIDString = self.xmppUserObject.jidStr;
    self.toJID = self.xmppUserObject.jid;
    [self getMessageData];
    if (self.dataArray.count > 1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - my method
- (AppDelegate *)appDelegate
{
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.chatDelegate = self;
	return delegate;
}
- (void)getMessageData{
    NSManagedObjectContext *context = [[self appDelegate].xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSError *error ;
    NSArray *messages = [context executeFetchRequest:request error:&error];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:messages];
}
- (void)sendAudio:(id)sender {
}
- (void)sendMessage{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.toJID];
    [message addBody:self.messageTextField.text];
    [[[self appDelegate] xmppStream] sendElement:message];
}
#pragma mark - IBAction
- (IBAction)sendDone:(id)sender {
    [self sendMessage];
    [self.messageTextField resignFirstResponder];
    [self.messageTextField setText:nil];
    [self getMessageData];
    [self.tableView reloadData];
}

- (IBAction)cancelDone:(id)sender {
    [self.messageTextField resignFirstResponder];
    [self.messageTextField setText:nil];
}

- (IBAction)beginAudio:(id)sender {
    //设置文件名
    self.originWav = [VoiceRecorderBaseVC getCurrentTimeString];
    //开始录音
    [recorderVC beginRecordByFileName:self.originWav];

}

- (IBAction)endAudio:(id)sender {
    [VoiceConverter wavToAmr:[VoiceRecorderBaseVC getPathByFileName:originWav ofType:@"wav"] amrSavePath:[VoiceRecorderBaseVC getPathByFileName:self.originWav ofType:@"amr"]];

}
#pragma mark - VoiceRecorderBaseVC Delegate Methods
//录音完成回调，返回文件路径和文件名
- (void)VoiceRecorderBaseVCRecordFinish:(NSString *)_filePath fileName:(NSString*)_fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[[paths objectAtIndex:0]stringByAppendingPathComponent:@"Voice"] stringByAppendingPathComponent:[[_fileName stringByAppendingString:@".amr"] stringByReplacingOccurrencesOfString:@".wav" withString:@""]];
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    if ([fileManager fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSString *base64 = [data base64EncodedString];
        [self sendAudio:base64 withName:_fileName];
    }
}
-(void)sendAudio:(NSString *)base64String withName:(NSString *)audioName{
    NSMutableString *soundString = [[NSMutableString alloc]initWithString:@"base64"];
    [soundString appendString:base64String];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.toJID];
    [message addBody:soundString];
    [[[self appDelegate] xmppStream] sendElement:message];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    // Configure the cell...
    XMPPMessageArchiving_Message_CoreDataObject *object = [self.dataArray objectAtIndex:indexPath.row];
    NSMutableString *showString = [[NSMutableString alloc] init];
    if (object.bareJidStr) {
        [showString appendFormat:@"bareJidStr:%@\n",object.bareJidStr];
    }
    if (object.body) {
        if ([object.body hasPrefix:@"base64"]) {
            [showString appendFormat:@"语音文件"];
            NSData *audioData = [[object.body substringFromIndex:6] base64DecodedData];
        }else{
            [showString appendFormat:@"body:%@\n",object.body];
        }
    }
    if (object.isOutgoing) {
        [showString appendFormat:@"isOutgoing\n"];
    }else{
        [showString appendFormat:@"no out going \n"];
    }
    if (object.timestamp) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        [showString appendFormat:@"timestamp:%@\n",[formatter stringFromDate:object.timestamp]];
    }
    cell.textLabel.numberOfLines = 50;
    cell.textLabel.text = showString;
    return cell;
}
#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - keyboard reference
-(void)WillChangeFrame:(NSNotification *)notif{
    CGRect chatRect = CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.frame = CGRectMake(0, chatRect.origin.y, chatRect.size.width, chatRect.size.height - keyboardSize.height );
        self.toolbar.center = CGPointMake(self.toolbar.center.x,self.view.bounds.size.height -  keyboardSize.height - self.toolbar.bounds.size.height / 2);
    } completion:^(BOOL finish){
        if (self.dataArray.count > 1) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}
- (void)keyboardWillHidden:(NSNotification *)notif{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 40);\
        self.toolbar.center = CGPointMake(self.toolbar.center.x, self.view.bounds.size.height - self.toolbar.bounds.size.height / 2);
    } completion:^(BOOL finish){
    }];
    
    
}
#pragma mark - ChatDelegate
-(void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message
{
    [self getMessageData];
    [self.tableView reloadData];
}
-(void)friendStatusChange:(AppDelegate *)appD Presence:(XMPPPresence *)presence
{
}


@end
