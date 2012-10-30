//
//  AppDelegate.h
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/03.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEDDiffDriver.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LEDDiffDriver *ledDriver;

@end
