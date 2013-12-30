//
//  vectorCode.m
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/13.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import "vectorCode.h"
#import "vector2d.h"

@implementation vectorCode
#pragma mark - Variables
int lengthCode_;
int angleCode_;
int hashValue_;

#pragma mark - Properties
@synthesize lengthCode = lengthCode_;
@synthesize angleCode = angleCode_;
@synthesize hashValue = hashValue_;

#pragma mark - Constructor
+(id)allocWithVectors:(int)unitLength vector:(vector2d *)vector referenceVector:(vector2d *)referenceVector
{
	return [[vectorCode alloc] initWithVectors:unitLength vector:vector referenceVector:referenceVector];
}
+(id)allocWithValues:(int)unitLength length:(float)length angle:(float)angle
{
	return [[vectorCode alloc] initWithValues:unitLength length:length angle:angle];
}
-(id)initWithVectors:(int)unitLength vector:(vector2d *)vector referenceVector:(vector2d *)referenceVector
{
	int lengthCode = [vectorCode getLengthCode:unitLength length:vector.length];
	int angleCode  = [vectorCode getAngleCode:[vector angleBetween:referenceVector]];
	self = [self initWithCodes:lengthCode angleCode:angleCode];
	return self;
}
-(id)initWithValues:(int)unitLength length:(float)length angle:(float)angle;
{
	int lengthCode = [vectorCode getLengthCode:unitLength length:length];
	int angleCode  = [vectorCode getAngleCode:angle];
	self = [self initWithCodes:lengthCode angleCode:angleCode];
	return self;
}
-(id)initWithCodes:(int)lengthCode angleCode:(int)angleCode
{
	self = [super init];
	if(self) {
		lengthCode_ = lengthCode;
		angleCode_ = angleCode;
		hashValue_ = lengthCode_ * 32 + angleCode_;
	}
	return self;
}

#pragma mark - Override methods
-(NSString *)description
{
	return [NSString stringWithFormat:@"%d,%d", lengthCode_, angleCode_];
}
#pragma mark - Private methods
// 距離コード、 コヨリとカテゴリ番号の対応は
/// 0-0.5   0
/// 0.5-1.2 1
/// 1.2-1.7 2
/// 1.7-2.5 3 (距離2とルート5を縮退)
/// 2.5-3.3 4
/// 3.3-    5
+(int)getLengthCode:(int)unitLength length:(float)length
{
	int cat = 0;
	float dist = length / (float)unitLength;
	if (3.3 < dist) { cat = 5; }
	else if (2.5 < dist && dist <= 3.3) { cat = 4; }
	else if (1.7 < dist && dist <= 2.5) { cat = 3; }
	else if (1.2 < dist && dist <= 1.7) { cat = 2; }
	else if (0.5 < dist && dist <= 1.2) { cat = 1; }
	
	return cat;
}
// 角度コード(単位は度)
+(int)getAngleCode:(float)ang
{
	int angle =(int)ang;
	angle = (angle + 360) % 360; // 値域を0-359に
	int quadrant = angle / 90;
	angle %= 90;
	
	int cat = 0;            
	if (77 < angle) { cat = 4; }
	else if (54 < angle && angle <= 77) { cat = 3; }
	else if (36 < angle && angle <= 54) { cat = 2; }
	else if (13 < angle && angle <= 36) { cat = 1; }
	
	cat += quadrant * 4;
	cat %= 16;
	
	return cat;
}
@end
