//
//  measureViewController.h
//  TouchStamp
//
//  Created by 昭宏 上原 on 12/05/29.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "measureView.h"

@interface measureViewController : UIViewController

@property (weak, nonatomic) IBOutlet measureView *measureView1_;
@property (weak, nonatomic) IBOutlet measureView *measureView2_;
@property (weak, nonatomic) IBOutlet UITextView *textView_;

@end
