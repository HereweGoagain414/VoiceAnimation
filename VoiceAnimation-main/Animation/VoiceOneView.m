//
//  VoiceOneView.m
//  LoginDemo
//
//  Created by jeremy on 2024/3/27.
//  Copyright © 2024 aqara. All rights reserved.
//

#import "VoiceOneView.h"


@interface VoiceOneView()
{
  CGFloat lineWidth;
  CGFloat lineMargin;
  NSInteger lineNum;
  CGFloat animationDuration;
  CGFloat offsetX;
  CGFloat voiceValue;
}
@property(nonatomic, strong)UIBezierPath *levelPath;

@property(nonatomic, strong)CAShapeLayer *shapeLayer;

// 在类扩展中声明属性
@property (nonatomic, strong) NSMutableArray<NSNumber *> *activeEnergies;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *activePositions;
@property (nonatomic, assign) CGFloat decayRate;  // 能量衰减率


@end

@implementation VoiceOneView


- (CGSize)intrinsicContentSize{
  return CGSizeMake(300, 40);
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
      lineWidth = 3;
      lineMargin = 2;
      lineNum = 37;
      animationDuration = 0.05;
      offsetX = 0;
      voiceValue = 0.8;
      
//      [self setupWaveParams];
    
      CAShapeLayer* levelLayer = [CAShapeLayer layer];
      levelLayer.fillColor = [UIColor whiteColor].CGColor;
      levelLayer.strokeColor = [UIColor whiteColor].CGColor;
      levelLayer.lineWidth = lineWidth;
      levelLayer.lineCap = kCALineCapRound;
      [self.layer addSublayer:levelLayer];
      self.shapeLayer = levelLayer;
    
  }
  return self;
}
// 初始化方法中设置默认值
- (void)setupWaveParams {
    _decayRate = 0.85;  // 每帧衰减15%的能量
    
    // 初始生成4个激活因子
    for (int i = 0; i < 5; i++) {
        [self generateNewActiveFactor];
    }
}

// 生成新的激活因子
- (void)generateNewActiveFactor {
    // 随机位置 (0-36)
    NSInteger newPos = arc4random_uniform(37);
    [self.activePositions addObject:@(newPos)];
    [self.activeEnergies addObject:@(1.0)];  // 初始能量为1.0
    
}

- (void)reset{
    [self.activeEnergies removeAllObjects];
    [self.activePositions removeAllObjects];
}

- (void)setColor:(UIColor*)colcor{
  self.shapeLayer.strokeColor = colcor.CGColor;
}

- (void)inputDbValue:(float)height{
    voiceValue = height;
    if (voiceValue < 0.55) {
        voiceValue = 0;
    }
    NSLog(@"height%f",height);

    [self drawWaveLayer];
}

