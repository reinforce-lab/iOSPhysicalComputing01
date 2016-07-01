//
//  measureViewController.m
//  TouchStamp
//
//  Created by 昭宏 上原 on 12/05/29.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "measureViewController.h"
#import "stampRecognizer.h"
#import "keyRecognizer.h"
#import "stampInfo.h"
#import <sys/utsname.h>

@interface measureViewController () {    
    absPatternRecognizer *recognizer_;
}
-(int)getUnitLength:(double)lengthInMiliMeter;
@end

@implementation measureViewController

#pragma mark - Properties
@synthesize measureView1_;
@synthesize measureView2_;
@synthesize textView_;

#pragma mark - Life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    int unitLength = [self getUnitLength:16]; // MAGIC number Stepper initial value
    
    recognizer_ = [[stampRecognizer alloc] initWithTarget:self action:@selector(stampAction:) unitLength:unitLength]; 
    [recognizer_ addObserver:self forKeyPath:@"touches" options:NSKeyValueObservingOptionNew context:nil];
	[self.view addGestureRecognizer:recognizer_];
    
	[measureView1_ setRecognizer:recognizer_];
    [measureView2_ setRecognizer:recognizer_];    
}

- (void)viewDidUnload
{
    [self setTextView_:nil];
    [self setMeasureView1_:nil];
    [self setMeasureView2_:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
// モデル名を取得する
-(NSString*)getDeviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}
-(int)getUnitLength:(double)lengthInMiliMeter
{
    float ppi = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 132.0f : 163.0f;

    NSString* deviceName = [self getDeviceName];
    if( [deviceName hasPrefix:@"iPhone7,1"] || [deviceName hasPrefix:@"iPhone8,2"] ) { // iPhone6plus , iPhone6s plus
        ppi = 401 / 2;
    }

    return (int)((ppi / 25.4f) * lengthInMiliMeter);
}

-(void)stampAction:(stampRecognizer *)sender
{    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == recognizer_) {        
        NSMutableString *msg = [[NSMutableString alloc] initWithCapacity:100];        
        [msg appendString:@"Distance: "];
        // 2点間の距離計算
        if([recognizer_.touches count] >= 2 ) {
            vector2d *p1 = [recognizer_.touches objectAtIndex:0];
            vector2d *p2 = [recognizer_.touches objectAtIndex:1];
            vector2d *d = [p1 sub:p2];
            [msg appendFormat:@"%2.1f mm", d.length * (25.4f / 163.0f)];
        }
        textView_.text = msg;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
