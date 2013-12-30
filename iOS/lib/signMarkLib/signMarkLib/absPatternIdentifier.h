//
//  patternIdentifier.h
//  signMarkLib
//
//  Created by Uehara Akihiro on 11/10/03.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@class stampInfo, clusterVO;

// THIS IS ABSTRACT CLASS!! Implement buildPatterns message by yourself.
// パータンテンプレート情報保持と一致係数の算出
@interface absPatternIdentifier : NSObject
// テンプレートと完全に一致するベクタコードを取得。該当がない場合はnil
-(stampInfo *)match:(int)unit cluster:(clusterVO *)cluster;
@end
