//
//  measureView.m
//  TouchStamp
//
//  Created by 昭宏 上原 on 12/05/30.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "measureView.h"
#import "stampRecognizer.h"

#import "vector2d.h"
#import "clusterVO.h"

#define MARK_SIZE 24

@implementation measureView {
    absPatternRecognizer *recognizer_;
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
    
	CGContextRef ctx = UIGraphicsGetCurrentContext();

    // 描画領域のクリア
	CGContextSetRGBFillColor(ctx,   1.0, 1.0, 1.0, 0.0); // fill clear
	CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, 0.0); // stroke transparent
	CGContextFillRect(ctx, self.bounds);
    
    // タッチ点は2以上か？
    if(recognizer_.touches.count >=2 ) {    
        // 直線の描画
        vector2d *p1 = [recognizer_.touches objectAtIndex:0];
        vector2d *p2 = [recognizer_.touches objectAtIndex:1];
        CGContextSetLineWidth(ctx, 8); // 線分の太さ
        CGContextSetRGBStrokeColor(ctx, 1.0, 0.1, 0.1, 0.8); // 赤色
        CGContextMoveToPoint(ctx, p1.x, p1.y - dy); // 始点
        CGContextAddLineToPoint(ctx, p2.x, p2.y - dy); // 終点
        CGContextStrokePath(ctx);
    }
    
	// タッチ点の描画
    CGContextSetLineWidth(ctx, 0); // 線分の太さ
	CGContextSetRGBFillColor(ctx, 204.0 / 255.0 , 209.0 / 255.0, 228 / 255.0, 1.0); // fill green 
    for(vector2d *pt in recognizer_.touches) {
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
    recognizer_ = recognizer;
    [recognizer_ addObserver:self forKeyPath:@"touches" options:NSKeyValueObservingOptionNew context:nil];
}

@end
