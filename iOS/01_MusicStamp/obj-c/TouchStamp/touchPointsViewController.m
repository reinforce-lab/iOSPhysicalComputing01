//
//  touchPointsViewController.m
//  TouchStamp
//
//  Created by 昭宏 上原 on 12/05/26.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

#import "touchPointsViewController.h"
#import "touchesView.h"
#import "stampRecognizer.h"
#import "stampIdentifier.h"
#import "vector2d.h"

@interface touchPointsViewController () {    
    absPatternRecognizer *recognizer_;
    SystemSoundID sid_;
    int prev_touches_;
}

-(int)getUnitLength:(double)lengthInMiliMeter;
@end

@implementation touchPointsViewController

#pragma mark - Life cycle
@synthesize touchesView1_;
@synthesize touchesView2_;
@synthesize textView_;
@synthesize onpuBtn_;
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
    // Do any additional setup after loading the view from its nib.
      
    // load sound file
    NSString *path = [[NSBundle mainBundle] pathForResource:@"input" ofType:@"aif"];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &sid_);
    
    int unitLength = [self getUnitLength:16]; // MAGIC number Stepper initial value
    recognizer_ = [[stampRecognizer alloc] initWithTarget:self action:@selector(stampAction:) unitLength:unitLength]; 
    [recognizer_ addObserver:self forKeyPath:@"touches" options:NSKeyValueObservingOptionNew context:nil];
	[self.view addGestureRecognizer:recognizer_];

	[touchesView1_ setRecognizer:recognizer_];
    [touchesView2_ setRecognizer:recognizer_];    
}

- (void)viewDidUnload
{
    [self setTextView_:nil];
    [self setTouchesView1_:nil];
    [self setTouchesView2_:nil];
    [self setOnpuBtn_:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -
-(int)getUnitLength:(double)lengthInMiliMeter
{
    float ppi = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 132.0f : 163.0f;
    return (int)((ppi / 25.4f) * lengthInMiliMeter);
}
-(void)stampAction:(stampRecognizer *)sender
{    
    /*
     stampInfo *info = [recognizer_.stampInfo anyObject];
     label_.text = [NSString stringWithFormat:@"stamp id:%d pos:%@ angle:%d", info.stampID, info.position, info.angle];*/
    
}

- (IBAction)onpu_btn_touchUpInside:(id)sender {
   }

- (IBAction)onput_btn_touchDown:(id)sender {
    // toggle highghlighted flag
    onpuBtn_.selected = ! onpuBtn_.selected;
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == recognizer_) {
        if(onpuBtn_.selected && prev_touches_ == 0 && [recognizer_.touches count] > 0) {
            AudioServicesPlaySystemSound(sid_);
        }
        prev_touches_ = [recognizer_.touches count];
        // 座標表示
        NSMutableString *msg = [[NSMutableString alloc] initWithCapacity:100];
        [msg appendString:@"Touch points:\n"];
        for(int i = 0; i < [recognizer_.touches count]; i++) {
            vector2d *vec = [recognizer_.touches objectAtIndex:i];
            if(vec.y >= 216 ) { // MAGIC WORD 216は、下半分のViewのY座標。上半分のViewのタッチは表示しない
                [msg appendFormat:@"\t%d:(%3d, %-3d)\n", i, (int)vec.x, (int)vec.y - 216];
            }
        }
        textView_.text = msg;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
