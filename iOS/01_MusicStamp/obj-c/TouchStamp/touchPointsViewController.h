//
//  touchPointsViewController.h
//  TouchStamp
//
//  Created by 昭宏 上原 on 12/05/26.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "touchesView.h"

@interface touchPointsViewController : UIViewController

@property (weak, nonatomic) IBOutlet touchesView *touchesView1_;
@property (weak, nonatomic) IBOutlet touchesView *touchesView2_;
@property (weak, nonatomic) IBOutlet UITextView *textView_;
@property (weak, nonatomic) IBOutlet UIButton *onpuBtn_;

- (IBAction)onpu_btn_touchUpInside:(id)sender;
- (IBAction)onput_btn_touchDown:(id)sender;

@end
