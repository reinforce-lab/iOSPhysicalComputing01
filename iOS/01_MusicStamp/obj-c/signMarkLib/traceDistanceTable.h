//
//  traceDistanceTable.h
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/13.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import <Foundation/Foundation.h>

// 任意のトレース感の距離テーブル、距離に基づくクラスタ情報
// 点間の距離計算を繰り返すムダを省くためのテーブル
@interface traceDistanceTable : NSObject
// スタンプの基準単位の長さ(単位 ピクセル)
@property (nonatomic, readonly) int unitLengthInPixel;
// 接点 vector2dの配列
@property (nonatomic, strong, readonly) NSArray *touches;
//vectorCodeのArrayの集合
@property (nonatomic, strong, readonly) NSSet* clusters;

// UITouchの配列
-(id)initWithTouches:(NSArray*)touches unitLengthInPixel:(int)unitLengthInPixel numOfPoints:(int)numOfPoints;

// 2点間の距離を求める。数値はtouchPointsのインデックス値
-(int)getDistance:(int)a b:(int)b;
-(int)getDistanceCode:(int)a b:(int)b;
@end
