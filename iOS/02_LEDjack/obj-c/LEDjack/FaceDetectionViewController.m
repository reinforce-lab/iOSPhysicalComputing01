//
//  FaceDetectionViewController.m
//  OTOsense
//
//  Created by 昭宏 上原 on 12/06/10.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "FaceDetectionViewController.h"

#define MAX_DURATION 100

@interface FaceDetectionViewController () {
    bool isMortorOn_;
}
-(void)updateMortorDrive:(bool)faceDetected;
@end

@implementation FaceDetectionViewController
#pragma mark - life cycle
@synthesize faceDetector;
@synthesize positionLabel;
@synthesize preview;
@synthesize areaLabel;

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.faceDetector = [[FaceDetector alloc] initWithView:(UIView *)self.preview];
    self.faceDetector.delegate = self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.ledDriver setWaveformParameters:4 burstDuration:MAX_DURATION];
    [self.ledDriver setAmplitude:1.0 led2Amplitude:1.0];
    [self.ledDriver setDuration:0 led2OnDuration:0];
    
    [self.faceDetector start];

    if(! self.faceDetector.isCameraAvailable) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"警告"
                              message:@"フロントカメラが有効ではありません。"
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.faceDetector stop];
}

- (void)viewDidUnload {
    [self.faceDetector stop];
    self.faceDetector = nil;
    
    [self setPositionLabel:nil];
    [self setAreaLabel:nil];
    [self setPreview:nil];
    [self setMortorButton:nil];
    
    [super viewDidUnload];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark - Private methods
-(void)detectionUpdated:(NSArray *)features
{
    bool isFaceDetected = ([features count] > 0);
    
    if(!isFaceDetected) {
        areaLabel.text = @"(  0,  0)";
        positionLabel.text = @"(  0,  0)";
    } else {
        CGRect r = [[features objectAtIndex:0] CGRectValue];
        //NSLog(@"%@", NSStringFromCGRect(r));
        areaLabel.text = [NSString stringWithFormat:@"(% 3d,% 3d)", (int)r.size.width, (int)r.size.height];
        positionLabel.text = [NSString stringWithFormat:@"(% 3d,% 3d)", (int)r.origin.x, (int)r.origin.y];
    }
    
    [self updateMortorDrive:isFaceDetected];
}

- (IBAction)mortorButtonTouchUpInside:(id)sender {
    self.mortorButton.selected = ! self.mortorButton.selected;
    // update mortor status
    [self updateMortorDrive:NO];
}

-(void)updateMortorDrive:(bool)faceDetected
{
    bool mortorStat = self.mortorButton.selected || faceDetected;
    
    if(mortorStat != isMortorOn_) {
        isMortorOn_ = mortorStat;
        if(isMortorOn_ ) {
            [self.ledDriver setDuration:MAX_DURATION led2OnDuration:MAX_DURATION];
        } else {
            [self.ledDriver setDuration:0 led2OnDuration:0];
        }
    }
}
@end