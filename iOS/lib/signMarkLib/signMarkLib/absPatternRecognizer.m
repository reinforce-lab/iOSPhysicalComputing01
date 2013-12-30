//
//  absPatternRecognizer.m
//  signMarkLib
//
//  Created by Uehara Akihiro on 11/10/03.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "absPatternRecognizer.h"
#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "absPatternIdentifier.h"
#import "traceDistanceTable.h"

@interface absPatternRecognizer()

-(void)update:(UIEvent *)event;

// abstrace message
-(absPatternIdentifier *)allocPatternIdentifier;
-(void)identify:(NSArray *)allTouches;
@end

@implementation absPatternRecognizer
#pragma mark - Variables
NSArray *touches_;
NSSet *clusters_;
NSSet *stampInfo_;

#pragma mark - Properties
@synthesize touches    =touches_;
@synthesize clusters   =clusters_;
@synthesize stampInfo  =stampInfo_;
@dynamic unitLength;
-(void)setUnitLength:(int)unitLength
{
    unitLength_ = unitLength;
}
-(int)getUnitLength
{
    return unitLength_;
}

#pragma mark - Constructor
- (id)initWithTarget:(id)target action:(SEL)action unitLength:(int)unitLength
{
	self = [super initWithTarget:target action:action];
	if(self) {
        unitLength_ = unitLength;
		self.state = UIGestureRecognizerStatePossible;    
	}
	return self;
}

#pragma mark - Abstrace methods
// abstrace message
-(absPatternIdentifier *)allocPatternIdentifier
{
    return nil;
}
-(void)identify:(NSArray *)allTouches
{
    /*
    //    NSLog(@"%@", event); 
	traceDistanceTable *tbl = [self alloctraceDistanceTable:[[event allTouches] allObjects]];
    NSAssert(tbl != nil, @"absPatternRecognizer is ABSTRACT class. Implement allocTableDistanceTable message.");
	
    NSMutableSet *stamps = [NSMutableSet setWithCapacity:4];
	for(clusterVO *cluster in tbl.clusters) {
		stampInfo *stamp = [identifier_ match:unitLength_ cluster:cluster];
		if(stamp != nil) {
            //			NSLog(@"    stamp:%@", stamp);
			[stamps addObject:stamp];
		}
	}
	
	// update properties
	self.touches  = tbl.touches;
	self.clusters = tbl.clusters;
     self.stampInfo = stamps;
     */
}
#pragma mark - Private methods
-(void)update:(UIEvent *)event
{	 
    [self identify:[[event allTouches] allObjects]];
    
	// update state
    if([self.touches count] <= 0) { // タッチ点がなければ、状態終了もしくは開始可能に遷移。
        switch (self.state) {
            case UIGestureRecognizerStateEnded:
                self.state = UIGestureRecognizerStatePossible;
                break;
            default:
                self.state = UIGestureRecognizerStateEnded;
                break;
        }
    } else {
		switch (self.state) {
			case UIGestureRecognizerStatePossible: // 可能状態。スタンプがあれば開始に遷移
                if([self.stampInfo count] > 0) {
                    self.state = UIGestureRecognizerStateBegan;
                }
				break;
			case UIGestureRecognizerStateBegan:
			case UIGestureRecognizerStateChanged:
				if([self.stampInfo count] > 0) {
					self.state = UIGestureRecognizerStateChanged;
				} else {
                    self.state = UIGestureRecognizerStateEnded;
                }
				break;
			default:
                self.state = UIGestureRecognizerStatePossible;
				break;
		}
	}
    //	NSLog(@"  gesture state: %d", self.state);
}
#pragma mark - Override methods
//- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer;
//- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer;
-(void)reset
{
    //	NSLog(@"%s", __func__);
	[super reset];
	self.touches   = nil;
	self.clusters  = nil;
	self.stampInfo = nil;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self update:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self update:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self update:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self update:event];
}
@end
