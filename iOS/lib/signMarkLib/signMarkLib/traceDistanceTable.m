//
//  traceDistanceTable.m
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/13.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import "traceDistanceTable.h"
#import "vectorCode.h"
#import "vector2d.h"
#import "clusterVO.h"

@interface traceDistanceTable ()
-(void)initialize:(NSArray *)touches;
-(void)initVectors:(NSArray *)touches;
-(void)initTable;
-(void)setClusterVO;
@end

@implementation traceDistanceTable
#pragma mark - Variables
int unitLengthInPixel_;
int numOfPoints_;

NSArray *touches_;
NSArray *distances_;
NSArray *distanceCode_;
NSSet   *clusters_;

#pragma mark - Properties
@synthesize unitLengthInPixel = unitLengthInPixel_;
@synthesize touches = touches_;
@synthesize clusters = clusters_;

#pragma mark - Constructor
-(id)initWithTouches:(NSArray*)touches unitLengthInPixel:(int)unitLengthInPixel numOfPoints:(int)numOfPoints
{
	self = [super init];
	if(self) {
		unitLengthInPixel_ = unitLengthInPixel;
        numOfPoints_ = numOfPoints;
		[self initialize:touches];
	}
	return self;
}

#pragma mark - Private methods
-(void)initialize:(NSArray *)touches
{
	[self initVectors:touches];
	[self initTable];
	[self setClusterVO];
}
// タッチ点を保存
-(void)initVectors:(NSArray *)touches
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:[touches count]];
	for(UITouch *touch in touches)  {
        if(touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            CGPoint pt = [touch locationInView:nil];
            [array addObject:[[vector2d alloc] initWithCGPoint:pt]];
        }
	}
	touches_ = array;
//    NSLog(@"%@", touches_);
}
-(void)initTable
{
	// タッチ間の距離とコードを設定
	NSUInteger cnt = [touches_ count];
	NSMutableArray *distTable     = [NSMutableArray arrayWithCapacity:cnt];
	NSMutableArray *distCodeTable = [NSMutableArray arrayWithCapacity:cnt];
	for(int i=0; i < cnt; i++) {
		NSMutableArray *dTbl     = [NSMutableArray arrayWithCapacity:cnt];
		NSMutableArray *dCodeTbl = [NSMutableArray arrayWithCapacity:cnt];
		for(int j=0; j < cnt; j++) {
			// ベクトルの差分
			vector2d *v1 = [touches_ objectAtIndex:i];
			vector2d *v2 = [touches_ objectAtIndex:j];
			vector2d *vdiff = [vector2d sub:v1 b:v2];
			// 距離
			int length = (int)vdiff.length;
			int code = [vectorCode getLengthCode:unitLengthInPixel_ length:length];
			[dTbl addObject:[NSNumber numberWithInt:length]];
			[dCodeTbl addObject:[NSNumber numberWithInt:code]];
		}
		// 配列をテーブル配列に追加
		[distTable addObject:dTbl];
		[distCodeTable addObject:dCodeTbl];
	}
	// テーブル配列を保持
	distances_    = distTable;
	distanceCode_ = distCodeTable;
	
/*	NSLog(@"%s", __func__);
	NSLog(@"ditances %@", distances_);
	NSLog(@"distance codes %@",distanceCode_);*/
}
// 距離のカテゴリ1-4のものをクラスタ化
-(void)setClusterVO
{
	NSUInteger cnt = [touches_ count];
	int clusterTable[cnt];
	int clusterCnt = 1;
	
	NSMutableArray *arrayList = [NSMutableArray arrayWithCapacity:cnt];
	memset(clusterTable, 0, cnt * sizeof(int));
	
	for(int i=0; i < cnt; i++) {
		int cid = clusterTable[i];
		// クラスタ番号割り当て
		if(cid ==0) {
			cid =clusterCnt++;
		}
		NSMutableArray *list = [NSMutableArray arrayWithCapacity:cnt];
		NSArray *ithCodes = [distanceCode_ objectAtIndex:i];
		// 対角要素も含めて距離判定が閾値以下のものを配列に追加。ついでにクラスタ対角要素にcidを設定。
		for(int j=i; j < cnt; j++) {
			int code = [[ithCodes objectAtIndex:j] intValue];
			if(code <= 8) { // MAGIC NUMBER 距離コード4以下をクラスタとする
				if(clusterTable[j] == 0) { // 重複カウント(jの点に対して近い場合の重複カウントを防止
					[list addObject:[NSNumber numberWithInt:j]];
					clusterTable[j] = cid;
				}
			}
		}
		[arrayList addObject:list];
	}
	
/*	NSLog(@"%s", __func__);
	NSLog(@"distance code: %@", distanceCode_);
	NSLog(@"cluster: %@", arrayList);*/
	
	// clusters に変換								
    NSMutableSet *mset = [NSMutableSet setWithCapacity:cnt];
	for(NSArray *list in arrayList) {
        // 規定点数のものだけをフィルタリング
		if([list count] == numOfPoints_) {
			clusterVO *vo = [[clusterVO alloc] initWithIndices:self indices:list];
			[mset addObject:vo];
		}
	}
    clusters_ = mset;
}
#pragma mark - Public methods
-(int)getDistance:(int)a b:(int)b
{
	// aがbより小さくなるようにスワップ
	if(a > b) {
		int c = a;
		a = b;
		b = c;
	}
	NSAssert(b < [distances_ count], @"配列外へのアクセス");
	return [[[distances_ objectAtIndex:a] objectAtIndex:b] intValue];
}
-(int)getDistanceCode:(int)a b:(int)b
{
	// aがbより小さくなるようにスワップ
	if(a > b) {
		int c = a;
		a = b;
		b = c;
	}
	NSAssert(b < [distanceCode_ count], @"配列外へのアクセス");
	return [[[distanceCode_ objectAtIndex:a] objectAtIndex:b] intValue];
}
@end
