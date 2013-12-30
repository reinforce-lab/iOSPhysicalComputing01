//
//  patternIdentifier.m
//  signMarkLib
//
//  Created by Uehara Akihiro on 11/10/03.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import "stampIdentifier.h"
#import "vector2d.h"
#import "clusterVO.h"
#import "stampInfo.h"
#import "vectorCode.h"
#import "vectorCodeSet.h"

@interface absPatternIdentifier()
//implement this pattern building message
-(NSArray *)buildPatterns;
-(void)initialize;
@end

@implementation absPatternIdentifier
#pragma mark - Variables
NSDictionary *templates_;
NSDictionary *stampIDs_;
NSDictionary *referenceVectors_;
NSDictionary *orgVectors_;

#pragma mark - Constructor
-(id)init
{
	self = [super init];
	if(self) {
        [self initialize];
	}
	return self;
}
-(void)initialize
{
    NSArray *patterns = [self buildPatterns];
    NSAssert(patterns != nil, @"inherent class should build valid pattern. implement buildPatterns message of absPatternIdentifier class.");
       
       // build code book
	NSMutableDictionary *vectorCodeSetDict = [NSMutableDictionary dictionaryWithCapacity:30];
	NSMutableDictionary *stampIDDic = [NSMutableDictionary dictionaryWithCapacity:30];
	NSMutableDictionary *refVectDic = [NSMutableDictionary dictionaryWithCapacity:30];
	NSMutableDictionary *orgVectDic = [NSMutableDictionary dictionaryWithCapacity:30];
	int stampid=0;	
	for(NSArray *vectors in patterns) {
		NSUInteger cnt = [vectors count];
		stampid++;
		for(int j =0; j < cnt; j++) {
			//パターンの原点
			vector2d *orgVec = [vectors objectAtIndex:j];		
			for(int k=0; k < cnt; k++) {
				if(j == k) continue; // 基準ベクトルがない場合はコードブックに追加できないから、次に移行
				// パターンの基準ベクトル
				vector2d *kVec = [vectors objectAtIndex:k];
				vector2d *refVec = [vector2d sub:kVec b:orgVec]; //基準ベクトル
				// パターンのコード生成
				NSMutableArray *codes = [NSMutableArray arrayWithCapacity:3];
				for(int m=0; m< cnt; m++) {
					if(m == j) continue; // 原点とかぶるものは除外
					vector2d *mVec = [vectors objectAtIndex:m];
					vector2d *targetVec = [vector2d sub:mVec b:orgVec];
					[codes addObject:[vectorCode allocWithVectors:1.0 vector:targetVec referenceVector:refVec]];				
				}
				vectorCodeSet *codeSet = [vectorCodeSet allocWithVectorCodes:codes];
				// TODO 重複チェック
				[vectorCodeSetDict setObject:codeSet forKey:codeSet.hash];
				[stampIDDic setObject:[NSNumber numberWithInt:stampid] forKey:codeSet.hash];
				[refVectDic setObject:refVec forKey:codeSet.hash];
				[orgVectDic setObject:orgVec forKey:codeSet.hash];
			}
		}
	}
	templates_        = vectorCodeSetDict;
	stampIDs_         = stampIDDic;
	referenceVectors_ = refVectDic;
	orgVectors_       = orgVectDic;
}
#pragma mark - Abstract methods
// building patterns
-(NSArray *)buildPatterns
{  
    return nil;
}

#pragma mark - Public methods
-(stampInfo *)match:(int)unit cluster:(clusterVO *)clusterVO
{
	NSString *key = clusterVO.hash;
	vectorCodeSet *codeSet = [templates_ objectForKey:key];
	if(codeSet == nil) {
		return nil;
	}
	//スタンプ情報の算出
	int stampid = [[stampIDs_ objectForKey:key] intValue];
	//角度
	vector2d *refVec = [referenceVectors_ objectForKey:key];
    //	vector2d *orgVec = [orgVectors_ objectForKey:key];
	int angle = (int)[refVec angleBetween:clusterVO.referenceVector];
	// 位。中心点(1,1)を回転&角度長さで伸ばす
	float rad = 2 * M_PI * (float)angle / 360.0f;
	vector2d *pos = [[vector2d allocWithValues:(unit * cos(rad)) y:(unit *sin(rad))] add:clusterVO.origin];
    
	return [stampInfo allocWithValues:stampid position:pos angle:(int)angle];
}
@end
