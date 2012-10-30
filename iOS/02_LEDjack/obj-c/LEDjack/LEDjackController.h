//
//  LEDjackController.h
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/09.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEDDiffDriver.h"

@interface LEDjackController : UIViewController
@property (nonatomic, unsafe_unretained) LEDDiffDriver *ledDriver;

@property (weak, nonatomic) IBOutlet UIImageView *ballonImageView;
@property (weak, nonatomic) IBOutlet UILabel *ballonTextLabel;

@property (nonatomic, readonly) bool canDriveLED;

//- Abstract messages that inheritaed class must implement.
-(void)setupLEDDriver;
-(void)canLEDDriveChanged:(bool)canDrive;
@end
