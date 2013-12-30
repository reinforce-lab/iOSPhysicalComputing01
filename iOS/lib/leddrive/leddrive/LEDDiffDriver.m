//
//  LEDDiffDriver.m
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/05.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "LEDDiffDriver.h"

#define SAMPLING_RATE      44100
#define AUDIOI_BUFFER_SIZE 1024

@interface LEDDiffDriver() {
    bool isWarningShown_;
    int wrtPos_;    
    int bufLen_;
    AudioUnitSampleType *lchBuf_;
    AudioUnitSampleType *rchBuf_;
}

// properties enabed to write in this class
@property (nonatomic, assign) bool isDriving;

@property (nonatomic, assign) int samplesForPulse;
@property (nonatomic, assign) int burstDuration;

@property (nonatomic, assign) float led1Amplitude;
@property (nonatomic, assign) float led2Amplitude;

@property (nonatomic, assign) int led1OnDuration;
@property (nonatomic, assign) int led2OnDuration;

// isDrivingプロパティの更新
-(void)updateIsDriving;
-(void)updateWaveform;
@end

@implementation LEDDiffDriver

#pragma mark - Properties
@synthesize isDriving;

@synthesize samplesForPulse;
@synthesize burstDuration;

@synthesize led1Amplitude;
@synthesize led2Amplitude;

@synthesize led1OnDuration;
@synthesize led2OnDuration;

#pragma mark - Varidator
-(BOOL)validatelchAmplitude:(id *)ioValie error:(NSError **)outError 
{
//    NSLog(@"%s", __func__);
    /*
    if(*ioValie == nil) { 
        // trap this in setNilValueForKey
        // alternative might be to create new NSNumber with value 0 here
        return YES;
    }*/
    return YES;
/*    if([*ioValie intValue] 
 if (outError != NULL) {
 NSString *errorString = NSLocalizedStringFromTable(
 @"A Person's name must be at least two characters long", @"Person",
 @"validation: too short name error");
 NSDictionary *userInfoDict =
 [NSDictionary dictionaryWithObject:errorString
 forKey:NSLocalizedDescriptionKey];
 *outError = [[[NSError alloc] initWithDomain:PERSON_ERROR_DOMAIN
 code:PERSON_INVALID_NAME_CODE
 userInfo:userInfoDict] autorelease];
 }*/
}

#pragma mark - Constructor
-(id)init
{
    self = [super init];
    if(self) {
        // バッファの確保と初期化
        [self setWaveformParameters:1 burstDuration:256];

        led1Amplitude  = 1.0;
        led2Amplitude  = 1.0;
        led1OnDuration = 0;
        led2OnDuration = 0;
        [self updateWaveform];
    }
    return self;
}
-(void)dealloc
{
    [self stop]; 
    if(bufLen_ > 0) {
        bufLen_ = 0;
        free(lchBuf_);
        free(rchBuf_);
    }
}
#pragma mark - Private methods
// isDrivingの値更新。出力ON指示がでていて、かつヘッドセットが挿入されている間のみ、LED駆動を出力する
-(void)updateIsDriving
{
    self.isDriving = self.isRunning && self.isJackIn;
}
-(void)updateWaveform
{    
    @synchronized(self) {
        // zero clear
        memset(lchBuf_, 0, sizeof(AudioUnitSampleType) * bufLen_);
        memset(rchBuf_, 0, sizeof(AudioUnitSampleType) * bufLen_);
    
        // set 1st LED
        AudioUnitSampleType pamp = (AudioUnitSampleType)(led1Amplitude * (float)((1 << kAudioUnitSampleFractionBits) ));
        AudioUnitSampleType mamp = -1 * pamp;
    
        const int s = samplesForPulse;
        int d = led1OnDuration;
        
        for(int i=0; i < d; i++) {
            for(int j= 0; j < s; j++) {
                lchBuf_[2 * s * i + j] = pamp;
                rchBuf_[2 * s * i + j] = mamp;
            }
        }
    
        // set 2nd LED
        pamp = -1 * (AudioUnitSampleType)(led2Amplitude * (float)((1 << kAudioUnitSampleFractionBits) ));
        mamp = -1 * pamp;
        
        d = led2OnDuration;
        for(int i=0; i < d; i++) {
            for(int j= s; j < 2 * s; j++) {
                lchBuf_[2 * s * i + j] = pamp;
                rchBuf_[2 * s * i + j] = mamp;
            }
        }
    }
    /*
    for(int i=0; i < bufLen_; i++) {
        NSLog(@"%d %ld %ld", i, lchBuf_[i] , rchBuf_[i]);
    } */
}

#pragma mark - Public methods
-(void)start
{
//    NSLog(@"%s", __func__);
    [super start];
    [self updateIsDriving];
    
    if(! isWarningShown_) {
        isWarningShown_ = YES;
        // 警告をUI表示する
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"警告"
                              message:@"これはLED制御実験ソフトです。\n適切な知識と指導の元で行なってください。\n特に光過敏性発作等の危険性への配慮が必要です。"
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)stop
{
//    NSLog(@"%s", __func__);
    [super stop];
    [self updateIsDriving];
}
-(void)setWaveformParameters:(int)samples burstDuration:(int)dur
{
    self.samplesForPulse = samples;    
    self.burstDuration   = dur;    

    // パラメータ初期化
    self.led1Amplitude  = 1.0;
    self.led2Amplitude  = 1.0;
    self.led1OnDuration = 0;
    self.led2OnDuration = 0;
    
    // バッファの再割当て (同期処理)
    @synchronized(self) {
        if(bufLen_ > 0) {
            free(lchBuf_);
            free(rchBuf_);
        }
        
        wrtPos_ = 0;
        bufLen_ = 2 * samplesForPulse * burstDuration;
        lchBuf_ = calloc(bufLen_, sizeof(AudioUnitSampleType));
        rchBuf_ = calloc(bufLen_, sizeof(AudioUnitSampleType));
    }
}
-(void)setAmplitude:(float)a1 led2Amplitude:(float)a2
{
    led1Amplitude = a1;
    led2Amplitude = a2;
    [self updateWaveform];
}
-(void)setDuration:(int)d1 led2OnDuration:(int)d2
{
    self.led1OnDuration = d1;
    self.led2OnDuration = d2;
    [self updateWaveform];
}

#pragma mark - AudioPHYDelegate
-(void)outputVolumeChanged:(float)volume
{
//    NSLog(@"%s %1.2f", __func__, volume );
}
-(void)jackInOutChanged:(BOOL)val {
    [self updateIsDriving];
//    NSLog(@"%s %d", __func__, val );
}
-(void)audioSessionInterrupted:(BOOL)isInterrupted {
}


#pragma mark - AudioBufferDelegate
-(void)demodulate:(UInt32)length buf:(AudioUnitSampleType *)buf
{}
-(void)modulate:(UInt32)length leftBuf:(AudioUnitSampleType *)leftBuf rightBuf:(AudioUnitSampleType *)rightBuf
{
//    NSLog(@"modulate isDriving:%d", self.isDriving);    
    if(self.isDriving) {
        @synchronized(self) {
            for(int i=0; i < length; i++) {
                leftBuf[i]  = lchBuf_[wrtPos_];
                rightBuf[i] = rchBuf_[wrtPos_];
                wrtPos_ = (wrtPos_ +1) % bufLen_;
            }            
        }
    } else {
        memset(leftBuf,  0, sizeof(AudioUnitSampleType) * length);
        memset(rightBuf, 0, sizeof(AudioUnitSampleType) * length);        
    }
}
@end