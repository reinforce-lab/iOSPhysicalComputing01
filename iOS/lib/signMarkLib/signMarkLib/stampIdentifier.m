//
//  stampIdentifier.m
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/13.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import "stampIdentifier.h"
#import "vector2d.h"
#import "clusterVO.h"
#import "stampInfo.h"
#import "vectorCode.h"
#import "vectorCodeSet.h"

@implementation stampIdentifier
#pragma mark - Abstract methods
// building patterns
-(NSArray *)buildPatterns
{
	NSMutableArray *patterns = [NSMutableArray arrayWithCapacity:30];
	[patterns addObject:[NSArray arrayWithObjects: [vector2d allocWithValues:0 y:0], [vector2d allocWithValues:0 y:3], [vector2d allocWithValues:2 y:3] ,nil]];
    [patterns addObject:[NSArray arrayWithObjects: [vector2d allocWithValues:0 y:0], [vector2d allocWithValues:0 y:3], [vector2d allocWithValues:4 y:3] ,nil]];
    [patterns addObject:[NSArray arrayWithObjects: [vector2d allocWithValues:0 y:0], [vector2d allocWithValues:0 y:3], [vector2d allocWithValues:2 y:0] ,nil]];
    [patterns addObject:[NSArray arrayWithObjects: [vector2d allocWithValues:0 y:0], [vector2d allocWithValues:0 y:3], [vector2d allocWithValues:4 y:0] ,nil]];
    [patterns addObject:[NSArray arrayWithObjects: [vector2d allocWithValues:0 y:0], [vector2d allocWithValues:2 y:3], [vector2d allocWithValues:4 y:3] ,nil]];
    [patterns addObject:[NSArray arrayWithObjects: [vector2d allocWithValues:0 y:0], [vector2d allocWithValues:2 y:3], [vector2d allocWithValues:4 y:0] ,nil]];
    
    return patterns;
}

@end
