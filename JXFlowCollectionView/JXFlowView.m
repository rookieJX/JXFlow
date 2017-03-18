//
//  JXFlowView.m
//  JXFlowCollectionView
//
//  Created by 王加祥 on 2017/3/18.
//  Copyright © 2017年 王加祥. All rights reserved.
//

#import "JXFlowView.h"
#import "JXFlowViewCell.h"

// 默认的cell高度
#define kJXFlowViewCellDefaultH 100.0f
// 默认cell列数
#define kJXFlowViewDefaultCloumns 3
// 默认间距
#define kJXFlowViewCellDefaultMargin 10.0

@interface JXFlowView ()
/** 每个cell的frame */
@property (nonatomic,strong) NSMutableArray * cellFrames;
/** 正在展示的cell */
@property (nonatomic,strong) NSMutableDictionary * displayCells;
/** 缓存池 */
@property (nonatomic,strong) NSMutableSet * reusableCells;
@end

@implementation JXFlowView

- (void)reloadData {
    // cell总数
    NSInteger cells = [self.jx_dataSource numberOfCellsInFlowView:self];
    
    // cell总列数
    NSInteger columns = [self columns];
    
    // 间距
    CGFloat cellMarignTop = [self cellMarginForType:JXFlowViewMarginTypeTop];
    CGFloat cellMarginBottom = [self cellMarginForType:JXFlowViewMarginTypeBottom];
    CGFloat cellMarignLeft = [self cellMarginForType:JXFlowViewMarginTypeLeft];
    CGFloat cellMarignRight = [self cellMarginForType:JXFlowViewMarginTypeRight];
    CGFloat cellMarignCol = [self cellMarginForType:JXFlowViewMarginTypeColumn];
    CGFloat cellMarignRow = [self cellMarginForType:JXFlowViewMarginTypeRow];
    
    // cell宽度
    CGFloat cellW = (self.frame.size.width - cellMarignLeft - cellMarignRight - (columns - 1) * cellMarignCol) / columns;
    
    // 用一个C代码来存放最大的Y值
    CGFloat maxYOfColumns[columns];
    for (NSInteger i=0; i<columns; i++) {
        maxYOfColumns[i] = 0.0f;
    }
    
    
    for (NSInteger i=0; i<cells; i++) {
        // cell所在列
        NSUInteger cellColumn = 0;
        // cell所在列最大的Y值(默认)
        CGFloat maxYOfCellColums = maxYOfColumns[cellColumn];
        // 计算最短的列数
        for (NSInteger j=1; j<columns; j++) {
            if (maxYOfColumns[j] < maxYOfCellColums) {
                cellColumn = j;
                maxYOfCellColums = maxYOfColumns[j];
            }
            
        }
        CGFloat cellX = cellMarignLeft + (cellW + cellMarignCol) * cellColumn;
        CGFloat cellY = 0;
        if (maxYOfCellColums == 0.0) {
            cellY = cellMarignTop;
        } else {
            cellY = maxYOfCellColums + cellMarignRow;
        }
        CGFloat cellH = [self heightAtIndex:i];
        
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        // 更新最短一列的最大Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
        
        // 取出cell
        JXFlowViewCell *cell = [self.jx_dataSource flowView:self cellAtIndex:i];
        cell.frame = cellFrame;
        [self addSubview:cell];
    }
    
    // 设置contentSize
    CGFloat contentH = maxYOfColumns[0];
    for (NSInteger j=1; j<columns; j++) {
        if (maxYOfColumns[j] > contentH) {
            contentH = maxYOfColumns[j];
        }
        
    }
    contentH += cellMarginBottom;
    self.contentSize = CGSizeMake(0, contentH);
    
}


#pragma mark - 布局
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 根据数据源来返回cell
    NSUInteger numberOfCells = self.cellFrames.count;
    for (NSInteger i=0; i<numberOfCells; i++) {
        CGRect frame = [self.cellFrames[i] CGRectValue];
        
        // 字典中取出cell
        JXFlowViewCell *cell = self.displayCells[@(i)];
        // 判断是否在屏幕上
        if ([self isInScreen:frame]) {
            
            if (cell == nil) { // 如果暂无cell,创建
                cell = [self.jx_dataSource flowView:self cellAtIndex:i];
                cell.frame = frame;
                [self addSubview:cell];
                
                // 存放到字典中
                self.displayCells[@(i)] = cell;
            }
            
        } else {
            
            if (cell) {
                [cell removeFromSuperview];
                [self.displayCells removeObjectForKey:@(i)];
                [self.reusableCells addObject:cell];
            }
        }
        
    }
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)reusal {
    __block JXFlowViewCell *reusablaCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(JXFlowViewCell *cell, BOOL * _Nonnull stop) {
        if ([cell.identifier isEqualToString:reusal]) {
            reusablaCell = cell;
            *stop = YES;
        }
    }];
    
    // 如果存在就移除
    if (reusablaCell) {
        [self.reusableCells removeObject:reusablaCell];
    }
    
    return reusablaCell;
    
}

#pragma mark - 触摸方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (!(self.jx_delegate && [self.jx_delegate respondsToSelector:@selector(flowView:didSelectAtIndex:)])) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    // 遍历当前在屏幕上的控件
    __block NSNumber *selectIndex = nil;
    [self.displayCells enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, JXFlowViewCell *cell, BOOL * _Nonnull stop) {
        // 如果包含点
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    
    if (selectIndex) {
        [self.jx_delegate flowView:self didSelectAtIndex:selectIndex.unsignedIntegerValue];
    }
}
#pragma mark - 私有方法
// 根据一个frame返回是否在屏幕上
- (BOOL)isInScreen:(CGRect)frame {
    return (CGRectGetMaxY(frame) > self.contentOffset.y) &&
    (CGRectGetMaxY(frame) < self.contentOffset.y + self.frame.size.height);
}
// 返回cell高度
- (CGFloat)heightAtIndex:(NSUInteger)index {
    CGFloat cellH = kJXFlowViewCellDefaultH;
    if (self.jx_delegate && [self.jx_delegate respondsToSelector:@selector(flowView:heightAtIndex:)]) {
        cellH = [self.jx_delegate flowView:self heightAtIndex:index];
    }
    return cellH;
}

// 返回总列数
- (NSInteger)columns {
    NSInteger cols = kJXFlowViewDefaultCloumns;
    if (self.jx_dataSource && [self.jx_dataSource respondsToSelector:@selector(numberOfColumunsInFlowView:)]) {
        cols = [self.jx_dataSource numberOfColumunsInFlowView:self];
    }
    return cols;
}

// 返回间距
- (CGFloat)cellMarginForType:(JXFlowViewMarginType)type {
    CGFloat cellMargin = kJXFlowViewCellDefaultMargin;
    if (self.jx_delegate && [self.jx_delegate respondsToSelector:@selector(flowView:marginForType:)]) {
        cellMargin = [self.jx_delegate flowView:self marginForType:type];
    }
    return cellMargin;
}
#pragma mark - 初始化
- (NSMutableArray *)cellFrames{
    if (_cellFrames == nil) {
        _cellFrames = [[NSMutableArray alloc] init];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayCells{
    if (_displayCells == nil) {
        _displayCells = [[NSMutableDictionary alloc] init];
    }
    return _displayCells ;
}

- (NSMutableSet *)reusableCells{
    if (_reusableCells == nil) {
        _reusableCells = [[NSMutableSet alloc] init];
    }
    return _reusableCells;
}
@end
