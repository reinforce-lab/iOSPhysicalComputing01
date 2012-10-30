//
//  DoubleLEDViewController.m
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/04.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "DoubleLEDViewController.h"

#define SAMPLING_RATE     44100.0
#define SAMPLES_PER_PULSE 4
#define MAX_DURATION      100

@interface DoubleLEDViewController()
-(void)updateLEDDuration;
@end

@implementation DoubleLEDViewController
@synthesize led1TextLabel;
@synthesize led2TextLabel;
@synthesize led1Slidebar;
@synthesize led2Slidebar;

- (void)viewDidUnload
{
    [self setLed1TextLabel:nil];
    [self setLed2TextLabel:nil];
    [self setLed1Slidebar:nil];
    [self setLed2Slidebar:nil];
    
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
    
    [self updateLEDDuration];
}

#pragma mark - Private messages
-(void)updateLEDDuration
{
    if(self.ledButton.selected) {   
        int l1 = (int)(led1Slidebar.value /2);
        int l2 = (int)(led2Slidebar.value /2);
        [self.ledDriver setDuration:l1 led2OnDuration:l2];
    } else {
        [self.ledDriver setDuration:0 led2OnDuration:0];
    }
}
-(void)setupLEDDriver
{
    [self.ledDriver setWaveformParameters:SAMPLES_PER_PULSE burstDuration:MAX_DURATION];
    [self.ledDriver setAmplitude:1.0 led2Amplitude:1.0];
    [self.ledDriver setDuration:0 led2OnDuration:0];
}
-(void)canLEDDriveChanged:(bool)canDrive
{
    if(canDrive) {
        self.volumeWarningTextView.hidden = NO;
        self.ledButton.enabled            = YES;
        self.led1Slidebar.enabled  = YES;
        self.led2Slidebar.enabled  = YES;
        self.led1TextLabel.enabled = YES;
        self.led2TextLabel.enabled = YES;
    } else {
        self.volumeWarningTextView.hidden = YES;
        self.ledButton.enabled   = NO;
        self.ledButton.selected  = NO;
        self.ledStatusLabel.text = @"OFF";
        self.led1Slidebar.enabled  = NO;
        self.led2Slidebar.enabled  = NO;
        self.led1TextLabel.enabled = NO;
        self.led2TextLabel.enabled = NO;
    }
}
#pragma mark - Event handlers
- (IBAction)led1SlidebarValueChanged:(id)sender
{
    led1TextLabel.text = [NSString stringWithFormat:@"%3d", (int) led1Slidebar.value];
    [self updateLEDDuration];
}

- (IBAction)led2SlidebarValueChanged:(id)sender
{
    led2TextLabel.text = [NSString stringWithFormat:@"%3d", (int)led2Slidebar.value];
    [self updateLEDDuration];
}

@end
