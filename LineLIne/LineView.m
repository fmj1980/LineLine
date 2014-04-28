//
//  LineView.m
//  LineLIne
//
//  Created by fmj on 14-4-25.
//  Copyright (c) 2014年 fmj. All rights reserved.
//

#import "LineView.h"

@implementation LineCoordinate
-(id)initWith:(int)x y:(int)y
{
    if(self = [super init])
    {
        self.X = x;
        self.Y = y;
    }
    return self;
}
@end

@implementation LineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.selected) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(context, 6.0);
        CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextAddRect(context, rect);
        CGContextStrokePath(context);
    }
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self setNeedsDisplay];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
