//
//  ZYTableView.m
//  ZYTableView
//
//  Created by 雨张 on 2018/4/3.
//  Copyright © 2018年 雨张. All rights reserved.
//

#import "ZYTableView.h"
#define IS_CONTEXT_TABLE if(tableView == _contextTable)

#define MAX_CATEGORYCELL_HEIGHT 100
#define MIN_CATEGORYCELL_HEIGHT 40
#define DEFAULT_SECTIONHEADER_HEIGHT 10
#define DEFAULT_SECTIONFOOTER_HEIGHT 0
#define FIT_FLOAT(X,MIN,MAX) (X < MIN ? MIN:(X > MAX ? MAX : X))
@interface ZYTableView()<UITableViewDelegate,UITableViewDataSource>
{
@private
    UITableView * _categoryTable; // 左侧的类别表 只负责显示右侧分组列表的组别
    UITableView * _contextTable;  // 具体的内容table
}
@end
@implementation ZYCategoryCell
-(void)setSelected:(BOOL)selected
{
    self.textLabel.textColor = selected ?[UIColor blackColor] : [UIColor lightGrayColor];
}

@end


static NSString * CATEGORY_CELL_IDENTIFIER = @"CATEGORY_CELL";
static NSString * CONTENT_CELL_IDENTIFIER  = @"CONTENT_CELL";
@implementation ZYTableView
{
    /*
     *  记录上一次 scrollViewDidScroll 触发时的偏移量
     *  ，以便和这次的偏移量做比较 来确定是上滑 还是 下滑
     */
    float _last_offset_y;
    
    
    /*
     * 用来判断是上滑 还是 下滑  true为上滑
     */
    BOOL _isUpScroll;
    
    /*
     * 用来判断 categoryTable是不是第一次 loadData
     * 如果是  需要将第一个cell的textColor 设置为黑色
     */
    BOOL _isCategoryFirstLoad;
    
    /*
     *  用来判断是不是选中 categoryTable中的cell 引起的滚动
     *  如果是 willDisplayHeaderView 和 didEndDisplayingHeaderView 方法直接返回
     */
    BOOL _isSelectedCategoryOperation;
}
-(id)init
{
    if(self = [super init])
    {
        [self initSubview];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initSubview];
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    float viewWidth      = self.frame.size.width;
    float viewHeight     = self.frame.size.height;
    _categoryTable.frame = CGRectMake(0, 0, viewWidth * _categoryWidthProportion, viewHeight);
    _contextTable.frame  = CGRectMake(viewWidth * _categoryWidthProportion, 0, viewWidth * (1 - _categoryWidthProportion),viewHeight);
}
#pragma mark private method
-(void)initSubview
{
    _isCategoryFirstLoad         = YES;
    _isSelectedCategoryOperation = NO;
    _categoryWidthProportion     = 0.3;
    //////////
    float viewWidth  = self.frame.size.width;
    float viewHeight = self.frame.size.height;
    
    CGRect categoryFrame      = CGRectMake(0, 0, viewWidth * _categoryWidthProportion, viewHeight);
    _categoryTable = [[UITableView alloc] initWithFrame:categoryFrame style:UITableViewStylePlain];
    _categoryTable.dataSource = self;
    _categoryTable.delegate   = self;
    _categoryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _categoryTable.allowsMultipleSelection = NO;
    _categoryTable.showsVerticalScrollIndicator = NO;
    
    CGRect contextFrame = CGRectMake(viewWidth * _categoryWidthProportion, 0, viewWidth * (1-_categoryWidthProportion), viewHeight);
    _contextTable  = [[UITableView alloc] initWithFrame:contextFrame style:UITableViewStylePlain];
    _contextTable.dataSource  = self;
    _contextTable.delegate    = self;
    _contextTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contextTable.showsVerticalScrollIndicator = NO;
    
    [self addSubview:_categoryTable];
    [self addSubview:_contextTable];
}
- (void)selectCategoryRowAtIndexPath:(NSIndexPath*)indexPath
{
    /*
     * 选定一个类别
     */
    NSIndexPath * willUnSelecteIndex = [_categoryTable indexPathForSelectedRow];
    
    /*
     * 如果选取了已选取的类别  不执行任何操作
     */
    if([indexPath isEqual:willUnSelecteIndex])
        return;
    
    UITableViewCell * cell           = [_categoryTable cellForRowAtIndexPath:indexPath];
    [cell setSelected:YES];
    
    
    UITableViewCell * u_cell         = [_categoryTable cellForRowAtIndexPath:willUnSelecteIndex];
    [u_cell setSelected:NO];
    
    [_categoryTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}
#pragma mark Public method
- (nullable __kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    return [_contextTable dequeueReusableCellWithIdentifier:identifier];
}
-(void)reloadData
{
    [_contextTable reloadData];
    [_categoryTable reloadData];
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == _contextTable)
    {
        if(_dataSource && [_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)])
            return [_dataSource numberOfSectionsInTableView:self];
        else
            return 1;
    }
    else
    {
        return 1;
    }
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == _contextTable)
    {
        if(_dataSource && [_dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)])
            return [_dataSource tableView:self titleForHeaderInSection:section];
        return @"";
    }
    else
    {
        return nil;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _contextTable)
    {
        if(_dataSource && [_dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
            return [_dataSource tableView:self numberOfRowsInSection:section];
        else
            return 0;
    }
    else
    {
        if(_dataSource && [_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)])
            return [_dataSource numberOfSectionsInTableView:self];
        else
            return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _contextTable)
    {
        if(_dataSource && [_dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)])
            return [_dataSource tableView:self cellForRowAtIndexPath:indexPath];
        else
        {
            /*
             * 如果代理中没有实现cellFroRowAtIndexPath 则返回一个默认的cell
             */
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CONTENT_CELL_IDENTIFIER];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CONTENT_CELL_IDENTIFIER];
            }
            return cell;
        }
    }
    else
    {
        ZYCategoryCell * cell = [tableView dequeueReusableCellWithIdentifier:CATEGORY_CELL_IDENTIFIER];
        if(cell == nil)
        {
            cell = [[ZYCategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CATEGORY_CELL_IDENTIFIER];
            cell.selectionStyle          = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font          = [UIFont systemFontOfSize:12];
            if(_isCategoryFirstLoad && indexPath.row == 0)
                [cell setSelected:YES];
            else
                [cell setSelected:NO];
            _isCategoryFirstLoad = false;
        }
        if(_dataSource && [_dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)])
            cell.textLabel.text  = [_dataSource tableView:self titleForHeaderInSection:indexPath.row];
        else
            cell.textLabel.text  = @"";
        if(_dataSource && [_dataSource respondsToSelector:@selector(tableView:imageForHeaderInSection:)])
            cell.imageView.image = [_dataSource tableView:self imageForHeaderInSection:indexPath.row];
        else
            cell.imageView.image = nil;
        return cell;
    }
}
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _contextTable)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
            return [_delegate tableView:self heightForRowAtIndexPath:indexPath];
        return 40;
    }
    else
    {
        /*
         * height of category tableview's cell
         */
        float cell_h = self.bounds.size.height / [self numberOfSectionsInTableView:_contextTable];

        /*
         * 为 category cell 设置一个适当的高度值 依据 max_categorycell_height 和 min_categorycell_height
         */
        return FIT_FLOAT(cell_h, MIN_CATEGORYCELL_HEIGHT, MAX_CATEGORYCELL_HEIGHT);
    
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == _contextTable)
    {
        if( [_delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
        {
            return [_delegate tableView:self heightForHeaderInSection:section];
        }
        return DEFAULT_SECTIONHEADER_HEIGHT;
    }
    else
    {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView == _contextTable)
    {
        if([_delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)])
        {
            return [_delegate tableView:self heightForFooterInSection:section];
        }
        return DEFAULT_SECTIONFOOTER_HEIGHT;
    }
    else
    {
        return 0;
    }
}

/*
 * 接下来是 UIScrollviewDelegate 中的方法,在这里实现两个tableView的一些联动
 *
 */
- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _categoryTable)
    {
        _isSelectedCategoryOperation = true;
        [self selectCategoryRowAtIndexPath:indexPath];
        [_contextTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    return indexPath;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if(_isSelectedCategoryOperation)
        return;
    if( _isUpScroll)
        return;
    
    if(tableView == _contextTable)
    {
        NSIndexPath * willSelectIndex = [NSIndexPath indexPathForRow:section inSection:0];
        [self selectCategoryRowAtIndexPath:willSelectIndex];
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if(_isSelectedCategoryOperation)
        return;
    if( !_isUpScroll)
        return;

    if(tableView == _contextTable)
    {
        NSIndexPath * willSelectIndex = [NSIndexPath indexPathForRow:section + 1 inSection:0];
        [self selectCategoryRowAtIndexPath:willSelectIndex];
    }
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _isSelectedCategoryOperation = false;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _isUpScroll    = (scrollView.contentOffset.y > _last_offset_y);
    _last_offset_y = scrollView.contentOffset.y;
}

@end
