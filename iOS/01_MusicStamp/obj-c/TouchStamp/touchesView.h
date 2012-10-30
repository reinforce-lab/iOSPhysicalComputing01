//
//  touchesView.h
//  TouchStamp
//
//  Created by 昭宏 上原 on 12/05/29.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class absPatternRecognizer;

@interface touchesView : UIView
-(void)setRecognizer:(absPatternRecognizer *)recognizer;
@end
