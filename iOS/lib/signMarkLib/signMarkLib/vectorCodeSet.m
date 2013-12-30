//
//  vectorCodeSet.m
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/13.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import "vectorCode.h"
#import "vectorCodeSet.h"

@interface vectorCodeSet()
-(void)setVectorCodes:(NSArray *)vectorCodes;
@end

#pragma mark - function declaration
NSInteger vectorSort(id v1, id v2, void *context);

@implementation vectorCodeSet
#pragma mark -Variables
NSArray *vectorCodes_;
NSString *hash_;

#pragma mark - Properties
@synthesize vectorCodes = vectorCodes_;
@synthesize hash = hash_;

#pragma mark - Constructor
+(id)allocWithVectorCodes:(NSArray *)vectorCodes
{
	return [[vectorCodeSet alloc] initWithVectorCodes:vectorCodes];
}
-(id)initWithVectorCodes:(NSArray *)vectorCodes
{
	self = [super init];
	if(self) {
		[self setVectorCodes:vectorCodes];
	}
	return self;
}

#pragma mark - OVerride methods
-(NSString *)description {
	return hash_;
}
#pragma mark - Private methods
NSInteger vectorSort(id v1, id v2, void *context)
{
	int h1 = ((vectorCode *)v1).hashValue;
	int h2 = ((vectorCode *)v2).hashValue;
	if(h1 < h2) 
		return NSOrderedAscending;
	else if(h1 > h2) 
		return NSOrderedDescending;
	else 
		return NSOrderedSame;
}
-(void)setVectorCodes:(NSArray *)vectorCodes
{
	// 角度と長さでソート
	vectorCodes_ =[vectorCodes sortedArrayUsingFunction:vectorSort context:nil];
	// ハッシュ文字列を計算
	NSMutableString *str = [NSMutableString stringWithCapacity:128];
	for(vectorCode *code in vectorCodes_) {
		[str appendFormat:@"(%d,%d),", code.lengthCode, code.angleCode];
	}	
	hash_ = str;
}

#pragma mark - Public methods
-(BOOL)isMatch:(vectorCodeSet *)codeSet
{
	return [hash_ isEqualToString:codeSet.hash];
}
@end
