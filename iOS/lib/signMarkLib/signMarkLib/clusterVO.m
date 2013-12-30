//
//  clusterVO.m
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/15.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import "clusterVO.h"
#import "vectorCode.h"
#import "vector2d.h"
#import "traceDistanceTable.h"
#import <math.h>

@interface clusterVO()
-(NSArray *)getVectorCodes:(int)unitLength vectors:(NSArray *)vectors;
-(void)initCircumscribedRect:(NSArray *)vectors;
@end

@implementation clusterVO
#pragma mark - Variables
vector2d *origin_;
vector2d *referenceVector_;
CGRect circumscribeRect_;	

#pragma mark - Properties
@synthesize origin = origin_;
@synthesize referenceVector = referenceVector_;
@synthesize circumscribeRect =circumscribeRect_;

#pragma mark - Construcotr
-(id)initWithIndices:(traceDistanceTable *)table indices:(NSArray *)indices
{
	// vector code構築
	NSMutableArray *vectors = [NSMutableArray arrayWithCapacity:[indices count]];
	for(NSNumber *idx in indices) {	
		vector2d *vector = [table.touches objectAtIndex:[idx intValue]];
		[vectors addObject:vector];
	}
	NSArray *vectorCodes = [self getVectorCodes:table.unitLengthInPixel vectors:vectors];
	
	self = [super initWithVectorCodes:vectorCodes];
	if(self) {
		origin_ = [vectors objectAtIndex:0];
		referenceVector_ = [vector2d sub:[vectors objectAtIndex:1] b:[vectors objectAtIndex:0]];
				
		[self initCircumscribedRect:vectors];
	}
	return self;
}

#pragma mark - Private metods
-(void)initCircumscribedRect:(NSArray *)vectors
{
	// 点群の最大/最小の座標値を取得
	float minX = MAXFLOAT;
	float minY = MAXFLOAT;
	float maxX = 0;
	float maxY = 0;
	for(vector2d *pt in vectors) {
		minX = fminf(pt.x, minX);
		maxX = fmaxf(pt.x, maxX);
		minY = fminf(pt.y, minY);
		maxY = fmaxf(pt.y, maxY);
	}
	// 四角領域
	circumscribeRect_ = CGRectMake(minX, minY, maxX-minX, maxY-minY);
}
// 適当な2点を基準として、長さと角度(カテゴライズした)配列を算出。ベクトルは時計回りの方向にソート
-(NSArray *)getVectorCodes:(int)unitLength vectors:(NSArray *)vectors
{
	// 基準ベクトル
	vector2d *op = [vectors objectAtIndex:0];
	vector2d *up = [vectors objectAtIndex:1];
	vector2d *ov = op;
	vector2d *uv = [vector2d sub:up b:op];
	
	// 角度を求める
	NSUInteger cnt = [vectors count];
	NSMutableArray *codes = [NSMutableArray arrayWithCapacity:cnt];	
	for(int i=1; i < cnt; i++) {
		vector2d *p = [vectors objectAtIndex:i];
		vector2d *v = [vector2d sub:p b:ov];
		vectorCode *vc = [[vectorCode alloc] initWithVectors:unitLength vector:v referenceVector:uv];				
		[codes addObject:vc];
	}
	return codes;
}
#pragma mark - Public methods
@end
