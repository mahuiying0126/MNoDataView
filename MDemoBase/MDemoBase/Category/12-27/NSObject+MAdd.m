//
//  NSObject+MAdd.m
//  Demo_268EDU
//
//  Created by yizhilu on 2017/12/18.
//  Copyright © 2017年 Magic. All rights reserved.
//
/**
 *关于自动移除KVO 详见网址
 *https://mp.weixin.qq.com/s/NdPgtpBHL7h8sqN-rui_LA
 **/
#import "NSObject+MAdd.h"
#import <objc/runtime.h>
@interface MObserverHelper : NSObject

@property (nonatomic, unsafe_unretained) id target;

@property (nonatomic, unsafe_unretained) id observer;

@property (nonatomic, strong) NSString *keyPath;

@property (nonatomic, weak) MObserverHelper *factor;

@end

@implementation MObserverHelper

- (void)dealloc {
    
    if ( _factor ) {
        
        [_target removeObserver:_observer forKeyPath:_keyPath];
        
    }
    
}

@end

@implementation NSObject (MAdd)


-(void)m_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    
    MObserverHelper *helper = [MObserverHelper new];
    
    MObserverHelper *sub = [MObserverHelper new];
    
    sub.target = helper.target = self;
    
    sub.observer = helper.observer = observer;
    
    sub.keyPath = helper.keyPath = keyPath;
    
    helper.factor = sub;
    
    sub.factor = helper;
    
    const char *helpeKey = [NSString stringWithFormat:@"%zd", [observer hash]].UTF8String;
    
    objc_setAssociatedObject(self, helpeKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(observer, helpeKey, sub, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIImage *)cutTableView:(UITableView *)view{
    UIImage* image = nil;
    UIGraphicsBeginImageContextWithOptions(view.contentSize, YES, 0.0);
    
    //保存当前的偏移量
    CGPoint savedContentOffset = view.contentOffset;
    CGRect saveFrame = view.frame;
    
    //将的偏移量设置为(0,0)
    view.contentOffset = CGPointZero;
    view.frame = CGRectMake(0, 0, view.contentSize.width, view.contentSize.height);
    
    //在当前上下文中渲染出
    [view.layer renderInContext: UIGraphicsGetCurrentContext()];
    //截取当前上下文生成Image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    //恢复的偏移量
    view.contentOffset = savedContentOffset;
    view.frame = saveFrame;
    
    UIGraphicsEndImageContext();
    
    if (image != nil) {
        return image;
    }else {
        return nil;
    }
    
}
- (UIImage *)screenShot:(UIView *)view withSize:(CGSize)size {
    UIImage* image = nil;
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [view.layer renderInContext: UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    if (image != nil) {
        return image;
    }else {
        return nil;
    }
}

//获得某个范围内的屏幕图像
- (UIImage *)imageWithView:(UIView *)view frame:(CGRect)frame{
    

    UIImage * image = [self screenShot:view withSize:view.frame.size];

    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= frame.origin.x*scale,y=frame.origin.y*scale,w=frame.size.width*scale,h=frame.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    return newImage;
    
}

//将两张图片拼接在一起，第二张图片拼接在第一张图的下面。
- (UIImage *)addSlaveImage:(UIImage *)slaveImage toMasterImage:(UIImage *)masterImage {
    CGSize size;
    size.width = masterImage.size.width;
    size.height = masterImage.size.height + slaveImage.size.height;
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    
    //Draw masterImage
    [masterImage drawInRect:CGRectMake(0, 0, masterImage.size.width, masterImage.size.height)];
    
    //Draw slaveImage
    [slaveImage drawInRect:CGRectMake(0, masterImage.size.height, masterImage.size.width, slaveImage.size.height)];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return resultImage;
}



@end
