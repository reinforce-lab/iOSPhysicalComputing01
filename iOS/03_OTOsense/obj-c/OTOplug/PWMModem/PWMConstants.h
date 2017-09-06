//
//  PWMConstants.h
//  SoftwareModem
//
//  Created by UEHARA AKIHIRO on 10/11/28.
//  Copyright 2010 REINFORCE Lab. All rights reserved.
//
#import <Foundation/Foundation.h>
@import AudioToolbox;

#define kSWMSamplingRate    48000.0
#define kSWMSyncCode        0x7e
#define kSWMMaxMark1Length  5

#define kPWMMaxPacketSize  32
#define kPWMMark1Samples1200   40 // 1200bpsでのビットサンプリング数, 48000 / 1200 = 40
#define kPWMMark1Samples2400   20 // 2400bpsでのビットサンプリング数, 48000 / 2400 = 20
//#define kPWMMark0Samples   (kPWMMark1Samples *2)
//#define kPWMBaudRate       (kSWMSamplingRate / kPWMMark1Samples)

// constants for implementation
//#define kPWMSliceLevel (1.0f / 250.0f)
#define kPWMSliceLevel (0.04)

#define kPWMAudioBufferSize 512
//#define kPWMLostCarrierDuration   (kPWMMark0Samples * 1.5)
//#define kPWMPulseWidthThreashold  (kPWMMark1Samples * 1.5)
// number of sync code to re-sync
#define kNumberOfReSyncCode 2
// Modulator can have at leaset 2 packets in its buffer (data0/data1) // バッファ長がより長く必要な1200bpsで定義しておく
#define kMaxSamplingPerByte ((kPWMMark1Samples1200 * 2) * 8 * 1.2) // 1バイトあたりの最悪のサンプリング数。マーク0(長い)のサンプリング数 * 8ビットに、連続する0で5ビットごとの挿入で1.2倍に膨れるとして。
#define kPWMModulatorBufferLength (int)(((kMaxSamplingPerByte * (kNumberOfReSyncCode + kPWMMaxPacketSize)) / kPWMAudioBufferSize +1) * kPWMAudioBufferSize) // パケットあたりのサンプリング数を、オーディオバッファ単位で量子化。

