//
//  VoiceWaveView.h
//  Animation
//
//  Created by dada on 2025/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceWaveView : UIView

- (void)startAnimating;

- (void)stopAnimating;

- (void)updateWithLevel:(CGFloat)level;

@end

NS_ASSUME_NONNULL_END
