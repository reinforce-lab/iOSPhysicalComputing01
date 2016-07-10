//
//  AudioSocket.m
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/07.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "AudioSocket.h"
 #import <AudioToolbox/AudioToolbox.h>

#define kAudioSamplingRate 44100
#define kDefaultAudioBufferSize 1024

@interface AudioSocket() {
    int _bufferSize;
    AVAudioSession *_session;
    AudioUnit _audioUnit;
}

@property(nonatomic, assign) float outputVolume;
@property(nonatomic, assign) BOOL  isJackIn;
@property(nonatomic, assign) BOOL  isMicAvailable;
@property(nonatomic, assign) BOOL  isInterrupted;

@property(nonatomic, assign) BOOL isRunning;

@end

// function declarations
static void sessionPropertyChanged(void *inClientData,
                                   AudioSessionPropertyID inID,
                                   UInt32 inDataSize,
                                   const void *inData);

@implementation AudioSocket
#pragma mark - Constructor
-(id)init
{
    return [self initWithParameters:kDefaultAudioBufferSize];
}
-(id)initWithParameters:(int)audioBufferSize {
    self = [super init];
    if(self) {
        _session = [AVAudioSession sharedInstance];
        _bufferSize = audioBufferSize;
        
        [self prepareAudioSession:_bufferSize];
        [self addSessionObservers];
        [self prepareAudioUnit];
    }
    return  self;
}
-(void)dealloc{
    [self stop];
    [self removeSessionObservers];
    [self disposeAudioUnit];
}
#pragma mark - Public messages
-(void)start
{
	if(!self.isRunning){
		AudioOutputUnitStart(_audioUnit);
        self.isRunning = YES;
	}
}

-(void)stop
{
	if(self.isRunning) {
		AudioOutputUnitStop(_audioUnit);
		self.isRunning = NO;
	}
}

#pragma mark - AudioBufferDelegate
//-(void)demodulate:(UInt32)length buf:(AudioUnitSampleType *)buf {}
-(void)modulate:(UInt32)length leftBuf:(Float32 *)leftBuf rightBuf:(Float32 *)rightBuf {}

#pragma mark - render callback
static OSStatus renderCallback(void * inRefCon,
							   AudioUnitRenderActionFlags* ioActionFlags,
							   const AudioTimeStamp* inTimeStamp,
							   UInt32 inBusNumber,
							   UInt32 inNumberFrames,
							   AudioBufferList* ioData) 
{
	AudioSocket* phy = (__bridge AudioSocket*) inRefCon;
	if(!phy.isRunning) {
		return kAudioUnitErr_CannotDoInCurrentContext;
	}
    
	Float32 *outL = ioData->mBuffers[0].mData;
	Float32 *outR = ioData->mBuffers[1].mData;
	
	// modulate
	[phy modulate:inNumberFrames leftBuf:outL rightBuf:outR];
	
	return noErr;
}

#pragma mark - AudioSession callback messages
-(void)interruptionNotification:(NSNotification *)notification {
    NSNumber *num = notification.userInfo[AVAudioSessionInterruptionTypeKey];
    AVAudioSessionInterruptionType interruptionType = [num unsignedIntegerValue];
    
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            [self updateIsAudioSessionInterrupted:YES];
            break;
        case AVAudioSessionInterruptionTypeEnded:
            [_session setActive:YES error:nil]; // re-activate and re-start audio play&recording
            [self updateIsAudioSessionInterrupted:NO];
            break;
        default:
            @throw [NSString stringWithFormat:@"Unexpected interruptionType:%ld, func:%s", interruptionType, __PRETTY_FUNCTION__];
            break;
    }
}
-(void)routeChangeNotification:(NSNotification *)notification {
    [self updateRouteStatus];
}
-(void)mediaServicesWereLostNotification:(NSNotification *)notification {
    _session = [AVAudioSession sharedInstance];
    [self prepareAudioSession:_bufferSize];
    [self addSessionObservers];
    [self prepareAudioUnit];
}
-(void)mediaServicesWereResetNotification:(NSNotification *)notification {
    _session = [AVAudioSession sharedInstance];
    [self prepareAudioSession:_bufferSize];
    [self addSessionObservers];
    [self prepareAudioUnit];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)(self)) {
        [self updateOutputVolume];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - Private messages
-(void)checkOSStatusError:(NSString *)message error:(OSStatus)error
{
	if(error) {
		NSLog(@"AudioSocket error message:%@ OSStatus:%d.",message, (int)error);
	}
}
-(void)checkError:(NSString *)message error:(NSError *)error
{
	if(error) {
		NSLog(@"AudioSocket error message:%@ OSStatus:%@.",message, error);
	}
}
-(void)updateRouteStatus
{
#if TARGET_IPHONE_SIMULATOR
	self.isJackIn = true;
#else // TARGET_IOS_IPHONE
    AVAudioSessionPortDescription *outport = [_session.currentRoute.outputs firstObject];
    self.isJackIn = [outport.portType isEqualToString:AVAudioSessionPortHeadphones];
    
    if([self respondsToSelector:@selector(jackInOutChanged:)]) {
        [self jackInOutChanged:self.isJackIn];
    }
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, outport.portType);
#endif
}
-(void)updateOutputVolume
{
    self.outputVolume = _session.outputVolume;
    if([self respondsToSelector:@selector(outputVolumeChanged:)]) {
        [self outputVolumeChanged:_session.outputVolume];
    }
}
-(void)updateIsAudioSessionInterrupted:(BOOL) isInt
{
    self.isInterrupted = isInt;
    if([self respondsToSelector:@selector(audioSessionInterrupted:)]){
        [self audioSessionInterrupted:isInt];
    }
}

