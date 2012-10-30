//
//  FlashViewController.m
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/04.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "FlashViewController.h"

#define SAMPLING_RATE     44100.0
#define SAMPLES_PER_PULSE 4

@interface FlashViewController ()
-(void)updateFlashFreq;
@end

@implementation FlashViewController
@synthesize flashFreqTextLabel;
@synthesize flashFreqSlidebar;
@synthesize dutySlidebar;
@synthesize dutyTextLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setFlashFreqTextLabel:nil];
    [self setFlashFreqSlidebar:nil];
    [self setDutySlidebar:nil];
    [self setDutyTextLabel:nil];
     

    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Event handlers
- (IBAction)ledButtonTouchUpInside:(id)sender {
    self.ledButton.selected = ! self.ledButton.selected;
    
    if(self.ledButton.selected) { // LEDをON
        self.ledStatusLabel.text = @"ON";
    } else {
        self.ledStatusLabel.text = @"OFF";
    }

    [self updateFlashFreq];
}

#pragma mark - Private messages
-(void)updateFlashFreq
{
    if(self.ledButton.selected) {
        float d   = SAMPLING_RATE / (2.0 * SAMPLES_PER_PULSE * flashFreqSlidebar.value);
        int ond = (int)(d * dutySlidebar.value);
        
//        NSLog(@"%s duty %d on-duty %d %f", __func__, (int)d, ond, dutySlidebar.value);
        
        [self.ledDriver setWaveformParameters:SAMPLES_PER_PULSE burstDuration:(int)d];
        [self.ledDriver setDuration:ond led2OnDuration:ond];
    } else {
        [self.ledDriver setDuration:0 led2OnDuration:0];
    }
}
-(void)setupLEDDriver
{
    [self.ledDriver setWaveformParameters:4 burstDuration:100];
    [self.ledDriver setAmplitude:1.0 led2Amplitude:1.0];
    [self.ledDriver setDuration:0 led2OnDuration:0];
}
-(void)canLEDDriveChanged:(bool)canDrive
{
    if(canDrive) {
        self.volumeWarningTextView.hidden = NO;
        self.ledButton.enabled            = YES;
        self.flashFreqSlidebar.enabled  = YES;
        self.flashFreqTextLabel.enabled = YES;
        self.dutySlidebar.enabled  = YES;
        self.dutyTextLabel.enabled = YES;
    } else {
        self.volumeWarningTextView.hidden = YES;
        self.ledButton.enabled   = NO;
        self.ledButton.selected  = NO;
        self.ledStatusLabel.text = @"OFF";
        self.flashFreqSlidebar.enabled  = NO;
        self.flashFreqTextLabel.enabled = NO;
        self.dutySlidebar.enabled  = NO;
        self.dutyTextLabel.enabled = NO;
    }
}
#pragma mark - Event handlers
- (IBAction)flashFreqSlidebarValueChanged:(id)sender
{
    flashFreqTextLabel.text = [NSString stringWithFormat:@"%3d", (int) flashFreqSlidebar.value];
    [self updateFlashFreq];
}

- (IBAction)dutySlidebarValueChanged:(id)sender
{
    dutyTextLabel.text = [NSString stringWithFormat:@"%1.1f", dutySlidebar.value];
    [self updateFlashFreq];
}

@end
