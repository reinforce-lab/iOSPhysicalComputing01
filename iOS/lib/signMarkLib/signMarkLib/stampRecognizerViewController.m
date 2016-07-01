//
//  stampRecognizerViewController.m
//  signMarkLib
//
//  Created by Akihiro Uehara on 2012/10/29.
//  Copyright (c) 2012年 Akihiro Uehara. All rights reserved.
//

#import "stampRecognizerViewController.h"
#import "stampRecognizer.h"
#import <sys/utsname.h>

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
-(NSString*)getDeviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}
-(int)getUnitLength:(double)lengthInMiliMeter
{
//    float ppi = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 132.0f : 163.0f;
    float ppi = 163.0f;

    NSString* deviceName = [self getDeviceName];
    if( [deviceName hasPrefix:@"iPhone7,1"] || [deviceName hasPrefix:@"iPhone8,2"] ) { // iPhone6plus , iPhone6s plus
        ppi = 401 / 2;
    }
    
    return (int)((ppi / 25.4f) * lengthInMiliMeter);
}

-(void)stampAction:(stampRecognizer *)sender
{
}
@end