- (void)drawWaveLayer {

    CGFloat height = self.intrinsicContentSize.height;
    CGFloat width = self.intrinsicContentSize.width;
  
    CGFloat F = voiceValue*height/2.0;
    CGFloat left = (width - lineNum*lineWidth - (lineNum-1)*lineMargin)/2.0;
    offsetX += (lineWidth + lineMargin);
    self.levelPath = [UIBezierPath bezierPath];
    for (int i = 0; i < lineNum; i++) {
      CGFloat x = left + i * (lineWidth + lineMargin);
        CGFloat baseH = F * sin(x * 0.2 + offsetX);
        CGFloat pulseH = 0;
        pulseH = baseH * (arc4random_uniform(100)/100.0);
        CGFloat pathH = fabs(pulseH) + 3;
        CGFloat startY = height/2.0 - pathH/2.0;
        CGFloat endY = height/2.0 + pathH/2.0;
        [self.levelPath moveToPoint:CGPointMake(x, startY)];
        [self.levelPath addLineToPoint:CGPointMake(x, endY)];
    }
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = animationDuration;
    pathAnimation.fromValue = (__bridge id)self.shapeLayer.path;
    pathAnimation.toValue = (__bridge id)self.levelPath.CGPath;
    [self.shapeLayer addAnimation:pathAnimation forKey:@"pathAnimation"];
   self.shapeLayer.path = self.levelPath.CGPath;
    
    //******
    
//    CGFloat height = self.intrinsicContentSize.height;
//        CGFloat width = self.intrinsicContentSize.width;
//        CGFloat F = voiceValue * height / 2.0;
//        CGFloat left = (width - lineNum*lineWidth - (lineNum-1)*lineMargin)/2.0;
//        offsetX += (lineWidth + lineMargin);
//
//        // 1. 更新激活因子能量系统
//        NSMutableIndexSet *expiredIndices = [NSMutableIndexSet indexSet];
//        for (int i = 0; i < self.activeEnergies.count; i++) {
//            CGFloat newEnergy = [self.activeEnergies[i] floatValue] * _decayRate;
//            self.activeEnergies[i] = @(newEnergy);
//            
//            // 标记需要替换的能量枯竭因子
//            if (newEnergy < 0.05) {
//                [expiredIndices addIndex:i];
//            }else {
//                self.activeEnergies[i] = @(newEnergy);
//            }
//        }
//        
//        // 替换已耗尽的激活因子
//        [expiredIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
//            [self.activePositions removeObjectAtIndex:idx];
//            [self.activeEnergies removeObjectAtIndex:idx];
//            [self generateNewActiveFactor];
//        }];
//        
//        // 2. 创建波形路径
//        self.levelPath = [UIBezierPath bezierPath];
//        CGFloat amplitudeFactors[lineNum];  // 存储每个波形的振幅系数
//        
//        // 初始化所有波形为0
//        for (int i = 0; i < lineNum; i++) {
//            amplitudeFactors[i] = 0;
//        }
//        
//        // 3. 计算激活区域振幅系数
//        for (int factorIdx = 0; factorIdx < self.activePositions.count; factorIdx++) {
//            NSInteger center = [self.activePositions[factorIdx] integerValue];
//            CGFloat energy = [self.activeEnergies[factorIdx] floatValue];
//            
//            // 设置5个连续波形的振幅系数 (center-2到center+2)
//            for (NSInteger offset = -2; offset <= 2; offset++) {
//                NSInteger pos = center + offset;
//                if (pos < 0 || pos >= lineNum) continue;
//                
//                // 根据位置确定振幅等级
//                CGFloat positionFactor = (CGFloat)labs(offset)/3.0;
//                if (labs(offset) == 0) {  // 中位 (最高)
//                    positionFactor = 1.5;
//                } else if (labs(offset) == 1) {  // 次位 (中等)
//                    positionFactor = 0.7;
//                } else if (labs(offset) == 2) {  // 末位 (最低)
//                    positionFactor = 0.2;
//                }
//                
//                // 更新振幅系数 (取最大值)
//                CGFloat finalFactor = energy * positionFactor;
//                if (finalFactor > amplitudeFactors[pos]) {
//                    amplitudeFactors[pos] = finalFactor;
//                }
//            }
//        }
//        
//        // 4. 绘制所有波形
//        for (int i = 0; i < lineNum; i++) {
//            CGFloat x = left + i * (lineWidth + lineMargin);
//            CGFloat baseH = F * sin(x * 0.8 + offsetX);
//            
//            // 应用激活因子振幅系数
//            CGFloat pulseH = baseH * amplitudeFactors[i];
//            CGFloat minHeight = 4.0;
//            CGFloat pathH = MAX(fabs(pulseH), minHeight);
////            CGFloat pathH = fabs(pulseH) + 3;  // 保证最小高度
//            
//            CGFloat startY = height/2.0 - pathH/2.0;
//            CGFloat endY = height/2.0 + pathH/2.0;
//            
//            [self.levelPath moveToPoint:CGPointMake(x, startY)];
//            [self.levelPath addLineToPoint:CGPointMake(x, endY)];
//        }
//        
//        // 5. 添加路径动画
//        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
//        pathAnimation.duration = 0.1;
//        pathAnimation.fromValue = (__bridge id)self.shapeLayer.path;
//        pathAnimation.toValue = (__bridge id)self.levelPath.CGPath;
//        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        
//        self.shapeLayer.path = self.levelPath.CGPath;
//        [self.shapeLayer addAnimation:pathAnimation forKey:@"pathAnimation"];
}
- (NSMutableArray<NSNumber *> *)activeEnergies {
    if (!_activeEnergies) {
        _activeEnergies = [[NSMutableArray alloc]init];
    }
    return _activeEnergies;
}
- (NSMutableArray<NSNumber *> *)activePositions {
    if (!_activePositions) {
        _activePositions = [[NSMutableArray alloc]init];
    }
    return _activePositions;
}
@end
