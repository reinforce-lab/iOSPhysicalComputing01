//
//  rotatableTabBarController.m
//  LEDjack
//
//  Created by Akihiro Uehara on 2012/10/30.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "rotatableTabBarController.h"

@interface rotatableTabBarController ()

@end

@implementation rotatableTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - rotatable view controller
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (   interfaceOrientation == UIInterfaceOrientationPortrait
            || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
-(BOOL)shouldAutorotate
{
    return YES;
}

@end
