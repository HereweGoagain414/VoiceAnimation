//
//  WaveformView.m
//  Animation
//
//  Created by dada on 2025/7/30.
//

#import "WaveformView.h"

@interface WaveformView() <AVAudioRecorderDelegate>
@property (nonatomic, strong) NSArray<NSNumber *> *factorArray; // 位移因子数组（0-36）
@property (nonatomic, assign) CGFloat offsetX;                  // 波浪偏移量
@property (nonatomic, strong) CADisplayLink *displayLink;       // 刷新定时器
@end

@implementation WaveformView

@end
