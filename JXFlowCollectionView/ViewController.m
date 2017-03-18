//
//  ViewController.m
//  JXFlowCollectionView
//
//  Created by 王加祥 on 2017/3/18.
//  Copyright © 2017年 王加祥. All rights reserved.
//

#import "ViewController.h"
#import "JXFlowView.h"
#import "JXFlowViewCell.h"

@interface ViewController ()<JXFlowViewDelegate,JXFlowViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    JXFlowView *flowView = [[JXFlowView alloc] init];
    flowView.jx_delegate = self;
    flowView.jx_dataSource = self;
    flowView.frame = self.view.bounds;
    [self.view addSubview:flowView];
    
    [flowView reloadData];
    
}

/////// 代理方法
- (NSUInteger)numberOfCellsInFlowView:(JXFlowView *)flowView {
    return 100;
}

- (NSUInteger)numberOfColumunsInFlowView:(JXFlowView *)flowView {
    return 4;
}

- (JXFlowViewCell *)flowView:(JXFlowView *)flowView cellAtIndex:(NSUInteger)index {
    static NSString *identifier = @"cell";
    
    JXFlowViewCell *cell = [flowView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[JXFlowViewCell alloc] init];
        cell.identifier = identifier;
    }
    cell.backgroundColor = [UIColor redColor];
    return cell;
}

- (CGFloat)flowView:(JXFlowView *)flowView heightAtIndex:(NSUInteger)index {
    if (index % 3) return 100.0f;
    return 70.0f;
}


- (CGFloat)flowView:(JXFlowView *)flowView marginForType:(JXFlowViewMarginType)type {
    switch (type) {
        case JXFlowViewMarginTypeRow:
            return 10.0f;
            break;
        default:
            return 10.0f;
            break;
    }
}

- (void)flowView:(JXFlowView *)flowView didSelectAtIndex:(NSUInteger)index {
    NSLog(@"点击了--%ld",index);
}
@end
