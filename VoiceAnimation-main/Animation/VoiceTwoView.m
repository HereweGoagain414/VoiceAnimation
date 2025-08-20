//
//  VoiceTwoView.m
//  Animation
//
//  Created by dada on 2025/8/18.
//

#import "VoiceTwoView.h"
@interface VoiceTwoView()
{
  CGFloat lineWidth;
  CGFloat lineMargin;
  NSInteger lineNum;
  CGFloat offsetX;
  CGFloat voiceValue;
}

@property(nonatomic, strong)UIBezierPath *levelPath;

@property(nonatomic, strong)CAShapeLayer *shapeLayer;

// 在类扩展中声明属性
@property (nonatomic, strong) NSMutableArray<NSNumber *> *activeEnergies;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *activePositions;
@property (nonatomic, assign) CGFloat decayRate;  // 能量衰减率

// 平滑动画参数
@property (nonatomic, strong) NSMutableArray<NSNumber *> *currentAmplitudes;
@property (nonatomic, assign) CFTimeInterval lastUpdateTime;


// 下一波次激活因子
@property (nonatomic, strong) NSMutableArray<NSNumber *> *nextActivePositions;
@property (nonatomic, assign) CFTimeInterval transitionProgress;

@end

@implementation VoiceTwoView
- (CGSize)intrinsicContentSize{
  return CGSizeMake(300, 40);
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
      
      [self setupWaveParams];
    
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
    lineWidth = 3;
    lineMargin = 2;
    lineNum = 37;
    offsetX = 0;
    voiceValue = 0.8;
    _decayRate = 0.75;  // 每帧衰减15%的能量
    
    _activeEnergies = [NSMutableArray array];
    _activePositions = [NSMutableArray array];
    _currentAmplitudes = [NSMutableArray array];
    _nextActivePositions = [NSMutableArray array];
    _transitionProgress = 0;
    
    // 初始化振幅数组
    for (int i = 0; i < lineNum; i++) {
        [_currentAmplitudes addObject:@(0.0)];
    }
    
    // 初始生成4个激活因子
    for (int i = 0; i < 4; i++) {
        [self generateNewActiveFactor];
    }
    
    // 预生成下一波次激活因子
    [self prepareNextWave];
}

// 生成新的激活因子
- (void)generateNewActiveFactor {
    // 随机位置 (0-36)
//    NSInteger newPos = arc4random_uniform(37);
//    [self.activePositions addObject:@(newPos)];
//    [self.activeEnergies addObject:@(1.0)];  // 初始能量为1.0
    
    // 确保激活因子不会太靠近边界
    NSInteger newPos = arc4random_uniform(lineNum - 4) + 2;
    [self.activePositions addObject:@(newPos)];
    // 初始能量为1.0
    [self.activeEnergies addObject:@(1.0)];
    
}
- (void)prepareNextWave {
    [self.nextActivePositions removeAllObjects];
    // 生成4-6个新激活因子
    NSInteger count = 4 + arc4random_uniform(3);
    for (int i = 0; i < count; i++) {
        // 确保新因子不会与当前因子太接近
        NSInteger newPos;
        BOOL validPosition;
        int attempts = 0;
        
        do {
            validPosition = YES;
            newPos = arc4random_uniform(lineNum - 4) + 2;
            attempts++;
            
            // 检查是否与当前激活因子太接近
            for (NSNumber *pos in self.activePositions) {
                if (labs([pos integerValue] - newPos) < 3) {
                    validPosition = NO;
                    break;
                }
            }
            
            // 检查是否与已生成的下一波次因子太接近
            for (NSNumber *pos in self.nextActivePositions) {
                if (labs([pos integerValue] - newPos) < 3) {
                    validPosition = NO;
                    break;
                }
            }
            
            // 防止无限循环
            if (attempts > 20) {
                validPosition = YES;
                break;
            }
        } while (!validPosition);
        
        [self.nextActivePositions addObject:@(newPos)];
    }
}
- (void)reset{
    [self.activeEnergies removeAllObjects];
    [self.activePositions removeAllObjects];
    
    // 重置振幅
    for (int i = 0; i < _currentAmplitudes.count; i++) {
        _currentAmplitudes[i] = @(0.0);
    }
    
    // 重新生成激活因子
    for (int i = 0; i < 5; i++) {
        [self generateNewActiveFactor];
    }
    
    [self prepareNextWave];
}

