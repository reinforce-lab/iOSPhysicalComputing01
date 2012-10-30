//
//  vectorCodeSet.h
//  signMarkLib
//
//  Created by 上原 昭宏 on 11/07/13.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import <Foundation/Foundation.h>

// VectorCodeの配列を保持するVOの基底クラス。
// 一致処理の基本を提供。ハッシュ値やソーティングなど、情報をまとめる。一致処理それ自体。
@interface vectorCodeSet : NSObject
//vectorCodeの配列
@property (nonatomic, strong, readonly) NSArray *vectorCodes;
//vectorCode配列のハッシュ文字列
@property (nonatomic, strong, readonly) NSString *hash;

+(id)allocWithVectorCodes:(NSArray *)vectorCodes;
-(id)initWithVectorCodes:(NSArray *)vectorCodes;
-(BOOL)isMatch:(vectorCodeSet *)codeSet;
@end
