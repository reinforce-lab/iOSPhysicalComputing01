//
//  AudioSocket.m
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/07.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "AudioSocket.h"
 #import <AudioToolbox/AudioToolbox.h>

#define AUDIO_AMPLING_RATE 44100
#define DEFAULT_AUDIO_BUFFER_SIZE 1024

@interface AudioSocket() {
    AudioUnit audioUnit_;
}

@property(nonatomic, assign) float outputVolume;
@property(nonatomic, assign) BOOL  isJackIn;
@property(nonatomic, assign) BOOL  isMicAvailable;
@property(nonatomic, assign) BOOL  isInterrupted;

@property(nonatomic, assign) BOOL isRunning;

-(void)setIsHeadSetInWP:(NSString *)route;
-(void)setVolumeWP:(NSNumber *)volume;
-(void)setIsAudioSessionInterruptedWP:(NSNumber *)isInterrupted;

-(void)checkOSStatusError:(NSString*)message error:(OSStatus)error;
-(void)prepareAudioSession:(int)audioBufferSize;
-(void)prepareAudioUnit;
@end

// function declarations
static void sessionPropertyChanged(void *inClientData,
                                   AudioSessionPropertyID inID,
                                   UInt32 inDataSize,
                                   const void *inData);

@implementation AudioSocket
#pragma mark - Properties
@synthesize outputVolume;
@synthesize isJackIn;
@synthesize isMicAvailable;
@synthesize isInterrupted;

@synthesize isRunning;

#pragma mark - Constructor
-(id)init
{
    return [self initWithParameters:DEFAULT_AUDIO_BUFFER_SIZE];
}
-(id)initWithParameters:(int)audioBufferSize {
    self = [super init];
    if(self) {
        [self prepareAudioSession:audioBufferSize];
        [self prepareAudioUnit];        
    }
    return  self;
}
-(void)dealloc{
    [self stop];
    // remove property listeners	
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, 
                                                   sessionPropertyChanged, (__bridge void *)self);
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, 
                                                   sessionPropertyChanged, (__bridge void*)self);    
    AudioUnitUninitialize(audioUnit_);
    AudioComponentInstanceDispose(audioUnit_);
}
#pragma mark - Public messages
-(void)start
{
	if(!self.isRunning){
		AudioOutputUnitStart(audioUnit_);
        self.isRunning = YES;
	}
}

-(void)stop
{
	if(self.isRunning) {
		AudioOutputUnitStop(audioUnit_);
		self.isRunning = NO;
	}
}

#pragma mark - AudioSocketDelegate

#pragma mark - AudioBufferDelegate
-(void)demodulate:(UInt32)length buf:(AudioUnitSampleType *)buf {}
-(void)modulate:(UInt32)length leftBuf:(AudioUnitSampleType *)leftBuf rightBuf:(AudioUnitSampleType *)rightBuf {}

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
	
	// render microphone 
	// refactoring: should allows an audio unit host application to tell an audio unit to use a specified buffer for its input callback.	
	OSStatus error = 
	AudioUnitRender(phy->audioUnit_,
					ioActionFlags,
					inTimeStamp,
					1, // microphone bus number
					inNumberFrames,
					ioData
					);
	[phy checkOSStatusError:@"Microphone audio rendering" error:error]; 	
	if(error) {
		return error;
	}
	
	// demodulate
	AudioUnitSampleType *outL = ioData->mBuffers[0].mData;
	AudioUnitSampleType *outR = ioData->mBuffers[1].mData;
	[phy demodulate:inNumberFrames buf:outL];
	
	// modulate
	[phy modulate:inNumberFrames leftBuf:outL rightBuf:outR];
	
	return noErr;
}
static void sessionInterruption(void *inClientData,
								UInt32 inInterruptionState)
{
    AudioSocket *phy = (__bridge AudioSocket *)inClientData;
	if(inInterruptionState == kAudioSessionBeginInterruption) {
        [phy performSelectorOnMainThread:@selector(setIsAudioSessionInterruptedWP:) 
                              withObject:[NSNumber numberWithBool:YES]
                           waitUntilDone:NO];
//		NSLog(@"Begin AudioSession interruption.");
	} else {
//		NSLog(@"End AudioSession interruption.");
		AudioSessionSetActive(YES); // re-activate and re-start audio play&recording
        [phy performSelectorOnMainThread:@selector(setIsAudioSessionInterruptedWP:) 
                              withObject:[NSNumber numberWithBool:NO]
                           waitUntilDone:NO];        
	}
}
static void sessionPropertyChanged(void *inClientData,
								   AudioSessionPropertyID inID,
								   UInt32 inDataSize,
								   const void *inData)
{
	AudioSocket *phy = (__bridge AudioSocket *)inClientData;
	if(inID ==kAudioSessionProperty_CurrentHardwareOutputVolume ) {	
		float volume = *((float *)inData);
        [phy performSelectorOnMainThread:@selector(setVolumeWP:) 
                              withObject:[NSNumber numberWithFloat:volume]
                           waitUntilDone:false];        
	} else if( inID == kAudioSessionProperty_AudioRouteChange ) {
#if !(TARGET_IPHONE_SIMULATOR)
		UInt32 size = sizeof(CFStringRef);
		CFStringRef route;
		AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &route);
        //		NSLog(@"%s route channged: %@", __func__, (NSString *)route );
		NSString *rt = [(__bridge_transfer NSString *)route copy];
        [phy performSelectorOnMainThread:@selector(setIsHeadSetInWP:) 
                              withObject:rt
                           waitUntilDone:false];
//            NSLog(@"%s rt:%@", __func__ , rt);
#endif		
	}
}

