//
//  touchesView.m
//  TouchStamp
//
//  Created by 昭宏 上原 on 12/05/29.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "touchesView.h"
#import "stampRecognizer.h"
#import "vector2d.h"
#import "clusterVO.h"

#define MARK_SIZE 24

@implementation touchesView {    
    absPatternRecognizer *recognizer_;
    CGAffineTransform transform_;
    //	float xscale_, yscale_;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark -
-(void)drawRect:(CGRect)rect
{
    // measure viewを上下に2つ置いている。
    // 下のViewはframeの原点を引き算するだけでよいが、上のViewはさらにViewの高さも引き算しないとだめ。
    // 2つを区別するのにフレームのy座標が240を超えているかどうかで切り分ける。
    CGFloat dy = 0;
    if( self.frame.origin.y < 240 ) { // 上のView
        dy = self.frame.origin.y + self.frame.size.height;
    } else { // 下のView
        dy = self.frame.origin.y;
        
    }
    
	// 描画領域のクリア
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextConcatCTM(ctx, transform_);
    
	CGContextSetRGBFillColor(ctx,   1.0, 1.0, 1.0, 0.0); // fill clear
	CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, 0.0); // stroke transparent
	CGContextFillRect(ctx, self.bounds);
    
    // クラスタ領域の描画
    /*
	CGContextSetRGBStrokeColor(ctx, 0, 1.0, 0, 0.8); // stroke green
	CGContextSetLineWidth(ctx, 4);
	for(clusterVO *cluster in recognizer_.clusters) {		
        //		CGRect r = cluster.circumscribeRect;
        //		rect = CGRectMake(xscale_ * r.origin.x, yscale_ *r.origin.y, xscale_ * r.size.width, yscale_ *r.size.height);
        //		CGContextStrokeRect(ctx, rect);		
        CGContextStrokeRect(ctx, cluster.circumscribeRect);
	}*/
    
	// タッチ点の描画
	CGContextSetRGBFillColor(ctx, 204.0 / 255.0 , 209.0 / 255.0, 228 / 255.0, 1.0); // fill green 
	for(vector2d *pt in recognizer_.touches) {
        //		rect = CGRectMake(xscale_ * pt.x -MARK_SIZE/2, yscale_ * pt.y -MARK_SIZE/2, MARK_SIZE, MARK_SIZE);
        //		CGContextFillRect(ctx, rect);
		rect = CGRectMake(pt.x -MARK_SIZE/2, pt.y -MARK_SIZE/2 -dy, MARK_SIZE, MARK_SIZE);
        CGContextFillRect(ctx, rect);        
	}
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == nil) {
        [self setNeedsDisplay];        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Public methods
-(void)setRecognizer:(absPatternRecognizer *)recognizer
{    
    transform_ = CGAffineTransformIdentity;  
    /*
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
  
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        transform_ = CGAffineTransformScale(transform_, CGRectGetWidth(self.frame)  / CGRectGetHeight(appFrame),CGRectGetHeight(self.frame) / CGRectGetWidth(appFrame));
        transform_ = CGAffineTransformTranslate(transform_, 0, CGRectGetWidth(appFrame));
        //        NSLog(@"appFrame width %d", (int)CGRectGetWidth(appFrame));
        transform_ = CGAffineTransformRotate(transform_, -0.5 * M_PI);
        //        transform_ = CGAffineTransformTranslate(transform_, 200, 200);
        //        transform_ = CGAffineTransformTranslate(transform_, 700, 700);//0, CGRectGetWidth(appFrame));
        //      transform_ = CGAffineTransformScale(transform_, CGRectGetWidth(self.frame)  / CGRectGetWidth(appFrame),CGRectGetHeight(self.frame) / CGRectGetHeight(appFrame));        
        //        transform_ = CGAffineTransformScale(transform_, CGRectGetWidth(self.frame)  / CGRectGetWidth(appFrame),CGRectGetHeight(self.frame) / CGRectGetHeight(appFrame));
    } else { // iphone
        transform_ = CGAffineTransformScale(transform_, CGRectGetWidth(self.frame)  / CGRectGetWidth(appFrame),CGRectGetHeight(self.frame) / CGRectGetHeight(appFrame));
    }
    */
    recognizer_ = recognizer;
    [recognizer_ addObserver:self forKeyPath:@"touches" options:NSKeyValueObservingOptionNew context:nil];
}
@end
