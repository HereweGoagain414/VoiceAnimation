//
//  UIView+PopAnimation.m
//  Animation
//
//  Created by dada on 2025/6/22.
//

#import "UIView+PopAnimation.h"

@implementation UIView (PopAnimation)

- (void)showPopAnimationWithDuration:(NSTimeInterval)duration {
    // 保存原始transform
    CGAffineTransform originalTransform = self.transform;
    
    // 设置锚点为视图中心
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    // 初始状态：缩小到0
    self.transform = CGAffineTransformMakeScale(0, 0);
    
    // 执行动画
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        // 恢复到原始大小
        self.transform = originalTransform;
    } completion:nil];
}

@end
