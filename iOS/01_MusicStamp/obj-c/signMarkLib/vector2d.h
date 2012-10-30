//
//  vector2d.h
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/15.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 2次元ベクトルクラス
@interface vector2d : NSObject 

@property (nonatomic, readonly) float x;
@property (nonatomic, readonly) float y;
@property (nonatomic, readonly, getter=getLength) float length;

+(id)allocWithValues:(float)x y:(float)y;
-(id)initWithCGPoint:(CGPoint)point;
-(id)initWithValues:(float)x y:(float)y;


+(vector2d *)add:(vector2d *)a b:(vector2d *)b;
+(vector2d *)sub:(vector2d *)a b:(vector2d *)b;
+(float)innerProduct:(vector2d *)a b:(vector2d *)b;
+(float)angleBetween:(vector2d *)a b:(vector2d *)b;

-(vector2d *)add:(vector2d *)a;
-(vector2d *)sub:(vector2d *)a;
-(float)innerProduct:(vector2d *)vect;
// 単位はdeg
-(float)angleBetween:(vector2d *)vect;
@end
