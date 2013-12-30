//
//  vectorCode.h
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/13.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vector2d.h"

// カテゴリ分けされた、ベクトルの長さと確度
@interface vectorCode : NSObject

@property (nonatomic, readonly) int lengthCode;
@property (nonatomic, readonly) int angleCode;
@property (nonatomic, readonly) int hashValue;

+(id)allocWithVectors:(int)unitLength vector:(vector2d *)vector referenceVector:(vector2d *)referenceVector;
+(id)allocWithValues:(int)unitLength length:(float)length angle:(float)angle;
-(id)initWithVectors:(int)unitLength vector:(vector2d *)vector referenceVector:(vector2d *)referenceVector;
-(id)initWithValues:(int)unitLength length:(float)length angle:(float)angle;
-(id)initWithCodes:(int)lengthCode angleCode:(int)angleCode;

+(int)getLengthCode:(int)unitLength length:(float)length;
+(int)getAngleCode:(float)angle;
@end
