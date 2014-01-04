//
//  AudioSocket.h
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/07.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

//オーディオインタフェースの基底クラスです。
//L/Rチャネルのオーディオインタフェースの駆動およびマイクモニタを提供します

//オーディオインタフェースの制御を実装するには、このクラスを継承します。
//継承クラスが実装してもよいのは、AudioPHYDelegateおよびAudioBufferDelegateプロトコルに宣言されたメッセージです。
//これらのクラスはAudioSocketクラスでは定義されていません。superを呼び出す必要はありません。

// AudioRouteの扱い
// AudioSessionのルートは、4極の純正ヘッドフォンでは”HeadsetInOut"、3極イヤホンでは”HeadphonesAndMicrophone"。
// このLEDドライバは、マイク端子がない場合でも、LEDを駆動する。故に。4極および3極でもイヤホンが接続されたことを検出する。
// また、マイク端子が有効か否かを、HeadsetInOutなら有効、それ以外は無効、で判定する。

// interface to AudioPHY
@protocol AudioPHYDelegate
@optional
-(void)outputVolumeChanged:(float)volume;
-(void)jackInOutChanged:(BOOL)isJackIn;
-(void)audioSessionInterrupted:(BOOL)isInterrupted;
@end

// interface to Audio buffer
@protocol AudioBufferDelegate
@optional
//-(void)demodulate:(UInt32)length buf:(AudioUnitSampleType *)buf;
-(void)modulate:(UInt32)length leftBuf:(AudioUnitSampleType *)leftBuf rightBuf:(AudioUnitSampleType *)rightBuf;
@end

@interface AudioSocket : NSObject<AudioBufferDelegate, AudioPHYDelegate>

// ユーザの設定音量。音量制限がONになっている場合は、その制限範囲での最大値
@property(nonatomic, assign, readonly) float outputVolume;
@property(nonatomic, assign, readonly) BOOL  isJackIn;
@property(nonatomic, assign, readonly) BOOL  isInterrupted;

@property(nonatomic, assign, readonly) BOOL isRunning;

-(id)initWithParameters:(int)audioBufferSize;
   
-(void) start;
-(void) stop;
@end
