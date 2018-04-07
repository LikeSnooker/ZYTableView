//
//  ZYTableView.h
//  ZYTableView
//
//  Created by 雨张 on 2018/4/3.
//  Copyright © 2018年 雨张. All rights reserved.
//

/*
 *  美团外卖订单页面的效果，左侧是类别tableView 右侧是内容tableView,因为左侧tableView的数据其实就是右侧
 *  tableView 的section title，因此这里将两个tableView封装到一起，通过一套代理来实现数据获得
 */
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class ZYTableView;
@protocol ZYTableViewDataSource<NSObject>
@required
- (NSInteger)          tableView:(ZYTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSInteger)          numberOfSectionsInTableView:(ZYTableView *)tableView;
- (UITableViewCell *)  tableView:(ZYTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSString *)tableView:(ZYTableView *)tableView titleForHeaderInSection
                                   :(NSInteger)section;
- (nullable UIImage  *)tableView:(ZYTableView *)tableView imageForHeaderInSection
                                   :(NSInteger)section;

@end
@protocol ZYTableViewDelegate<NSObject>
@required
- (CGFloat)tableView:(ZYTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (CGFloat)tableView:(ZYTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(ZYTableView *)tableView heightForFooterInSection:(NSInteger)section;
@end

@interface ZYCategoryCell:UITableViewCell
@end

@interface ZYTableView : UIView
/*
 *  dataSource为 _contextTable提供内容, _categoryTable的内容依托于_contexTable
 *  所以我们没有必要提供两个dataSource
 */

/*
 *  左侧类别 view 占 整个 view 的比例，默认被设置为0.3
 */
@property (nonatomic,assign) float                     categoryWidthProportion;
@property (nonatomic,assign) id<ZYTableViewDataSource> dataSource;
@property (nonatomic,assign) id<ZYTableViewDelegate>   delegate;

-(void)reloadData;
- (nullable __kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
@end
