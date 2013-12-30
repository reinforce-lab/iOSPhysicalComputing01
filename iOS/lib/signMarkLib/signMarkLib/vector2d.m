//
//  vector2d.m
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/15.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import "vector2d.h"

@implementation vector2d
#pragma mark - Variables
float x_;
float y_;	

#pragma mark - Properties
@synthesize x = x_;
@synthesize y = y_;
@dynamic length;
-(float)getLength{
	return sqrtf(x_*x_ + y_*y_);
}

#pragma mark - Constructor
+(id)allocWithValues:(float)x y:(float)y
{
	return [[vector2d alloc] initWithValues:x y:y];
}
-(id)initWithCGPoint:(CGPoint)point
{
	return [self initWithValues:point.x y:point.y];
}
-(id)initWithValues:(float)x y:(float)y
{
	self = [super init];
	if(self) {
		x_ = x;
		y_ = y;
	}
	return self;
}
-(NSString *)description
{
	return [NSString stringWithFormat:@"(%f, %f)", x_, y_];
}
#pragma mark - Public methods
// 2ベクトル間の角度
+(vector2d *)add:(vector2d *)a b:(vector2d *)b
{
	return [[vector2d alloc] initWithValues:(a.x + b.x) y:(a.y + b.y)];
}
+(vector2d *)sub:(vector2d *)a b:(vector2d *)b
{
	return [[vector2d alloc] initWithValues:(a.x - b.x) y:(a.y - b.y)];
}
+(float)innerProduct:(vector2d *)a  b:(vector2d *)b
{
	return a.x * b.x + a.y * b.y;
}
// 角度(単位はdeg)
+(float)angleBetween:(vector2d *)a b:(vector2d *)b
{
	float innerProduct = [vector2d innerProduct:a b:b];
	float outerProduct  = a.x * b.y - a.y * b.x;
	float s = a.length * b.length;
	float angle = 0;
	if(s != 0) {
		angle = acosf(innerProduct / s) * 360.0f /(2*M_PI);	 // acosfは[0,180>
	}
	if(outerProduct > 0) {
		angle = 360 - angle; //外積が正であれば、反時計回り
	}
	return angle;	
}

-(vector2d *)add:(vector2d *)a
{
	return [vector2d add:self b:a];
}
-(vector2d *)sub:(vector2d *)a
{
	return [vector2d sub:self b:a];
}
-(float)innerProduct:(vector2d *)vect
{
	return [vector2d innerProduct:self b:vect];
}
// 単位はdeg
-(float)angleBetween:(vector2d *)vect
{
	return [vector2d angleBetween:self b:vect];
}
@end
