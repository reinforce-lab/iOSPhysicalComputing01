//
//  DoubleLEDViewController.h
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/04.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEDViewController.h"

@interface DoubleLEDViewController : LEDViewController

@property (weak, nonatomic) IBOutlet UILabel *led1TextLabel;
@property (weak, nonatomic) IBOutlet UISlider *led1Slidebar;
@property (weak, nonatomic) IBOutlet UILabel *led2TextLabel;
@property (weak, nonatomic) IBOutlet UISlider *led2Slidebar;

- (IBAction)led1SlidebarValueChanged:(id)sender;
- (IBAction)led2SlidebarValueChanged:(id)sender;
@end
