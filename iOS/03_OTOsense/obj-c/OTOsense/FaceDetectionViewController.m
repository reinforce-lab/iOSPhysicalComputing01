//
//  FaceDetectionViewController.m
//  OTOsense
//
//  Created by 昭宏 上原 on 12/06/10.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "FaceDetectionViewController.h"
#import "PacketTypes.h"

@interface FaceDetectionViewController () {
    uint8_t buf_[5];
}
@end

@implementation FaceDetectionViewController
#pragma mark - life cycle
@synthesize positionLabel;
@synthesize preview;
@synthesize areaLabel;
@synthesize faceDetector;

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( self.faceDetector == nil) {
        self.faceDetector = [[FaceDetector alloc] initWithView:self.preview];
        self.faceDetector.delegate = self;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.faceDetector start];
    
    if(! self.faceDetector.isCameraAvailable) {        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"警告"
                                    message:@"フロントカメラが有効ではありません。"
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.faceDetector stop];

    [super viewWillDisappear:animated];
}

#pragma mark - Private methods
-(void)detectionUpdated:(NSArray *)features
{
     buf_[0] = FACE_PACKET_ID;
    for(int i=1; i < 5; i++) {
        buf_[i] = 0;
    }
    
    if([features count] == 0) { // 顔検出されない        
        areaLabel.text = @"(  0,  0)";        
        positionLabel.text = @"(  0,  0)";
    } else {
        CGRect r = [[features objectAtIndex:0] CGRectValue];
//NSLog(@"%@", NSStringFromCGRect(r));
        areaLabel.text = [NSString stringWithFormat:@"(% 3d,% 3d)", (int)r.size.width, (int)r.size.height];
        positionLabel.text = [NSString stringWithFormat:@"(% 3d,% 3d)", (int)r.origin.x, (int)r.origin.y];
        
        buf_[1] = (int)r.origin.x;
        buf_[2] = (int)r.origin.y;
        buf_[3] = (int)r.size.width;
        buf_[4] = (int)r.size.height;
    }

    [self.socket write:buf_ length:5];    
}
- (void)viewDidUnload {
    [self setPositionLabel:nil];
    [self setAreaLabel:nil];
    [self setPreview:nil];
    [super viewDidUnload];
}
@end