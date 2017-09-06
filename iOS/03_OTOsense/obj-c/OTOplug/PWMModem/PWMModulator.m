//
//  PWMModulator.m
//  SoftwareModem
//
//  Created by UEHARA AKIHIRO on 10/11/23.
//  Copyright 2010 REINFORCE Lab. All rights reserved.
//
#import <math.h>
#import <strings.h>
#import "PWMModulator.h"
#import "PWMConstants.h"
#import "SWMModem.h"

// Private method declarations
@interface PWMModulator() {		    
	Float32 *buf_;
	int bufReadIndex_, bufWriteIndex_;
	Float32 *mark0_, *mark1_;
	int mark0Length_, mark1Length_;
	int mark1Cnt_;
	BOOL resyncRequired_;
	BOOL mute_;
	BOOL isBufferEmpty_;
    __unsafe_unretained id<SWMModem> modem_;
    
    int kPWMMark0Samples_;
}

-(Float32 *)allocAndInitSineWaveform:(int)length;
-(void)addRawByte:(Byte)value;
-(void)addByte:(Byte)value;
-(void)addBytes:(Byte[])buf length:(int)length;
-(void)addWaveform:(Float32 *)buf length:(int)length;
@end

@implementation PWMModulator
#pragma mark Properties
@synthesize isBufferEmtpy = isBufferEmpty_;
@synthesize mute = mute_;

#pragma mark Constuctor
-(id)initWithModem:(id<SWMModem>)m mark1Samples:(int)mark1Samples;
{
    self = [super init];
	if(self) {
        mute_ = YES;
		resyncRequired_ = TRUE;
		modem_ = m;
		mark1Cnt_ = 0;
		buf_ = calloc(kPWMModulatorBufferLength, sizeof(Float32));
		
		// template waveform, '1' , '0', preamble (0xA5)
        mark0Length_ = mark1Samples * 2;
		mark0_ = [self allocAndInitSineWaveform:mark0Length_];
		mark1Length_ = mark1Samples;
		mark1_ = [self allocAndInitSineWaveform:mark1Length_];
        
        kPWMMark0Samples_ = mark1Samples * 2;
	}
	return self;
}
// allocats and initializes packet buffer
-(Float32 *)allocAndInitSineWaveform:(int)length
{
	Float32 *buf = calloc(length, sizeof(Float32));
	float dw = 2 * M_PI / length;
	for(int i=0; i < length;i++) {
        buf[i] = sin(i * dw);
	}
	return buf;
}
-(void)dealloc
{
	free(mark0_);
	free(mark1_);
	free(buf_);
}
#pragma mark Private methods
-(void)addWaveform:(Float32 *)buf length:(int)length
{
	memcpy(&buf_[bufWriteIndex_], buf, length * sizeof(Float32));
	bufWriteIndex_ += length;
}
-(void)addByte:(Byte) value
{
	for(int i=0; i < 8; i++) {
		// LSb-first
		if((value & 0x01) == 0) {
			[self addWaveform:mark0_ length:mark0Length_];
			mark1Cnt_ = 0;
		} else {
			[self addWaveform:mark1_ length:mark1Length_];
			mark1Cnt_++;
			// add a stuffing bit
			if(mark1Cnt_ >= kSWMMaxMark1Length) {
				[self addWaveform:mark0_ length:mark0Length_];
				mark1Cnt_ = 0;
			}
		}
		value >>= 1;
	}
}

-(void)addBytes:(Byte[])buf length:(int)length
{
	for(int i=0; i<length; i++ ) {
		[self addByte:buf[i]];
	}
}
-(void)addRawByte:(Byte) value
{
	for(int i=0; i < 8; i++) {
		// LSb-first
		if((value & 0x01) == 0) {
			[self addWaveform:mark0_ length:mark0Length_];
		} else {
			[self addWaveform:mark1_ length:mark1Length_];
		}
		value >>= 1;
	}
	mark1Cnt_ = 0;
}
#pragma mark Public methods
-(int)sendPacket:(Byte[])buf length:(int)length
{
	@synchronized(self)
	{		
		// check available buffer length
		int requiredBufferLength = (length + kNumberOfReSyncCode + 1) * 8 * kPWMMark0Samples_; // 3: preamble 1: postamble
		if( (kPWMModulatorBufferLength - bufWriteIndex_) < requiredBufferLength) {
			return 0;
		}
		
		// preamble	
		if(resyncRequired_) {
			resyncRequired_ = FALSE;
			for(int i = 0; i < kNumberOfReSyncCode; i++) {
				[self addRawByte:kSWMSyncCode];
			}
		}

		// write waveform
		[self addBytes:buf length:length];

		// postamble
		[self addRawByte:kSWMSyncCode];
	
		return length;
	}
}
// This method is invoked on audio rendering thread
-(void)modulate:(UInt32)length leftBuf:(Float32 *)leftBuf rightBuf:(Float32 *)rightBuf
{
	// fill left channel buffer
	@synchronized(self) {
		isBufferEmpty_ = (bufReadIndex_ == bufWriteIndex_);
		if(isBufferEmpty_ || mute_) {
			// waveform buffer is empty
            memset(leftBuf, 0, sizeof(Float32) * length);
		} else {
			// fill buffer tail
			int fill_size = (bufReadIndex_ + kPWMAudioBufferSize) - bufWriteIndex_;
			if(fill_size > 0) {
                memset(&buf_[bufWriteIndex_] , 0, fill_size * sizeof(Float32));
				bufWriteIndex_ += fill_size;
				resyncRequired_ = TRUE;
			}
			// copy buffer setment
			memcpy(leftBuf, &buf_[bufReadIndex_], kPWMAudioBufferSize * sizeof(Float32));
			bufReadIndex_ += kPWMAudioBufferSize;
			// is buffer empty?
			isBufferEmpty_ = (bufReadIndex_ == bufWriteIndex_);
			if( isBufferEmpty_ ) {
				bufReadIndex_  = 0;
				bufWriteIndex_ = 0;
			}
		}
        memcpy(rightBuf, leftBuf, length * sizeof(Float32));
// clear right buffer
// bzero(rightBuf, length * sizeof(Float32));
	}
	// request next packet data
	if(isBufferEmpty_) {
		[modem_ sendBufferEmptyNotify];
	}
}
@end
