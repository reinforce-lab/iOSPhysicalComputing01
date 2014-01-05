//
//  AudioPHY.m
//  SoftwareModem
//
//  Created by UEHARA AKIHIRO on 10/11/23.
//  Copyright 2010 REINFORCE Lab. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioPHYDelegate.h"
#import "AudioPHY.h"
#import "SWMModem.h"

// Private methods
@interface AudioPHY ()
{
    AVAudioSession *_session;
    AudioUnit _audioUnit;
    int _audioBufferSize;
    int _samplingRate;
    float _outputVolume;
    BOOL _isHeadsetIn;
    BOOL _isInterrupted; 
}

@property(nonatomic, assign) float outputVolume;
@property(nonatomic, assign) BOOL isHeadsetIn;
@property(nonatomic, assign) BOOL isMicAvailable;
@property(nonatomic, assign) BOOL isInterrupted;
@property(nonatomic, assign) BOOL isRunning;
@end

@implementation AudioPHY
#pragma mark - Properties
@dynamic outputVolume;
@dynamic isHeadsetIn;
@dynamic isInterrupted;

-(float)outputVolume
{
    return _outputVolume;
}
-(void)setOutputVolume:(float)outputVolume
{
    _outputVolume = outputVolume;
    [self.modem outputVolumeChanged:_outputVolume];
    [self.delegate outputVolumeChanged:_outputVolume];
}
-(BOOL)isHeadsetIn
{
    return _isHeadsetIn;
}
-(void)setIsHeadsetIn:(BOOL)isHeadsetIn
{
    _isHeadsetIn = isHeadsetIn;
    [self.modem headSetInOutChanged:_isHeadsetIn];
    [self.delegate headSetInOutChanged:_isHeadsetIn];
}
-(BOOL)isInterrupted
{
    return _isInterrupted;
}
-(void)setIsInterrupted:(BOOL)isInterrupted
{
    _isInterrupted = isInterrupted;
    [self.modem audioSessionInterrupted:_isInterrupted];
    [self.delegate audioSessionInterrupted:_isInterrupted];
}

#pragma mark - Constructor
-(id)initWithParameters:(float)samplingRate audioBufferSize:(int)audioBufferSize
{
    self = [super init];
	if(self) {
        _samplingRate = samplingRate;
        _audioBufferSize = audioBufferSize;
        _session = [AVAudioSession sharedInstance];
        
		[self prepareAudioSession];
        [self addSessionObservers];
		[self prepareAudioUnit];
	}
	return self;
}

-(void)dealloc {
    [self stop];
    [self removeSessionObservers];
    [self disposeAudioUnit];
}