-(void)prepareAudioSession:(int)audioBufferSize
{
    NSError *error;
    
	// Setting Audio Session Category (play and record)
    [_session setCategory:AVAudioSessionCategoryPlayback error:&error];
    
	[self checkError:@"[session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error]" error:error];
    
	// set hardware sampling rate
    [_session setPreferredSampleRate:kAudioSamplingRate error:&error];
    [self checkError:@"[session setPreferredSampleRate:kAudioSamplingRate error:&error]" error:error];

	// set audio buffer size
    NSTimeInterval duration = audioBufferSize / (double)kAudioSamplingRate;
    [_session setPreferredIOBufferDuration:duration error:&error];
	[self checkError:@"[session setPreferredIOBufferDuration:duration error:&error]" error:error];

	// read properties
    self.outputVolume = _session.outputVolume;
    
    [self updateRouteStatus];
    
	// activation
    [_session setActive:YES error:&error];
	[self checkError:@"[session setActive:YES error:&error]" error:error];
}
-(void)addSessionObservers {
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(interruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(routeChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(mediaServicesWereLostNotification:) name:AVAudioSessionMediaServicesWereLostNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(mediaServicesWereResetNotification:) name:AVAudioSessionMediaServicesWereResetNotification object:nil];
    
    [_session addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:(__bridge void *)(self)];
}
-(void)removeSessionObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_session removeObserver:self forKeyPath:@"outputVolume"];
}
-(void)prepareAudioUnit
{
	OSStatus error;
	//Getting RemoteIO Audio Unit (speaker out) AudioComponentDescription
    AudioComponentDescription cd;
	{
		cd.componentType    = kAudioUnitType_Output;
		cd.componentSubType = kAudioUnitSubType_RemoteIO;
		cd.componentManufacturer = kAudioUnitManufacturer_Apple;
		cd.componentFlags = 0;
		cd.componentFlagsMask = 0;
	}
    
    //Getting AudioComponent
    AudioComponent component = AudioComponentFindNext(NULL, &cd);
	
    //Getting audioUnit
    error = AudioComponentInstanceNew(component, &_audioUnit);
	[self checkOSStatusError:@"AudioComponentInstanceNew" error:error];
    
	// turning on a microphone
    /*
	UInt32 enableOutput = 1; // TRUE
	error = AudioUnitSetProperty(_audioUnit,
                                 kAudioOutputUnitProperty_EnableIO,
                                 kAudioUnitScope_Input,
                                 1, // microphone
                                 &enableOutput,
                                 sizeof(enableOutput));
	[self checkOSStatusError:@"AudioUnitSetProperty() turning on microphone" error:error];
	*/

    // sets a callback method
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback; //callback method
    callbackStruct.inputProcRefCon = (__bridge void*) self;// data pointer reffered in the callback method    
    error = AudioUnitSetProperty(_audioUnit, 
                                 kAudioUnitProperty_SetRenderCallback,                          
                                 kAudioUnitScope_Input, //input port of the speaker
                                 0,   // speaker
                                 &callbackStruct,
                                 sizeof(AURenderCallbackStruct));
	[self checkOSStatusError:@"AduioUnitSetProperty sets a callback method" error:error];
    
	// applying speaker-out audio format, stereo channels
    AudioStreamBasicDescription audioFormat;
	{
		audioFormat.mSampleRate         = kAudioSamplingRate;
		audioFormat.mFormatID           = kAudioFormatLinearPCM;
		audioFormat.mFormatFlags        = kAudioFormatFlagIsFloat | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked |  kAudioFormatFlagIsNonInterleaved;
		audioFormat.mChannelsPerFrame   = 2;
		audioFormat.mBytesPerPacket     = sizeof(Float32);
		audioFormat.mBytesPerFrame      = sizeof(Float32);
		audioFormat.mFramesPerPacket    = 1;
		audioFormat.mBitsPerChannel     = 8 * sizeof(Float32);
		audioFormat.mReserved           = 0;
	}    
    error = AudioUnitSetProperty(_audioUnit,
                                 kAudioUnitProperty_StreamFormat,
                                 kAudioUnitScope_Input, // input port of the speaker
                                 0, // speaker
                                 &audioFormat,
                                 sizeof(audioFormat));
	[self checkOSStatusError:@"AudioUnitSetProperty() sets speaker audio format" error:error];
    
	// applying microphone audio format, monoral channel
	// audioFormat.mChannelsPerFrame = 1;
    /*
	error = AudioUnitSetProperty(_audioUnit,
                                 kAudioUnitProperty_StreamFormat,
                                 kAudioUnitScope_Output,
                                 1, // microphone
                                 &audioFormat,
                                 sizeof(audioFormat));
	[self checkOSStatusError:@"AudioUnitSetProperty() sets microphone audio format" error:error];
    */
	//AudioUnit initialization
    error = AudioUnitInitialize(_audioUnit);
	[self checkOSStatusError:@"AudioUnitInitialize" error:error];
	/*
     uint flag = 0;
     AudioUnitGetProperty(audioUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Input, 0, &flag, sizeof(uint));
     NSLog(@"Should allocate buffer is %d.\n",flag);	*/
}
-(void)disposeAudioUnit {
    AudioUnitUninitialize(_audioUnit);
    AudioComponentInstanceDispose(_audioUnit);
}
@end
