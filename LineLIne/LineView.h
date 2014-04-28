//
//  LineView.h
//  LineLIne
//
//  Created by fmj on 14-4-25.
//  Copyright (c) 2014年 fmj. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LineCoordinate :NSObject

-(id)initWith:(int)x y:(int)y;
@property(nonatomic) int X;
@property(nonatomic) int Y;

@end

@interface LineView : UIView

@property(nonatomic) LineCoordinate* coordinate;

@property(nonatomic) BOOL selected;

@end
