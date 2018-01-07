//
//  UITableView+MAdd.m
//  Demo_268EDU
//
//  Created by yizhilu on 2017/12/26.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "UITableView+MAdd.h"
#import <objc/runtime.h>
#import "NSObject+MAdd.h"
@protocol MTableViewDelegate <NSObject>

@optional
- (UIView *)m_noDataView; //完全自定义占位图
- (UIImage *)m_noDataViewImage; //使用默认占位图, 提供一张图片,    可不提供, 默认不显示
- (NSString *)m_noDataViewMessage; //使用默认占位图, 提供显示文字,    可不提供, 默认为暂无数据
- (UIColor *)m_noDataViewMessageColor; //使用默认占位图, 提供显示文字颜色, 可不提供, 默认为灰色
- (NSNumber *)m_noDataViewCenterYOffset; //使用默认占位图, CenterY 向下的偏移量
@end

@interface UITableView ()
/**
 是否加载完成
 */
@property (nonatomic, assign)  BOOL isInitFinish;

@end

static NSString *MNoDataViewObserveKeyPath = @"frame";

@implementation UITableView (MAdd)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method reloadData = class_getInstanceMethod(self, @selector(reloadData));
        Method m_reloadData = class_getInstanceMethod(self, @selector(m_reloadData));
        method_exchangeImplementations(reloadData, m_reloadData);
        Method delloc = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
        Method m_delloc = class_getInstanceMethod(self, @selector(m_delloc));
        method_exchangeImplementations(delloc, m_delloc);
    });
}

-(void)m_reloadData{
    [self m_reloadData];
    //第一次忽略,不展示占位图
    if (!self.isInitFinish) {
        [self m_havingData:YES];
        self.isInitFinish = YES;
        return;
    }
    //  刷新完成之后检测数据量
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger numberOfSections = [self numberOfSections];
        BOOL havingData = NO;
        for (NSInteger i = 0; i < numberOfSections; i++) {
            if ([self numberOfRowsInSection:i] > 0) {
                havingData = YES;
                break;
            }
        }
        [self m_havingData:havingData];
    });
}

/**
 展示占位图
 */
- (void)m_havingData:(BOOL)havingData{
    //如果创建了自定义的加载图
    BOOL isView = [self.delegate respondsToSelector:@selector(m_noDataView)];
    //判断是否响应图片代理
    BOOL isImg = [self.delegate    respondsToSelector:@selector(m_noDataViewImage)];
    //判断是否响应文字代理
    BOOL isMsg = [self.delegate    respondsToSelector:@selector(m_noDataViewMessage)];
    if (isMsg || isImg || isView) {
        //不需要占位图,移除监听
        if (havingData) {
//            [self freeNoDataViewIfNeeded];
            self.backgroundView = nil;
            return ;
        }
        //如果已经存在,则不需要再次创建
        if (self.backgroundView) {
            return ;
        }
        
        if (isView) {
            self.backgroundView = [self.delegate performSelector:@selector(m_noDataView)];
            return ;
        }
        //使用自带的
        UIImage  *img   = nil;
        NSString *msg   = @"暂无数据";
        UIColor  *color = [UIColor lightGrayColor];
        CGFloat  offset = 0;
        
        //获取图片
        if (isImg) {
            img = [self.delegate performSelector:@selector(m_noDataViewImage)];
        }
        
        //获取文字
        if (isMsg) {
            msg = [self.delegate performSelector:@selector(m_noDataViewMessage)];
        }
        //获取颜色
        if ([self.delegate      respondsToSelector:@selector(m_noDataViewMessageColor)]) {
            color = [self.delegate performSelector:@selector(m_noDataViewMessageColor)];
        }
        //获取偏移量
        if ([self.delegate        respondsToSelector:@selector(m_noDataViewCenterYOffset)]) {
            offset = [[self.delegate performSelector:@selector(m_noDataViewCenterYOffset)] floatValue];
        }
        if (msg || img) {
            self.backgroundView = [self defaultNoDataViewWithImage:img message:msg color:color offsetY:offset];
        }
    }
    
    
}

/**
 默认的占位图
 */
- (UIView *)defaultNoDataViewWithImage:(UIImage *)image message:(NSString *)message color:(UIColor *)color offsetY:(CGFloat)offset {
    // 计算位置, 垂直居中, 图片默认中心偏上.
    CGFloat sW = self.bounds.size.width;
    CGFloat cX = sW / 2;
    CGFloat cY = self.bounds.size.height * (1 - 0.618) + offset;
    CGFloat iW = image.size.width;
    CGFloat iH = image.size.height;
    
    // 图片
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.frame = CGRectMake(cX - iW / 2, cY - iH / 2, iW, iH);
    imgView.image = image;
    
    //  文字
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = color;
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(0, CGRectGetMaxY(imgView.frame) + 20, sW, label.font.lineHeight);
    
    //  视图
    UIView *view = [[UIView alloc] init];
    [view addSubview:imgView];
    [view addSubview:label];
    
    //  实现跟随 TableView 滚动
//    [view addObserver:self forKeyPath:MNoDataViewObserveKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [view m_addObserver:self forKeyPath:MNoDataViewObserveKeyPath];
    return view;
}
/**
 监听
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:MNoDataViewObserveKeyPath]) {
        
        /**
         在 TableView 滚动 ContentOffset 改变时, 会同步改变 backgroundView 的 frame.origin.y
         可以实现, backgroundView 位置相对于 TableView 不动, 但是我们希望
         backgroundView 跟随 TableView 的滚动而滚动, 只能强制设置 frame.origin.y 永远为 0
         兼容 MJRefresh
         */
        CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        if (frame.origin.y != 0) {
            frame.origin.y  = 0;
            self.backgroundView.frame = frame;
        }
    }
}

/**
 移除 KVO 监听
 */
//- (void)freeNoDataViewIfNeeded {
//
//    [self.backgroundView removeObserver:self forKeyPath:MNoDataViewObserveKeyPath context:nil];
//
//}

-(void)m_delloc{
//    [self freeNoDataViewIfNeeded];
    [self m_delloc];
}

#pragma mark - 初始化属性

-(void)setIsInitFinish:(BOOL)isInitFinish{
    objc_setAssociatedObject(self, @selector(isInitFinish), @(isInitFinish), OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)isInitFinish{
    return objc_getAssociatedObject(self, _cmd);
}

@end
