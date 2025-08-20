//
//  ViewController.m
//  Animation
//
//  Created by jeremy on 2024/4/17.
//

#import "ViewController.h"
#import "VoiceOneView.h"
#import "VoiceTwoView.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceWaveView.h"
#import "Waver.h"
#import "UIView+PopAnimation.h"
//#include <stdio.h>
//#include <stdlib.h>
//#include <time.h>
#import "WaveformView.h"

@interface ViewController ()<AVAudioRecorderDelegate> {
    
}

@property(nonatomic, strong)CADisplayLink *dbTimer;

//@property (nonatomic, strong)VoiceOneView *waveView;
@property (nonatomic, strong)VoiceTwoView *waveView;

@property(nonatomic, assign)BOOL recorderNo;

@property (nonatomic, strong)AVAudioRecorder *recorder;

@property (nonatomic, strong)WaveformView *waveFromView;


@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
    [self configUI];
    // 设置音频会话
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // 配置录音器
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSDictionary *settings = @{
        AVSampleRateKey: @44100.0,
        AVFormatIDKey: @(kAudioFormatAppleLossless),
        AVNumberOfChannelsKey: @1,
        AVEncoderAudioQualityKey: @(AVAudioQualityHigh)
    };
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:nil];
    self.recorder.delegate = self;
    if (self.recorder) {
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = YES;
        [self.recorder record];
    }else {
        NSLog(@"%@",error.description);
    }
    
  
}
- (void)configUI {
    UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionBtn setFrame:CGRectMake(100, 100, 150, 50)];
    [actionBtn setTitle:@"开始收音" forState:UIControlStateNormal];
    [actionBtn setTitle:@"停止收音" forState:UIControlStateSelected];
    [actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [actionBtn addTarget:self action:@selector(voiceStartOrStop:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:actionBtn];
    
      
    self.waveView = [[VoiceTwoView alloc] initWithFrame:CGRectMake(20, 200, self.view.bounds.size.width - 40, 100)];
    self.waveView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.waveView];
    
    self.view.backgroundColor = UIColor.blackColor;
    
//    self.waveFromView = [[WaveformView alloc] initWithFrame:CGRectMake(20, 200, self.view.bounds.size.width - 40, 100)];
//    self.waveFromView.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:self.waveFromView];
//
//    self.view.backgroundColor = UIColor.blackColor;
    
//    Waver * waver = [[Waver alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)/2.0 - 50.0, CGRectGetWidth(self.view.bounds), 100.0)];
//    
//    __block AVAudioRecorder *weakRecorder = self.recorder;
//    
//    waver.waverLevelCallback = ^(Waver * waver) {
//        
//        [weakRecorder updateMeters];
//        
//        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / 40);
//        
//        waver.level = normalizedValue;
//        
//    };
//    [self.view addSubview:waver];
    
}

- (void)voiceStartOrStop:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
//        [self.waveView showPopAnimationWithDuration:0.5];
        self.recorderNo = YES;
        self.dbTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(levelTimerCallback:)];
        self.dbTimer.preferredFramesPerSecond = 30;
        [self.dbTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }else {
        self.recorderNo = NO;
        self.dbTimer.paused = YES;
        [self.waveView reset];
    }
}

- (void)levelTimerCallback:(CADisplayLink *)timer {

    [self.recorder updateMeters];
    
    float level;
    float minDecibels = -60.0f;
    float decibels = [self.recorder averagePowerForChannel:0];
    
    if (decibels< minDecibels) {
        level = 0.0f;
    }else if (decibels >= 0.0f){
        level = 1.0f;
    }else {
        float root = 5.0f;
        float minAmp = powf(10.0f, 0.05f * minDecibels);
        float inverseAmpRange = 1.0f / (1.0f - minAmp);
        float amp             = powf(10.0f, 0.05f * decibels);
        float adjAmp          = (amp - minAmp) * inverseAmpRange;
        level = powf(adjAmp, 1.0f / root);
    }
    if (!self.recorderNo) {
        level = 0.0;
    }
    /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
       dispatch_async(dispatch_get_main_queue(), ^{
           NSLog(@"voice updated :%f",level * 120);
           [self.waveView inputDbValue:level];
       });
}

@end