#pragma mark - AudioSession callback messages
-(void)setIsAudioSessionInterruptedWP:(NSNumber *)isInt
{
    BOOL val = [isInt boolValue];
    self.isInterrupted = val;
    if([self respondsToSelector:@selector(audioSessionInterrupted:)]){
        [self audioSessionInterrupted:val];
    }
}
-(void)setIsHeadSetInWP:(NSString *)rt
{
	self.isMicAvailable = [rt isEqualToString:@"HeadsetInOut"];
    self.isJackIn       = [rt isEqualToString:@"HeadsetInOut"] || [rt isEqualToString:@"HeadphonesAndMicrophone"];

    if([self respondsToSelector:@selector(jackInOutChanged:)]) {
        [self jackInOutChanged:self.isJackIn];
    }

//    NSLog(@"%s %@", __func__, rt );
}
-(void)setVolumeWP:(NSNumber *)volume
{
    float val = [volume floatValue];
    self.outputVolume = val;
    if([self respondsToSelector:@selector(outputVolumeChanged:)]) {
        [self outputVolumeChanged:val];
    }
}

#pragma mark - Private messages
-(void)checkOSStatusError:(NSString *)message error:(OSStatus)error
{
	if(error) {
		NSLog(@"AudioSocket error message:%@ OSStatus:%d.",message, (int)error);
	}
}
-(void)prepareAudioSession:(int)audioBufferSize
{
	OSStatus error;
	
	error = AudioSessionInitialize(NULL, NULL, sessionInterruption, (__bridge void*)self);
	[self checkOSStatusError:@"AudioSessionInitialize()" error:error];
	
	// Setting Audio Session Category (play and record)
	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
	error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                    sizeof(sessionCategory),
                                    &sessionCategory);
	[self checkOSStatusError:@"AudioSessionSetProperty() sets category" error:error];
    
	// set hardware sampling rate
	/*
     Float64 sampleRate = kSWMSamplingRate;
     error = AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, sizeof(Float64), &sampleRate);
     [self checkOSStatusError:@"AudioSessionSetProperty() sets currentHardwareSampleRate" error:error];
     */
	
	// set audio buffer size
	Float32 duration = audioBufferSize / (Float32)AUDIO_AMPLING_RATE;
	error = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(Float32), &duration);
	[self checkOSStatusError:@"AudioSessionSetProperty() sets preferredHardwareIOBufferDuration" error:error];
	
	// read properties
	UInt32 size = sizeof(float);
	float volume;
	error = AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareOutputVolume, &size, &volume);
	[self checkOSStatusError:@"AudioSessionGetProperty() current hardware volume." error:error];	
	self.outputVolume = volume;
    
#if TARGET_IPHONE_SIMULATOR
	self.isJackIn = true;
