//
//  ViewController.m
//  ZYTableView
//
//  Created by 雨张 on 2018/4/3.
//  Copyright © 2018年 雨张. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ZYTableView * table = [[ZYTableView alloc] init];
    float screen_width  = [UIScreen mainScreen].bounds.size.width;
    float screen_height = [UIScreen mainScreen].bounds.size.height;
    table.frame      = CGRectMake(0, 0,screen_width ,screen_height);
    table.delegate   = self;
    table.dataSource = self;
    [self.view addSubview:table];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate
- (void)tableView:(ZYTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"section = %d,row = %d",indexPath.section,indexPath.row);
}
- (CGFloat)tableView:(ZYTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (CGFloat)tableView:(ZYTableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 18;
}
- (CGFloat)tableView:(ZYTableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(ZYTableView *)tableView
{
    return 10;
}
- (NSString*) tableView:(ZYTableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"section = %ld",section];
}
- (nullable UIImage  *)tableView:(ZYTableView *)tableView imageForHeaderInSection
                                   :(NSInteger)section
{
    if(section == 0 || section == 1)
        return [UIImage imageNamed:@"icon"];
    else
        return nil;
}
- (NSInteger)tableView:(ZYTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
- (UITableViewCell *)tableView:(ZYTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"CELL_IDENTIFIER";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell                = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text     = [NSString stringWithFormat:@"row = %ld",indexPath.row];
    return cell;
}

@end
