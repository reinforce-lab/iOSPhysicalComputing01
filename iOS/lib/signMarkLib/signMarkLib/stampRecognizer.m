//
//  stampRecognizer.m
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/18.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import "stampRecognizer.h"
#import "stampIdentifier.h"
#import "stampInfo.h"
#import "traceDistanceTable.h"

@implementation stampRecognizer
#pragma mark - Variables
stampIdentifier *identifier_;

#pragma mark - Constructor
- (id)initWithTarget:(id)target action:(SEL)action unitLength:(int)unitLength
{
    self = [super initWithTarget:target action:action unitLength:unitLength];
    if(self) {
        identifier_ = [[stampIdentifier alloc] init];
    }
    return self;
}

#pragma mark - Abstract methods
-(void)identify:(NSArray *)allTouches
{
//    NSLog(@"%@", allTouches);
    traceDistanceTable *tbl = [[traceDistanceTable alloc] initWithTouches:allTouches unitLengthInPixel:unitLength_ numOfPoints:3]; // MAGIC word
    
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
