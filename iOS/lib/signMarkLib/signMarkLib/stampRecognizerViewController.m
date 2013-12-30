//
//  stampRecognizerViewController.m
//  signMarkLib
//
//  Created by Akihiro Uehara on 2012/10/29.
//  Copyright (c) 2012年 Akihiro Uehara. All rights reserved.
//

#import "stampRecognizerViewController.h"
#import "stampRecognizer.h"

@interface stampRecognizerViewController () {
}
@end

@implementation stampRecognizerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    int unitLength = [self getUnitLength:8]; // MAGIC number Stepper initial value
    
    recognizer_ = [[stampRecognizer alloc] initWithTarget:self action:@selector(stampAction:) unitLength:unitLength];
    [recognizer_ addObserver:self forKeyPath:@"touches" options:NSKeyValueObservingOptionNew context:nil];
	[self.view addGestureRecognizer:recognizer_];
}

#pragma mark -
-(int)getUnitLength:(double)lengthInMiliMeter
{
//    float ppi = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 132.0f : 163.0f;
    float ppi = 163.0f;
    return (int)((ppi / 25.4f) * lengthInMiliMeter);
}

-(void)stampAction:(stampRecognizer *)sender
{
}
@end

