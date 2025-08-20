//
//  VoiceWaveView.m
//  Animation
//
//  Created by dada on 2025/6/22.
//

#import "VoiceWaveView.h"

#define kBarWidth 4.0
#define kBarMargin 2.0
#define kCenterLineHeight 1.0

@implementation VoiceWaveView {
    CADisplayLink *_displayLink;
    NSMutableArray *_topBarLayers;
    NSMutableArray *_bottomBarLayers;
    CGFloat _targetLevel;
    CALayer *_centerLine;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _topBarLayers = [NSMutableArray array];
    _bottomBarLayers = [NSMutableArray array];
    
    CGFloat totalWidth = self.bounds.size.width;
    NSInteger barCount = totalWidth / (kBarWidth + kBarMargin);
    
    // 添加中心线
    _centerLine = [CALayer layer];
    _centerLine.backgroundColor = [UIColor whiteColor].CGColor;
    _centerLine.frame = CGRectMake(0,
                                 self.bounds.size.height/2 - kCenterLineHeight/2,
                                 totalWidth,
                                 kCenterLineHeight);
    [self.layer addSublayer:_centerLine];
    
    for (NSInteger i = 0; i < barCount; i++) {
        // 上方声波条
        CALayer *topBar = [CALayer layer];
        topBar.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.4 alpha:1.0].CGColor;
        topBar.frame = CGRectMake(i * (kBarWidth + kBarMargin),
                                self.bounds.size.height/2,
                                kBarWidth,
                                0);
        topBar.cornerRadius = kBarWidth / 2;
        [self.layer addSublayer:topBar];
        [_topBarLayers addObject:topBar];
        
        // 下方声波条
        CALayer *bottomBar = [CALayer layer];
        bottomBar.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.4 alpha:1.0].CGColor;
        bottomBar.frame = CGRectMake(i * (kBarWidth + kBarMargin),
                                   self.bounds.size.height/2,
                                   kBarWidth,
                                   0);
        bottomBar.cornerRadius = kBarWidth / 2;
        [self.layer addSublayer:bottomBar];
        [_bottomBarLayers addObject:bottomBar];
    }
}

- (void)startAnimating {
    if (_displayLink) return;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateWave)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopAnimating {
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)updateWithLevel:(CGFloat)level {
//    _targetLevel = level;
//    for (NSInteger i = 0; i < _topBarLayers.count; i++) {
//        CALayer *topBar = _topBarLayers[i];
//        CALayer *bottomBar = _bottomBarLayers[i];
//        
//        // 随机高度变化，但保持对称
////        CGFloat randomFactor = 0.5 + (arc4random_uniform(100)/100.0);
//        CGFloat randomFactor = arc4random_uniform(UINT32_MAX) / (CGFloat)UINT32_MAX;  // 0~500整数转0.0~0.5
//
//        CGFloat targetHeight = self.bounds.size.height/2 * _targetLevel * randomFactor;
//        
//        // 更新上方声波条
//        CGFloat currentTopHeight = topBar.bounds.size.height;
//        CGFloat newTopHeight = currentTopHeight + (targetHeight - currentTopHeight) * 0.2;
//        topBar.frame = CGRectMake(topBar.frame.origin.x,
//                                self.bounds.size.height/2 - newTopHeight,
//                                kBarWidth,
//                                newTopHeight);
//        
//        // 更新下方声波条（对称）
//        bottomBar.frame = CGRectMake(bottomBar.frame.origin.x,
//                                   self.bounds.size.height/2,
//                                   kBarWidth,
//                                   newTopHeight);
//    }
}

- (void)updateWave {
    
}

@end
