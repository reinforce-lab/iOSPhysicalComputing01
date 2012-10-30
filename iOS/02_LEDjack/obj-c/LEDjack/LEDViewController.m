//
//  LEDViewController.m
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/04.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "LEDViewController.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_DURATION 100

@interface LEDViewController ()
@end

@implementation LEDViewController
@synthesize volumeWarningTextView;
@synthesize ledButton;
@synthesize ledStatusLabel;

#pragma mark - VC life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];

    self.volumeWarningTextView.layer.cornerRadius = 5;
    self.volumeWarningTextView.layer.masksToBounds = YES;
}
- (void)viewDidUnload
{
    [self setVolumeWarningTextView:nil];
    [self setLedButton:nil];
    [self setLedStatusLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
-(void)viewWillAppear:(BOOL)animated
{
    ledButton.selected = NO;    
    [super viewWillAppear:animated];
}

#pragma mark - Event handlers
- (IBAction)ledButtonTouchUpInside:(id)sender {
    if(ledButton.selected) { // LEDをOF
        [self.ledDriver setDuration:0 led2OnDuration:0];
        ledStatusLabel.text = @"OFF";
    } else {
        [self.ledDriver setDuration:(MAX_DURATION /2) led2OnDuration:(MAX_DURATION /2)];
        ledStatusLabel.text = @"ON";
    }
    ledButton.selected = ! ledButton.selected;
}

#pragma mark - Private messages
-(void)setupLEDDriver
{
//-    NSLog(@"%s", __func__);
    [self.ledDriver setWaveformParameters:4 burstDuration:MAX_DURATION];
    [self.ledDriver setAmplitude:1.0 led2Amplitude:1.0];
    [self.ledDriver setDuration:0 led2OnDuration:0];
}
-(void)canLEDDriveChanged:(bool)canDrive
{
    if(canDrive) {
        volumeWarningTextView.hidden = NO;
        ledButton.enabled            = YES;
    } else {
        volumeWarningTextView.hidden = YES;
        ledButton.enabled   = NO;
        ledButton.selected  = NO;
        ledStatusLabel.text = @"OFF";
    }
}
@end
