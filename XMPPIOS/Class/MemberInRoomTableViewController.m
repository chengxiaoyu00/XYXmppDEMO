//
//  MemberInRoomTableViewController.m
//  XMPPIOS
//
//  Created by my on 14-5-16.
//  Copyright (c) 2014年 Dawn_wdf. All rights reserved.
//

#import "MemberInRoomTableViewController.h"

@interface MemberInRoomTableViewController ()
@property (nonatomic, strong) NSMutableDictionary *memberDic;
@end

@implementation MemberInRoomTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _memberDic = [NSMutableDictionary dictionary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addItems:(NSArray *)array type:(memberType)type
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:[_memberDic objectForKey:[NSString stringWithFormat:@"%d",type]]];
    [items removeAllObjects];
    [items addObjectsFromArray:array];
    if (items) {
        [_memberDic setObject:items forKey:[NSString stringWithFormat:@"%d",type]];
    }
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_memberDic count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_memberDic objectForKey:[NSString stringWithFormat:@"%d",section]] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    // Configure the cell...
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    NSArray *array = [_memberDic objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]] ;
    NSDictionary *dic = [array objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"nick"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"jid:%@/affiliation:%@/role:%@",[dic objectForKey:@"jid"],[dic objectForKey:@"affiliation"],[dic objectForKey:@"role"]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    NSInteger typeInt = [[[_memberDic allKeys] objectAtIndex:section] intValue];
    switch (section) {
        case 0:
            return @"memberType_ban";
            break;
        case 1:
            return @"memberType_members";

            break;
        case 2:
            return @"memberType_moderators";

            break;
        default:
            break;
    }
    return @"memberType";
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