#else // TARGET_IOS_IPHONE
	size = sizeof(CFStringRef);
	CFStringRef route;
	error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &route);
	[self checkOSStatusError:@"AudioSessionGetProperty() audio route." error:error];
	NSString *rt = (__bridge_transfer NSString *)route;
	self.isMicAvailable = [rt isEqualToString:@"HeadsetInOut"];
    self.isJackIn       = [rt isEqualToString:@"HeadsetInOut"] || [rt isEqualToString:@"HeadphonesAndMicrophone"];
#endif
	
	// add property listener
	AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume, sessionPropertyChanged, (__bridge void*)self);
	AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, sessionPropertyChanged, (__bridge void*)self);
	
	// activation
	error = AudioSessionSetActive( YES );
	[self checkOSStatusError:@"AudioSessionSetActive()" error:error];
}
-(void)prepareAudioUnit
{
	OSStatus error;
	//Getting RemoteIO Audio Unit (speaker out) AudioComponentDescription
    AudioComponentDescription cd;
	{
		cd.componentType = kAudioUnitType_Output;
		cd.componentSubType = kAudioUnitSubType_RemoteIO;
		cd.componentManufacturer = kAudioUnitManufacturer_Apple;
		cd.componentFlags = 0;
		cd.componentFlagsMask = 0;
	}
    
    //Getting AudioComponent
    AudioComponent component = AudioComponentFindNext(NULL, &cd);
	
    //Getting audioUnit
    error = AudioComponentInstanceNew(component, &audioUnit_);
	[self checkOSStatusError:@"AudioComponentInstanceNew" error:error];
    
	// turning on a microphone
	UInt32 enableOutput = 1; // TRUE
	error = AudioUnitSetProperty(audioUnit_,
                                 kAudioOutputUnitProperty_EnableIO,
                                 kAudioUnitScope_Input,
                                 1, // microphone
                                 &enableOutput,
                                 sizeof(enableOutput));
	[self checkOSStatusError:@"AudioUnitSetProperty() turning on microphone" error:error];
	
    // sets a callback method
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback; //callback method
    callbackStruct.inputProcRefCon = (__bridge void*) self;// data pointer reffered in the callback method    
    error = AudioUnitSetProperty(audioUnit_, 
                                 kAudioUnitProperty_SetRenderCallback,                          
                                 kAudioUnitScope_Input, //input port of the speaker
                                 0,   // speaker
                                 &callbackStruct,
                                 sizeof(AURenderCallbackStruct));
	[self checkOSStatusError:@"AduioUnitSetProperty sets a callback method" error:error];
    
	// applying speaker-out audio format, stereo channels
    AudioStreamBasicDescription audioFormat;
	{
		audioFormat.mSampleRate         = AUDIO_AMPLING_RATE;
		audioFormat.mFormatID           = kAudioFormatLinearPCM;
		audioFormat.mFormatFlags        = kAudioFormatFlagsAudioUnitCanonical;
		audioFormat.mChannelsPerFrame   = 2;
		audioFormat.mBytesPerPacket     = sizeof(AudioUnitSampleType);
		audioFormat.mBytesPerFrame      = sizeof(AudioUnitSampleType);
		audioFormat.mFramesPerPacket    = 1;
		audioFormat.mBitsPerChannel     = 8 * sizeof(AudioUnitSampleType);
		audioFormat.mReserved           = 0;
	}    
    error = AudioUnitSetProperty(audioUnit_,
                                 kAudioUnitProperty_StreamFormat,
                                 kAudioUnitScope_Input, // input port of the speaker
                                 0, // speaker
                                 &audioFormat,
                                 sizeof(audioFormat));
	[self checkOSStatusError:@"AudioUnitSetProperty() sets speaker audio format" error:error];
    
	// applying microphone audio format, monoral channel
	// audioFormat.mChannelsPerFrame = 1;
	error = AudioUnitSetProperty(audioUnit_,
                                 kAudioUnitProperty_StreamFormat,
                                 kAudioUnitScope_Output,
                                 1, // microphone
                                 &audioFormat,
                                 sizeof(audioFormat));
	[self checkOSStatusError:@"AudioUnitSetProperty() sets microphone audio format" error:error];
    
	//AudioUnit initialization
    error = AudioUnitInitialize(audioUnit_);
	[self checkOSStatusError:@"AudioUnitInitialize" error:error];	
	/*
     uint flag = 0;
     AudioUnitGetProperty(audioUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Input, 0, &flag, sizeof(uint));
     NSLog(@"Should allocate buffer is %d.\n",flag);	*/
}

@end
