//
//  JXFlowView.h
//  JXFlowCollectionView
//
//  Created by 王加祥 on 2017/3/18.
//  Copyright © 2017年 王加祥. All rights reserved.
//  使用瀑布流形式展示内容的控件

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JXFlowViewMarginType) {
    JXFlowViewMarginTypeTop,
    JXFlowViewMarginTypeBottom,
    JXFlowViewMarginTypeLeft,
    JXFlowViewMarginTypeRight,
    JXFlowViewMarginTypeColumn, // 每一列
    JXFlowViewMarginTypeRow // 每一行
};

@class JXFlowView,JXFlowViewCell;


////////////////  数据源方法
@protocol JXFlowViewDataSource <NSObject>

@required

// 返回数据
- (NSUInteger)numberOfCellsInFlowView:(JXFlowView *)flowView;
// 返回单元格
- (JXFlowViewCell *)flowView:(JXFlowView *)flowView cellAtIndex:(NSUInteger)index;

@optional
// 返回一共有多少列
- (NSUInteger)numberOfColumunsInFlowView:(JXFlowView *)flowView;

@end



/////////////////// 代理方法
@protocol JXFlowViewDelegate <NSObject>

@optional
// cell高度
- (CGFloat)flowView:(JXFlowView *)flowView heightAtIndex:(NSUInteger)index;
// 选中cell时调用
- (void)flowView:(JXFlowView *)flowView didSelectAtIndex:(NSUInteger)index;
// 返回间距
- (CGFloat)flowView:(JXFlowView *)flowView marginForType:(JXFlowViewMarginType)type;
@end



/////////////
@interface JXFlowView : UIScrollView
/** 数据源 */
@property (nonatomic,weak) id<JXFlowViewDataSource> jx_dataSource;
/** 代理方法 */
@property (nonatomic,weak) id<JXFlowViewDelegate> jx_delegate;
@end