- (void)setColor:(UIColor*)colcor{
  self.shapeLayer.strokeColor = colcor.CGColor;
}

- (void)inputDbValue:(float)height{
    voiceValue = height;
    if (voiceValue < 0.49) {
        voiceValue = 0;
    }
    NSLog(@"height%f",height);
    
    CFTimeInterval currentTime = CACurrentMediaTime();
        CFTimeInterval elapsed = currentTime - self.lastUpdateTime;
        self.lastUpdateTime = currentTime;
        
        // 更新过渡进度
        _transitionProgress += elapsed * 2.0; // 加快过渡速度
        if (_transitionProgress > 1.0) {
            _transitionProgress = 0;
            
            // 切换到下一波次
            [self.activePositions removeAllObjects];
            [self.activeEnergies removeAllObjects];
            
            for (NSNumber *pos in self.nextActivePositions) {
                [self.activePositions addObject:pos];
                [self.activeEnergies addObject:@(1.0)];
            }
            
            // 准备新的下一波次
            [self prepareNextWave];
        }
    
    [self drawWaveLayer];
}

- (void)drawWaveLayer {
    CGFloat height = self.intrinsicContentSize.height;
    CGFloat width = self.intrinsicContentSize.width;
    CGFloat F = voiceValue * height / 2.0;
    CGFloat left = (width - lineNum*lineWidth - (lineNum-1)*lineMargin)/2.0;
//    offsetX += (lineWidth + lineMargin);
    offsetX += 0.3;
    if (offsetX > M_PI * 2) offsetX = 0;

    // 1. 更新激活因子能量系统
    NSMutableIndexSet *expiredIndices = [NSMutableIndexSet indexSet];
    for (int i = 0; i < self.activeEnergies.count; i++) {
        CGFloat newEnergy = [self.activeEnergies[i] floatValue] * _decayRate;
//        self.activeEnergies[i] = @(newEnergy);

        // 标记需要替换的能量枯竭因子
        if (newEnergy < 0.1) {
            [expiredIndices addIndex:i];
        }else {
            self.activeEnergies[i] = @(newEnergy);
        }
    }

    // 替换已耗尽的激活因子
    [expiredIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self.activePositions removeObjectAtIndex:idx];
        [self.activeEnergies removeObjectAtIndex:idx];
        [self generateNewActiveFactor];
    }];
    
    // 2. 计算目标振幅系数
   CGFloat targetAmplitudes[lineNum];
   memset(targetAmplitudes, 0, sizeof(CGFloat) * lineNum);
    
    // 3. 计算激活区域振幅系数
    for (int factorIdx = 0; factorIdx < self.activePositions.count; factorIdx++) {
        NSInteger center = [self.activePositions[factorIdx] integerValue];
        CGFloat energy = [self.activeEnergies[factorIdx] floatValue];

        // 设置5个连续波形的振幅系数 (center-2到center+2)
        for (NSInteger offset = -2; offset <= 2; offset++) {
            NSInteger pos = center + offset;
            if (pos < 0 || pos >= lineNum) continue;
            CGFloat positionFactor = 0.0;
            NSInteger absOffset = labs(offset);
            
            if (absOffset == 0) {
                positionFactor = 1.0; // 中位 (最高)
            } else if (absOffset == 1) {
                positionFactor = 0.6; // 次位 (中等)
            } else if (absOffset == 2) {
                positionFactor = 0.3; // 末位 (最低)
            }

            CGFloat finalFactor = energy * positionFactor;
            // 取最大值，因为可能有多个激活因子影响同一个波形
            if (finalFactor > targetAmplitudes[pos]) {
                targetAmplitudes[pos] = finalFactor;
            }
        }
    }
    // 3. 预计算下一波次的振幅（用于平滑过渡）
        if (_transitionProgress > 0.5) {
            CGFloat nextTargetAmplitudes[lineNum];
            memset(nextTargetAmplitudes, 0, sizeof(CGFloat) * lineNum);
            
            for (NSNumber *pos in self.nextActivePositions) {
                NSInteger center = [pos integerValue];
                
                // 离散三段式分布
                for (NSInteger offset = -2; offset <= 2; offset++) {
                    NSInteger pos = center + offset;
                    if (pos < 0 || pos >= lineNum) continue;

                    // 根据偏移量确定振幅等级
                    CGFloat positionFactor = 0.0;
                    NSInteger absOffset = labs(offset);
                    
                    if (absOffset == 0) {
                        positionFactor = 1.2; // 中位 (最高)
                    } else if (absOffset == 1) {
                        positionFactor = 0.6; // 次位 (中等)
                    } else if (absOffset == 2) {
                        positionFactor = 0.3; // 末位 (最低)
                    }

                    // 下一波次的振幅逐渐增强
                    CGFloat finalFactor = positionFactor * (_transitionProgress - 0.5) * 2.0;
                    
                    // 取最大值
                    if (finalFactor > nextTargetAmplitudes[pos]) {
                        nextTargetAmplitudes[pos] = finalFactor;
                    }
                }
            }
            
            // 合并当前和下一波次的振幅
            for (int i = 0; i < lineNum; i++) {
                if (nextTargetAmplitudes[i] > targetAmplitudes[i]) {
                    targetAmplitudes[i] = nextTargetAmplitudes[i];
                }
            }
        }
    
    // 3. 平滑过渡到目标振幅
    CGFloat smoothingFactor = 0.45; // 平滑因子
    for (int i = 0; i < lineNum; i++) {
        CGFloat current = [_currentAmplitudes[i] floatValue];
        CGFloat target = targetAmplitudes[i];
        
        // 指数平滑：current = current + smoothingFactor * (target - current)
        CGFloat newAmplitude = current + smoothingFactor * (target - current);
        _currentAmplitudes[i] = @(newAmplitude);
    }

    // 4. 绘制所有波形
    self.levelPath = [UIBezierPath bezierPath];
    for (int i = 0; i < lineNum; i++) {
        CGFloat x = left + i * (lineWidth + lineMargin);
        CGFloat amplitudeFactor = [_currentAmplitudes[i] floatValue];
        CGFloat baseH = F * sin(x * 0.5 + offsetX);

        // 应用激活因子振幅系数
        CGFloat pulseH = baseH * amplitudeFactor * 2;
        CGFloat minHeight = 3.0;
        CGFloat maxHeight = height * 1.2;
        CGFloat pathH = fabs(pulseH);
        pathH = MAX(minHeight, MIN(pathH, maxHeight));

        CGFloat centerY = height/2.0;
        CGFloat startY = centerY - pathH/2.0;
        CGFloat endY = centerY + pathH/2.0;

        [self.levelPath moveToPoint:CGPointMake(x, startY)];
        [self.levelPath addLineToPoint:CGPointMake(x, endY)];
    }
    
    // 5. 添加路径动画
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = 0.05;
    pathAnimation.fromValue = (__bridge id)self.shapeLayer.path;
    pathAnimation.toValue = (__bridge id)self.levelPath.CGPath;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    self.shapeLayer.path = self.levelPath.CGPath;
    [self.shapeLayer addAnimation:pathAnimation forKey:@"pathAnimation"];
}

@end
