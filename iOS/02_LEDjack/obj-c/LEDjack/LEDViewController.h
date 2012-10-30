//
//  LEDViewController.h
//  LEDjack
//
//  Created by 昭宏 上原 on 12/06/04.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEDjackController.h"

@interface LEDViewController : LEDjackController
@property (weak, nonatomic) IBOutlet UITextView *volumeWarningTextView;
@property (weak, nonatomic) IBOutlet UIButton *ledButton;
@property (weak, nonatomic) IBOutlet UILabel *ledStatusLabel;

- (IBAction)ledButtonTouchUpInside:(id)sender;
@end
