//
//  onpuViewController.m
//  TouchStamp
//
//  Created by 昭宏 上原 on 12/05/29.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

#import "onpuViewController.h"
#import "onpuView.h"
#import "stampRecognizer.h"
#import "keyRecognizer.h"
#import "stampInfo.h"

// スタンプIDと音ファイル名の定義
#define NUM_OF_STAMPS 7
const int  StampIDs[] = {1, 2, 3, 7, 8, 9, 24};
const char *StampFileNames[] = {"a", "b", "c", "d", "e", "f", "g"};

@interface onpuViewController () {    
    NSMutableDictionary  *sounds_;
    int prevStampID_;
}
@end

@implementation onpuViewController

#pragma mark - Life cycle
@synthesize touchesView1_;
@synthesize touchesView2_;
@synthesize textView_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    prevStampID_ = -1;
    
    // load sound files
    SystemSoundID sid;
    sounds_ = [[NSMutableDictionary alloc] initWithCapacity:NUM_OF_STAMPS];
    for(int i=0; i < NUM_OF_STAMPS; i++) {
        NSString *fname = [NSString stringWithFormat:@"%s", StampFileNames[i]];
        NSString *path = [[NSBundle mainBundle] pathForResource:fname ofType:@"aif"];
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &sid);
        [sounds_ setObject:[NSNumber numberWithUnsignedInt:sid] forKey:[NSNumber numberWithInt:StampIDs[i]]];
    }
    
	[touchesView1_ setRecognizer:recognizer_];
    [touchesView2_ setRecognizer:recognizer_];    
}

- (void)viewDidUnload
{
    [self setTextView_:nil];
    [self setTouchesView1_:nil];
    [self setTouchesView2_:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -
-(void)stampAction:(stampRecognizer *)sender
{    
    stampInfo *info = [recognizer_.stampInfo anyObject];
    if(info == nil) {
        textView_.text = [NSString stringWithFormat:@"no stamp"];
    } else {
        textView_.text = [NSString stringWithFormat:@"stamp id:%d pos:%@ angle:%d", info.stampID, info.position, info.angle];
    }
    
    if(info == nil) {
        prevStampID_ = -1;
    } else {
        if(prevStampID_ != info.stampID) {
            prevStampID_ = info.stampID;
            NSNumber *sid = (NSNumber *)[sounds_ objectForKey:[NSNumber numberWithInt:info.stampID]]; 
            if(sid != nil) {
                AudioServicesPlaySystemSound([sid unsignedIntValue]);
            }
        }
    }
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == recognizer_) {        
        // タッチ検出時間を検出
        if([recognizer_.touches count] <= 0) {
        }
        // 座標表示
        /*
        NSMutableString *msg = [[NSMutableString alloc] initWithCapacity:100];
        [msg appendString:@"Touch points:\n"];
        for(int i = 0; i < [recognizer_.touches count]; i++) {
            vector2d *vec = [recognizer_.touches objectAtIndex:i];
            if(vec.y <= 216 ) { // MAGIC WORD 216は、上半分のViewのY座標。したのViewのタッチは表示しない
                [msg appendFormat:@"\t%d:(%3d, %-3d)\n", i, (int)vec.x, (int)vec.y];
            }
        }
        textView_.text = msg;
         */
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
