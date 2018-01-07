//
//  NSObject+MAdd.h
//  Demo_268EDU
//
//  Created by yizhilu on 2017/12/18.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MAdd)

- (void)m_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

//截取整个 tableview 的长图片
-(UIImage *)cutTableView:(UITableView *)view;
//截取指定 size 大小的视图
- (UIImage *)screenShot:(UIView *)view withSize:(CGSize)size;
//获得当前视图的图像
- (UIImage *)imageWithView:(UIView *)view frame:(CGRect)frame;
/*
 *slaveImage   从图片，拼接在masterImage的下面
 *masterImage  主图片，生成的图片的宽度为masterImage的宽度
 */
- (UIImage *)addSlaveImage:(UIImage *)slaveImage toMasterImage:(UIImage *)masterImage;



@end


