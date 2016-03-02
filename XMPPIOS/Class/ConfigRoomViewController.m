//
//  ConfigRoomViewController.m
//  XMPPIOS
//
//  Created by my on 14-5-15.
//  Copyright (c) 2014年 Dawn_wdf. All rights reserved.
//

#import "ConfigRoomViewController.h"
#import "ConfigViews.h"

@interface ConfigRoomViewController ()
{
    UIPickerView *_pickerView;
    NSDictionary *_pickerData;
    UITableView *_tableView;
    
    NSMutableDictionary *_postDic;
    NSXMLElement *_postElement;
}
@end

@implementation ConfigRoomViewController

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
    // Do any additional setup after loading the view from its nib.
    _pickerData = [NSDictionary dictionary];
    _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 250)];
    _pickerView.backgroundColor = [UIColor colorWithWhite:.8 alpha:.8];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    [self.view addSubview:_pickerView];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(40, 80, CGRectGetWidth(self.view.frame) - 80, CGRectGetHeight(self.view.frame) - 140) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.hidden = YES;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.allowsMultipleSelection = YES;
    [self.view addSubview:_tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(postData:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)parserConfigElement
{
    _postElement = self.configElement;
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    NSMutableArray *fields = [NSMutableArray array];
    for (DDXMLElement *element in [self.configElement children] ) {
        if ([element.name isEqualToString:@"field"]) {
            NSMutableDictionary *eleDic = [NSMutableDictionary dictionary];
            NSMutableDictionary *attributesDic = [NSMutableDictionary dictionary];
            NSMutableArray *childrenArray = [NSMutableArray array];
            for (DDXMLElement *attri in element.attributes) {
//                [attributesArray addObject:@{attri.name: attri.stringValue}];
                [attributesDic setObject:attri.stringValue forKey:attri.name];
            }

            for (DDXMLElement *childrenEle in element.children) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];

                if (childrenEle.attributes.count > 0 ) {
                    for (DDXMLElement *ele in childrenEle.attributes) {
                        [dic setObject:ele.stringValue forKey:ele.name];
                    }
                }
            
                if (childrenEle.name.length > 0 ) {
                    [dic setObject:childrenEle.stringValue forKey:childrenEle.name];

                    if (childrenEle.childCount > 0) {
                        for (DDXMLElement *ele in childrenEle.children) {
                            [dic setObject:ele.stringValue forKey:ele.name];
                        }
                    }
                }
                [childrenArray addObject:dic];
            }
            [eleDic setObject:attributesDic forKey:@"attributes"];
            [eleDic setObject:childrenArray forKey:@"children"];
            [fields addObject:eleDic];
        }else{
            [resultDic setObject:element.stringValue forKey:element.name];
        }
    }
    [resultDic setObject:fields forKey:@"fields"];
    _postDic = resultDic;
    [self createViewWithData:resultDic];
}
- (void)createViewWithData:(NSDictionary *)dataDic
{
    self.title =[NSString stringWithFormat:@"%@", [dataDic objectForKey:@"title"]];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[dataDic objectForKey:@"instructions"] delegate:self cancelButtonTitle:@"填写" otherButtonTitles:@"确定", nil];
    [alert show];
    float originY = 10;
    for (NSDictionary *dic in [dataDic objectForKey:@"fields"]) {
        
        NSMutableArray *fields = [NSMutableArray arrayWithArray:[_postDic objectForKey:@"fields"]];
        NSInteger index = [fields indexOfObject:dic];
        
        ConfigViews *view = [[ConfigViews alloc]initWithFrame:CGRectMake(0, originY, CGRectGetWidth(self.view.frame), 40) data:dic callbackBlock:^(id result) {
            if ([result isKindOfClass:[NSMutableDictionary class]]) {
//                NSLog(@"%@",result);
                [fields replaceObjectAtIndex:index withObject:result];
                [_postDic setObject:fields forKey:@"fields"];
            }
        }];
        view.configVC = self;
        [self.bgScrollView addSubview:view];
        originY += CGRectGetHeight(view.frame);
    }
    self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), originY + 10);
    
}
- (void)postData:(id)sender
{
    [self postDataDefault:NO];
}
- (void)postDataDefault:(BOOL)isDefault
{
    if (isDefault) {
        [self.xmppRoom configureRoomUsingOptions:nil];
        return;
    }
    // <iq type='set'
    //       id='create2'
    //       to='coven@chat.shakespeare.lit'>
    //   <query xmlns='http://jabber.org/protocol/muc#owner'>
    //     <x xmlns='jabber:x:data' type='submit'>
    //       <field var='FORM_TYPE'>
    //         <value>http://jabber.org/protocol/muc#roomconfig</value>
    //       </field>
    //       <field var='muc#roomconfig_roomname'>
    //         <value>A Dark Cave</value>
    //       </field>
    //       <field var='muc#roomconfig_enablelogging'>
    //         <value>0</value>
    //       </field>
    //       ...
    //     </x>
    //   </query>
    // </iq>
    NSXMLElement *xElement = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    NSArray *fields = [_postDic objectForKey:@"fields"];
    for (NSDictionary *dic in fields) {
        NSDictionary *attribute = [dic objectForKey:@"attributes"];
        NSArray *children = [dic objectForKey:@"children"];
        NSXMLElement *fieldElement = [NSXMLElement elementWithName:@"field"];
        for (NSString *key in attribute.allKeys) {
            [fieldElement addAttributeWithName:key stringValue:[attribute objectForKey:key]];
        }
        
        for (NSDictionary *dic in children) {
            if ([dic objectForKey:@"option"]) {
                NSXMLElement *optionElement = [NSXMLElement elementWithName:@"option"];
                if ([dic objectForKey:@"label"]) {
                    [optionElement addAttributeWithName:@"label" stringValue:[dic objectForKey:@"label"]];
                }
                if ([dic objectForKey:@"value"]) {
                    [optionElement addChild:[NSXMLElement elementWithName:@"value" stringValue:[dic objectForKey:@"value"]]];
                }
                [fieldElement addChild:optionElement];
            }else if([dic objectForKey:@"value"]){
                [fieldElement addChild:[NSXMLElement elementWithName:@"value" stringValue:[dic objectForKey:@"value"]]];
            }
        }
        [xElement addChild:fieldElement];
    }
//    NSLog(@"%@",xElement.description);
    [_xmppRoom configureRoomUsingOptions:xElement];
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            [self postDataDefault:YES];
        }
            break;
        default:
            break;
    }
}
#pragma mark - picker view
- (void)showPickerViewWithData:(NSDictionary *)data
{
    _pickerData = data;
    [self.view bringSubviewToFront:_pickerView];
    [_pickerView reloadAllComponents];
    [UIView animateWithDuration:.5 animations:^{
        _pickerView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - CGRectGetHeight(_pickerView.frame), _pickerView.bounds.size.width, _pickerView.bounds.size.height);
    }];
}
- (void)hidePickerView
{
    [UIView animateWithDuration:.5 animations:^{
        _pickerView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), _pickerView.bounds.size.width, _pickerView.bounds.size.height);
    }];
}
#pragma mark - UIPickerView Delegate and Datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *arry = [_pickerData objectForKey:@"children"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN self.@allKeys",@"label"];
    NSInteger count = [arry filteredArrayUsingPredicate:predicate].count;
    return count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *arry = [_pickerData objectForKey:@"children"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN self.@allKeys",@"label"];
    NSArray *result = [arry filteredArrayUsingPredicate:predicate];
    return [[result objectAtIndex:row] objectForKey:@"label"];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSMutableArray *fields = [NSMutableArray arrayWithArray:[_postDic objectForKey:@"fields"]];
    NSInteger index = [fields indexOfObject:_pickerData];
    
    NSArray *arry = [_pickerData objectForKey:@"children"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN self.@allKeys",@"label"];
    NSArray *result = [arry filteredArrayUsingPredicate:predicate];
    NSDictionary *dic = [result objectAtIndex:row];
    NSString *value = [dic objectForKey:@"value"];
    [[arry lastObject] setObject:value forKey:@"value"];
    [_pickerData setValue:arry forKey:@"children"];
    
    [fields replaceObjectAtIndex:index withObject:_pickerData];
    [_postDic setObject:fields forKey:@"fields"];
    
    [self.configV createViewWithData:_pickerData];
    [self hidePickerView];
}
#pragma mark - multi select tableview
- (void)showTableViewWithData:(NSDictionary *)data
{
    _pickerData = data;
    [_tableView reloadData];
    UIView *folderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    folderView.backgroundColor = [UIColor colorWithWhite:.8 alpha:.5];
    folderView.tag = 1000;
    [self.view addSubview:folderView];
    [self.view bringSubviewToFront:_tableView];
    _tableView.hidden = NO;

}
- (void)hideTabelView
{
    _tableView.hidden = YES;
    UIView *view = [self.view viewWithTag:1000];
    [view removeFromSuperview];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arry = [_pickerData objectForKey:@"children"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN self.@allKeys",@"label"];
    NSInteger count = [arry filteredArrayUsingPredicate:predicate].count;
    return count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    NSArray *arry = [_pickerData objectForKey:@"children"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN self.@allKeys",@"label"];
    NSArray *result = [arry filteredArrayUsingPredicate:predicate];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.row >= result.count) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        btn.frame = CGRectMake(10, 0, tableView.bounds.size.width - 20, 40);
        [btn addTarget:self action:@selector(sureButtonTaped) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
    }else{
        cell.textLabel.text = [[result objectAtIndex:indexPath.row] objectForKey:@"label"];

    }
    
    return cell;
}

- (void)sureButtonTaped
{
    NSMutableArray *fields = [NSMutableArray arrayWithArray:[_postDic objectForKey:@"fields"]];
    NSInteger index = [fields indexOfObject:_pickerData];
    
    NSArray *arry = [_pickerData objectForKey:@"children"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN self.@allKeys",@"label"];
    NSArray *result = [arry filteredArrayUsingPredicate:predicate];
    
    NSArray *array = [_tableView indexPathsForSelectedRows];

    NSMutableArray *selectValue = [NSMutableArray array];
    for (NSIndexPath *path in array) {
        NSString *valueStr = [[result objectAtIndex:path.row] objectForKey:@"value"];
        [selectValue addObject:@{@"value": valueStr}];
    }
    NSMutableArray *childrenArray = [NSMutableArray arrayWithArray:result];
    [childrenArray addObjectsFromArray:selectValue];
    [_pickerData setValue:childrenArray forKey:@"children"];
    
    [fields replaceObjectAtIndex:index withObject:_pickerData];
    [_postDic setObject:fields forKey:@"fields"];
    [self hideTabelView];
}
@end
