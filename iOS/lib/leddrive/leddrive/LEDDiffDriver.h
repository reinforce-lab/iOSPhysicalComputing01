//
//  LEDDiffDriver.h
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/05.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AudioSocket.h"

@class AudioPHY;

// LED制御ソケット。
// L-ch/R-chに対して、LED2つが正逆の向きに接続しているものとする。
// LED1 は L-ch -> R-chに順方向接続、LED2はその逆にR-ch->L-chに順方向接続しているとする。
// 
// LEDの明るさ制御は、イヤホン端子の出力振幅と、ON期間の2つで行う。
//
// バーストの周期とON時間とその波形は、下図の通り:
//    burstDuration
//   |<--    4    -->|
//   |               |
//   |bustOnDuration |
//   |<- 2 ->|       |
//   |       |       |
//   +-+ +-+ |       +-+ +-+ +-+
//   | | | | |       | | | | | |
// --+ + + + +-------+ + + + + +
//     | | | |         | | | |
//     +-+ +-+         +-+ +-+
//

@interface LEDDiffDriver : AudioSocket

@property (nonatomic, assign, readonly) bool isDriving;

@property (nonatomic, assign, readonly) int samplesForPulse;
@property (nonatomic, assign, readonly) int burstDuration;

@property (nonatomic, assign, readonly) float led1Amplitude;
@property (nonatomic, assign, readonly) float led2Amplitude;

@property (nonatomic, assign, readonly) int led1OnDuration;
@property (nonatomic, assign, readonly) int led2OnDuration;

-(void)setWaveformParameters:(int)samplesForPulse burstDuration:(int)burstDuration;
-(void)setAmplitude:(float)led1Amplitude led2Amplitude:(float)led2Amplitude;
-(void)setDuration:(int)led1OnDuration led2OnDuration:(int)led2OnDuration;
@end
