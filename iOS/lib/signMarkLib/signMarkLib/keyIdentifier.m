//
//  stampIdentifier.m
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/13.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import "keyIdentifier.h"
#import "vector2d.h"

@implementation keyIdentifier
#pragma mark - Abstract method
-(NSArray *)buildPatterns
{
	// stamp patterns
	NSMutableArray *patterns = [NSMutableArray arrayWithCapacity:30];						 
	[patterns addObject:[NSArray arrayWithObjects: 
                         [vector2d allocWithValues:0 y:0], 
                         [vector2d allocWithValues:1 y:0], 
                         [vector2d allocWithValues:2 y:0], 
                         nil]];

    return patterns;
}
@end
