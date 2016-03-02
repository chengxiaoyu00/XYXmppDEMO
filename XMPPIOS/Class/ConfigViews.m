//
//  ConfigViews.m
//  XMPPIOS
//
//  Created by my on 14-5-15.
//  Copyright (c) 2014年 Dawn_wdf. All rights reserved.
//

#import "ConfigViews.h"

@implementation ConfigViews

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame data:(NSDictionary *)data callbackBlock:(callbackblock)block
{
    self = [self initWithFrame:frame];
    if (self) {
        _block = block;
        self.dataDic = [NSMutableDictionary dictionaryWithDictionary:data];
        self.clipsToBounds = YES;
        [self createViewWithData:data];
    }
    return self;
}
- (void)createViewWithData:(NSDictionary *)data
{
//    NSLog(@"%@",data);
    self.dataDic = [NSMutableDictionary dictionaryWithDictionary:data];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGRect frame = self.frame;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.numberOfLines = 0;
    [self addSubview:titleLabel];
    NSString *typeStr = [[data objectForKey:@"attributes"] objectForKey:@"type"];
    if ([typeStr isEqualToString:@"hidden"]) {
        self.bounds = CGRectZero;
    }else if([typeStr isEqualToString:@"text-single"]){
        titleLabel.frame = CGRectMake(10, 0, 100, frame.size.height);
        titleLabel.text = [[data objectForKey:@"attributes"] objectForKey:@"label"];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(120, 5, frame.size.width - 130, frame.size.height - 10)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.delegate = self;
        textField.text = [[[data objectForKey:@"children"] lastObject] objectForKey:@"value"];
        [self addSubview:textField];
    }else if([typeStr isEqualToString:@"boolean"]){
        titleLabel.frame = CGRectMake(10, 0, 250, frame.size.height);
        titleLabel.text = [[data objectForKey:@"attributes"] objectForKey:@"label"];
        UISwitch *switchControll = [[UISwitch alloc]initWithFrame:CGRectMake(260, 5, 50, frame.size.height - 10)];
        switchControll.on = [[[[data objectForKey:@"children"] lastObject] objectForKey:@"value"] boolValue];
        [switchControll addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:switchControll];
    }else if([typeStr isEqualToString:@"list-single"]){
        titleLabel.frame = CGRectMake(10, 0, 200, frame.size.height);
        titleLabel.text = [[data objectForKey:@"attributes"] objectForKey:@"label"];
        UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(210, 0, 50, frame.size.height)];
        valueLabel.text = [[[data objectForKey:@"children"]lastObject] objectForKey:@"value"];
        valueLabel.adjustsFontSizeToFitWidth = YES;
        valueLabel.numberOfLines = 0;
        [self addSubview:valueLabel];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(260, 5, 50, frame.size.height - 10);
        [btn setTitle:@"选择" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }else if([typeStr isEqualToString:@"list-multi"]){
        titleLabel.frame = CGRectMake(10, 0, 200, frame.size.height);
        titleLabel.text = [[data objectForKey:@"attributes"] objectForKey:@"label"];
        UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(210, 0, 50, frame.size.height)];
        
        NSArray *arry = [data objectForKey:@"children"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT(%@ IN self.@allKeys)",@"text"];
        NSMutableString *textStr = [NSMutableString string];
        for (NSDictionary *dic in [arry filteredArrayUsingPredicate:predicate]) {
            [textStr appendString:[dic objectForKey:@"value"]];
            [textStr appendString:@","];
        }
        valueLabel.text =textStr;
        valueLabel.adjustsFontSizeToFitWidth = YES;
        valueLabel.numberOfLines = 0;
        [self addSubview:valueLabel];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(260, 5, 50, frame.size.height - 10);
        [btn setTitle:@"选择" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(multiSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

    }else if([typeStr isEqualToString:@"fixed"]){
        titleLabel.frame = CGRectMake(10, 0, frame.size.width - 20, frame.size.height);
        titleLabel.text = [[[data objectForKey:@"children"] objectAtIndex:0] objectForKey:@"value"];
        
    }else if([typeStr isEqualToString:@"text-private"]){
        titleLabel.frame = CGRectMake(10, 0, 200, frame.size.height);
        titleLabel.text = [[data objectForKey:@"attributes"] objectForKey:@"label"];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(120, 5, frame.size.width - 130, frame.size.height - 10)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.delegate = self;
        textField.secureTextEntry = YES;
        if ([data objectForKey:@"children"]) {
            if ([[data objectForKey:@"children"] lastObject] &&  [[[data objectForKey:@"children"] lastObject] objectForKey:@"value"]) {
                textField.text = [[[data objectForKey:@"children"] lastObject] objectForKey:@"value"];
            }
        }
        [self addSubview:textField];
    }else if([typeStr isEqualToString:@"jid-multi"]){
        titleLabel.frame = CGRectMake(10, 0, 200, frame.size.height);
        titleLabel.text = [[data objectForKey:@"attributes"] objectForKey:@"label"];
        UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(210, 0, 50, frame.size.height)];
        valueLabel.text = [[[data objectForKey:@"children"]lastObject] objectForKey:@"value"];
        valueLabel.adjustsFontSizeToFitWidth = YES;
        valueLabel.numberOfLines = 0;
        [self addSubview:valueLabel];
    }
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
    lineLabel.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
    [self addSubview:lineLabel];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)multiSelectBtn:(UIButton *)Btn
{
    self.configVC.configV =self;
    [self.configVC showTableViewWithData:self.dataDic];

}
- (void)selectBtn:(UIButton *)Btn
{
    self.configVC.configV =self;
    [self.configVC showPickerViewWithData:self.dataDic];
}
- (void)switchChanged:(UISwitch *)switchC
{
    NSMutableDictionary *children = [[self.dataDic objectForKey:@"children"] objectAtIndex:0];
    [children setObject:switchC.on?@"1":@"0" forKey:@"value"];
    [self.dataDic setObject:@[children] forKey:@"children"];
    _block(self.dataDic);
}
#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSMutableDictionary *children = [[self.dataDic objectForKey:@"children"] objectAtIndex:0];
    [children setObject:textField.text forKey:@"value"];
    [self.dataDic setObject:@[children] forKey:@"children"];
    _block(self.dataDic);
    [textField resignFirstResponder];
    return YES;
}

@end
