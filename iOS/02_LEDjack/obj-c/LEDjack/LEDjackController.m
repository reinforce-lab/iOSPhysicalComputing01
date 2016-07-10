//
//  LEDjackController.m
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/09.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "LEDjackController.h"
#import "LEDDiffDriver.h"
#import "AppDelegate.h"

@interface LEDjackController()
-(void)updateViews;
-(void)updateViewsIntrinsic;

@end

@implementation LEDjackController
#pragma mark - Properties
@synthesize ballonImageView;
@synthesize ballonTextLabel;
@synthesize ledDriver;
@dynamic canDriveLED;

-(bool)getCanDriveLED
{
    return ledDriver.isJackIn && ledDriver.outputVolume >= 1.0;
}

#pragma mark - Constructor
#pragma mark - VC life cycle
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
    AppDelegate *dlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.ledDriver = dlg.ledDriver;
}

- (void)viewDidUnload
{
    [self setBallonImageView:nil];
    [self setBallonTextLabel:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // update view status
    [self setupLEDDriver];
    [ledDriver start];
    
    // KVO
    [ledDriver addObserver:self forKeyPath:@"outputVolume"   options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [ledDriver addObserver:self forKeyPath:@"isJackIn" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [ledDriver addObserver:self forKeyPath:@"isDrive"  options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [self updateViews];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // show warning dialog
//    AppDelegate *dlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)viewWillDisappear:(BOOL)animated
{    
    [ledDriver removeObserver:self forKeyPath:@"outputVolume"];
    [ledDriver removeObserver:self forKeyPath:@"isJackIn"];
    [ledDriver removeObserver:self forKeyPath:@"isDrive"];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)self) {
        [self updateViews];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Private messages
-(void)setupLEDDriver {}
-(void)canLEDDriveChanged:(bool)canDrive {}

// Viewの表示状態を更新
-(void)updateViews
{
    [UIView animateWithDuration:1.0 animations:^{
        [self updateViewsIntrinsic];
    }];
}
-(void)updateViewsIntrinsic
{
    bool canLEDDrive = YES;
    
    if(! ledDriver.isJackIn ) { // イヤホンが刺されていない                
        canLEDDrive = NO;
        ballonImageView.hidden = NO;
        ballonImageView.image = [UIImage imageNamed:@"ballon_up.png"];
        
        ballonTextLabel.hidden = NO;        
        ballonTextLabel.text = @"イヤホンを挿してください。";
    } else if(ledDriver.outputVolume < 1.0) { // 音量設定不足    
        canLEDDrive = NO;
        
        ballonImageView.hidden = NO;
        ballonImageView.image = [UIImage imageNamed:@"ballon_left.png"];
        
        ballonTextLabel.hidden = NO;
        ballonTextLabel.text = @"音量を最大にしてください。";
        
//        NSLog(@"%1.2f", ledDriver.outputVolume);
    }

    if(canLEDDrive) { // バルーン表示を隠す
        ballonImageView.hidden = YES;
        ballonTextLabel.hidden = YES;
    } else {
        [ledDriver setDuration:0 led2OnDuration:0]; // turn off led
    }
    
    [self canLEDDriveChanged:canLEDDrive];
}

@end
