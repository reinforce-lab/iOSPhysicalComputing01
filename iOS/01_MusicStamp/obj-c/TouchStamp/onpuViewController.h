//
//  onpuViewController.h
//  TouchStamp
//
//  Created by 昭宏 上原 on 12/05/29.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "onpuView.h"
#import "stampRecognizerViewController.h"
@interface onpuViewController : stampRecognizerViewController

@property (weak, nonatomic) IBOutlet onpuView *touchesView1_;
@property (weak, nonatomic) IBOutlet onpuView *touchesView2_;
@property (weak, nonatomic) IBOutlet UITextView *textView_;

@end
