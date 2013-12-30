//
//  stampTemplate.h
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/13.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vector2d.h"

@interface stampInfo : NSObject 

@property (nonatomic, readonly) int stampID;
@property (nonatomic, readonly) int angle;
@property (nonatomic, strong, readonly) vector2d *position;

+(id)allocWithValues:(int)stampID position:(vector2d *)position angle:(int)angle;
-(id)initWithValues:(int)stampID  position:(vector2d *)position angle:(int)angle;
@end
