//
//  absPatternRecognizer.h
//  signMarkLib
//
//  Created by Uehara Akihiro on 11/10/03.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UIGestureRecognizer;

@interface absPatternRecognizer : UIGestureRecognizer
{
@protected
    int unitLength_;    
}
// タッチ点。vector2dの配列。
@property (nonatomic, strong) NSArray *touches;
// クラスタ配列。clusterVOの配列。
@property (nonatomic, strong) NSSet *clusters;
// スタンプ情報配列。stampInfoの配列。
@property (nonatomic, strong) NSSet *stampInfo;

@property (nonatomic, assign, setter = setUnitLength:, getter=getUnitLength) int unitLength;

- (id)initWithTarget:(id)target action:(SEL)action unitLength:(int)unitLength;
@end
