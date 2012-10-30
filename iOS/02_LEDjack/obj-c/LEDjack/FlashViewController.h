//
//  FlashViewController.h
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/04.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEDViewController.h"

@interface FlashViewController : LEDViewController

@property (weak, nonatomic) IBOutlet UILabel *flashFreqTextLabel;
@property (weak, nonatomic) IBOutlet UISlider *flashFreqSlidebar;
@property (weak, nonatomic) IBOutlet UILabel *dutyTextLabel;
@property (weak, nonatomic) IBOutlet UISlider *dutySlidebar;

- (IBAction)flashFreqSlidebarValueChanged:(id)sender;
- (IBAction)dutySlidebarValueChanged:(id)sender;


@end