#pragma mark render callback
static OSStatus renderCallback(void * inRefCon,
							   AudioUnitRenderActionFlags* ioActionFlags,
							   const AudioTimeStamp* inTimeStamp,
							   UInt32 inBusNumber,
							   UInt32 inNumberFrames,
							   AudioBufferList* ioData) 
{
	AudioPHY* phy = (__bridge AudioPHY*) inRefCon;
	if(!phy.isRunning) {
		return kAudioUnitErr_CannotDoInCurrentContext;
	}
	
	// render microphone 
	// refactoring: should allows an audio unit host application to tell an audio unit to use a specified buffer for its input callback.	
	OSStatus error = 
	AudioUnitRender(phy->_audioUnit,
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
	[phy.modem demodulate:inNumberFrames buf:outL];
	
	// modulate
	[phy.modem modulate:inNumberFrames leftBuf:outL rightBuf:outR];
	
// clear right channel
//	bzero(outR, inNumberFrames * sizeof(AudioUnitSampleType));
    
	return noErr;
}

#pragma mark - AudioSession callback messages
-(void)interruptionNotification:(NSNotification *)notification {
    NSNumber *num = notification.userInfo[AVAudioSessionInterruptionTypeKey];
    AVAudioSessionInterruptionType interruptionType = [num unsignedIntegerValue];
    
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            self.isInterrupted = YES;
            break;
        case AVAudioSessionInterruptionTypeEnded:
            [_session setActive:YES error:nil]; // re-activate and re-start audio play&recording
            self.isInterrupted = NO;
            break;
        default:
            @throw [NSString stringWithFormat:@"Unexpected interruptionType:%d, func:%s", (int)interruptionType, __PRETTY_FUNCTION__];
            break;
    }
}
-(void)routeChangeNotification:(NSNotification *)notification {
    [self updateRouteStatus];
}
-(void)mediaServicesWereLostNotification:(NSNotification *)notification {
    _session = [AVAudioSession sharedInstance];
    [self prepareAudioSession];
    [self addSessionObservers];
    [self prepareAudioUnit];
}
-(void)mediaServicesWereResetNotification:(NSNotification *)notification {
    _session = [AVAudioSession sharedInstance];
    [self prepareAudioSession];
    [self addSessionObservers];
    [self prepareAudioUnit];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)(self)) {
        self.outputVolume = _session.outputVolume;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - private methods
-(void)checkOSStatusError:(NSString *)message error:(OSStatus)error
{
	if(error) {
		NSLog(@"AudioPHY error message:%@ OSStatus:%d.",message, (int)error);
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
    self.isMicAvailable = YES;
	self.isHeadsetIn    = YES;
#else // TARGET_IOS_IPHONE
    AVAudioSessionPortDescription *outport = [_session.currentRoute.outputs firstObject];
    AVAudioSessionPortDescription *inport = [_session.currentRoute.inputs firstObject];
    self.isHeadsetIn = [outport.portType isEqualToString:AVAudioSessionPortHeadphones];
    self.isMicAvailable = [inport.portType isEqualToString:AVAudioSessionPortHeadsetMic];
#endif
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

-(void)prepareAudioSession
{
	NSError *error;
    
    // Setting Audio Session Category (play and record)
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [self checkError:@"[_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error]" error:error];

    // set hardware sampling rate
    [_session setPreferredSampleRate:_samplingRate error:&error];
    [self checkError:@"[session setPreferredSampleRate:kAudioSamplingRate error:&error]" error:error];
    
    // set audio buffer size
    NSTimeInterval duration = _audioBufferSize / (double)_samplingRate;
    [_session setPreferredIOBufferDuration:duration error:&error];
    [self checkError:@"[session setPreferredIOBufferDuration:duration error:&error]" error:error];
    
    // read properties
    self.outputVolume = _session.outputVolume;

    [self updateRouteStatus];
	
    // activation
    [_session setActive:YES error:&error];
    [self checkError:@"[session setActive:YES error:&error]" error:error];
    
	// activation
    [_session setActive:YES error:&error];
	[self checkError:@"[session setActive:YES error:&error]" error:error];
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
    error = AudioComponentInstanceNew(component, &_audioUnit);
	[self checkOSStatusError:@"AudioComponentInstanceNew" error:error];

	// turning on a microphone
	UInt32 enableOutput = 1; // TRUE
	error = AudioUnitSetProperty(_audioUnit,
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
		audioFormat.mSampleRate         = _samplingRate;
		audioFormat.mFormatID           = kAudioFormatLinearPCM;
		audioFormat.mFormatFlags        = kAudioFormatFlagsAudioUnitCanonical;
		audioFormat.mChannelsPerFrame   = 2;
		audioFormat.mBytesPerPacket     = sizeof(AudioUnitSampleType);
		audioFormat.mBytesPerFrame      = sizeof(AudioUnitSampleType);
		audioFormat.mFramesPerPacket    = 1;
		audioFormat.mBitsPerChannel     = 8 * sizeof(AudioUnitSampleType);
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
	//	audioFormat.mChannelsPerFrame = 1;
	error = AudioUnitSetProperty(_audioUnit,
						 kAudioUnitProperty_StreamFormat,
						 kAudioUnitScope_Output,
						 1, // microphone
						 &audioFormat,
						 sizeof(audioFormat));
	[self checkOSStatusError:@"AudioUnitSetProperty() sets microphone audio format" error:error];

	//AudioUnit initialization
    error = AudioUnitInitialize(_audioUnit);
	[self checkOSStatusError:@"AudioUnitInitialize" error:error];	
}
-(void)disposeAudioUnit {
    AudioUnitUninitialize(_audioUnit);
    AudioComponentInstanceDispose(_audioUnit);
}
#pragma mark public methods
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
@end
