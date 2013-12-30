//
//  keyRecognizer.m
//  signMarkLib
//
//  Created by Uehara Akihiro on 11/10/03.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "keyRecognizer.h"
#import "keyIdentifier.h"
#import "stampInfo.h"
#import "traceDistanceTable.h"

@implementation keyRecognizer
#pragma mark - Variables
keyIdentifier *identifier_;
#pragma mark - Constructor
- (id)initWithTarget:(id)target action:(SEL)action unitLength:(int)unitLength 
{
    self = [super initWithTarget:target action:action unitLength:unitLength];
    if(self) {
        identifier_ = [[keyIdentifier alloc] init];
    }
    return self;
}
#pragma mark - Abstract methods
-(void)identify:(NSArray *)allTouches
{
//    NSLog(@"%@", allTouches);
    traceDistanceTable *tbl = [[traceDistanceTable alloc] initWithTouches:allTouches unitLengthInPixel:unitLength_ numOfPoints:3];
    
    NSMutableSet *stamps = [NSMutableSet setWithCapacity:4];
    for(clusterVO *cluster in tbl.clusters) {
        stampInfo *stamp = [identifier_ match:unitLength_ cluster:cluster];
        if(stamp != nil) {
            // NSLog(@"    stamp:%@", stamp);
            [stamps addObject:stamp];
        }
    }
    
    // update properties        
    self.touches   = tbl.touches;
    self.clusters  = tbl.clusters;
    self.stampInfo = stamps;    
}
@end
