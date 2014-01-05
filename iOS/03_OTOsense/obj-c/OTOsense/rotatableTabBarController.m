//
//  rotatableTabBarController.m
//  OTOsense
//
//  Created by uehara akihiro on 2014/01/05.
//  Copyright (c) 2014年 REINFORCE Lab. All rights reserved.
//

#import "rotatableTabBarController.h"

@implementation rotatableTabBarController
-(BOOL)shouldAutorotate {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
@end
