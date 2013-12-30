//
//  clusterVO.h
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/15.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "vectorCodeSet.h"
#import "vector2d.h"

// 接触点の集合であるクラスタのValueObject
@class traceDistanceTable;
@interface clusterVO : vectorCodeSet 

// 原点となる接触点
@property (nonatomic, strong, readonly) vector2d *origin;
// 基準となるベクトル
@property (nonatomic, strong, readonly) vector2d *referenceVector;
// 接触点を内包する領域
@property (nonatomic, readonly) CGRect circumscribeRect;

-(id)initWithIndices:(traceDistanceTable *)table indices:(NSArray *)indices;
@end
