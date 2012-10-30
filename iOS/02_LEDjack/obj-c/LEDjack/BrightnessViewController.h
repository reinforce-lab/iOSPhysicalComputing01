//
//  BrightnessViewController.h
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/04.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEDjackController.h"

@interface BrightnessViewController : LEDjackController

@property (weak, nonatomic) IBOutlet UISlider *pulseDurationSlidebar;
@property (weak, nonatomic) IBOutlet UILabel *pulseDurationTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *amplitudeTextLabel;
@property (weak, nonatomic) IBOutlet UISlider *amplitudeSlider;
@property (weak, nonatomic) IBOutlet UILabel *ledStatusTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *ledButton;

- (IBAction)amplitudeSlidebarValueChanged:(id)sender;
- (IBAction)pulseDurationSlidebarValueChanged:(id)sender;
- (IBAction)ledButtonTouchUpInside:(id)sender;

@end
