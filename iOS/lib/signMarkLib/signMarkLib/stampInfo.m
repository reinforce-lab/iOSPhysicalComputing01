//
//  stampTemplate.m
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/13.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import "stampInfo.h"
#import "vector2d.h"

@implementation stampInfo
#pragma mark - Variables
int stampID_;
int angle_;
vector2d *position_;

#pragma mark - Properties
@synthesize stampID  = stampID_;
@synthesize angle    = angle_;
@synthesize position = position_;

#pragma mark - Constructor
+(id)allocWithValues:(int)stampID position:(vector2d *)position angle:(int)angle
{
	return [[stampInfo alloc] initWithValues:stampID position:position angle:angle];
}
-(id)initWithValues:(int)stampID position:(vector2d *)position angle:(int)angle
{
	self = [super init];
	if(self) {
		stampID_  = stampID;
		position_ = position;
		angle_ = angle;
	}
	return self;
}
#pragma mark - Override methods
-(NSString *)description
{
	return [NSString stringWithFormat:@"StampID:%d Pos:%@ Angle:%d", stampID_, position_, angle_];
}
@end
