//
//  BrightnessViewController.m
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/04.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "BrightnessViewController.h"

#define MAX_DURATION 100

@interface BrightnessViewController ()
-(void)updateSlidebarsViewStatus;
-(void)updateLEDOutput;
-(void)updateLEDAmplitude;
-(void)updateLEDDuration;
@end

@implementation BrightnessViewController
@synthesize pulseDurationSlidebar;
@synthesize pulseDurationTextLabel;
@synthesize amplitudeTextLabel;
@synthesize amplitudeSlider;
@synthesize ledStatusTextLabel;
@synthesize ledButton;

-(void)viewWillAppear:(BOOL)animated
{
    ledButton.selected = NO;
    //
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setLedButton:nil];
    [self setLedStatusTextLabel:nil];
    [self setAmplitudeTextLabel:nil];
    [self setAmplitudeSlider:nil];
    [self setPulseDurationTextLabel:nil];
    [self setPulseDurationSlidebar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
#pragma mark - 
-(void)setupLEDDriver
{
//    NSLog(@"%s", __func__);    
    [self.ledDriver setWaveformParameters:2 burstDuration:MAX_DURATION];
    [self updateLEDOutput];
}
-(void)canLEDDriveChanged:(bool)canDrive
{
//    NSLog(@"%s", __func__);  
    if(canDrive) { // ボタン、スライドバーを有効        
        ledButton.enabled  = YES;
        ledButton.selected = NO;
        ledStatusTextLabel.text = @"OFF";        
    } else { // ボタン、スライドバーを無効                      
        ledButton.enabled  = NO;
        ledButton.selected = NO;
    }
    
    [self updateLEDOutput];    
    [self updateSlidebarsViewStatus];    
}

#pragma mark - Private messages
-(void)updateSlidebarsViewStatus
{
    if(ledButton.selected) { // Slidebarを有効
        amplitudeSlider.enabled        = YES;
        amplitudeTextLabel.enabled     = YES;
        pulseDurationSlidebar.enabled  = YES;
        pulseDurationTextLabel.enabled = YES;
    } else { // slidebarを無効
        amplitudeSlider.enabled        = NO;
        amplitudeTextLabel.enabled     = NO;
        pulseDurationSlidebar.enabled  = NO;
        pulseDurationTextLabel.enabled = NO;
    }
}
-(void)updateLEDOutput
{
    if(ledButton.selected) {
        [self updateLEDAmplitude];
        [self updateLEDDuration];
    } else {
        [self.ledDriver setDuration:0 led2OnDuration:0];
    }
}
-(void)updateLEDAmplitude
{
    float a = amplitudeSlider.value / 100.0;
    [self.ledDriver setAmplitude:a led2Amplitude:a];
}
-(void)updateLEDDuration
{
    int d =(int)(pulseDurationSlidebar.value / 2.0);
    [self.ledDriver setDuration:d led2OnDuration:d];
}
#pragma mark - Event handlers
- (IBAction)pulseDurationSlidebarValueChanged:(id)sender 
{
    pulseDurationTextLabel.text = [NSString stringWithFormat:@"%3.0f", pulseDurationSlidebar.value];
    [self updateLEDDuration];
}
- (IBAction)ledButtonTouchUpInside:(id)sender {
    ledButton.selected = ! ledButton.selected;
    
    if(ledButton.selected) { // LEDをON
        ledStatusTextLabel.text = @"ON";
    } else { // LEDをオフ
        ledStatusTextLabel.text = @"OFF";
    }
    
    [self updateLEDOutput];
    [self updateSlidebarsViewStatus];
}
- (IBAction)amplitudeSlidebarValueChanged:(id)sender {
    amplitudeTextLabel.text = [NSString stringWithFormat:@"%3.0f", amplitudeSlider.value];
    [self updateLEDAmplitude];
}
@end
