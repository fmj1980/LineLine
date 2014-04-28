//
//  LineLineViewController.m
//  LineLIne
//
//  Created by fmj on 14-4-25.
//  Copyright (c) 2014年 fmj. All rights reserved.
//

#import "LineLineViewController.h"
#import "LineView.h"

#define LINE_ROW_COUNT      8
#define LINE_COLUMN_COUNT   7
#define LINE_SIZE  40
#define LINE_MAC_DIRECTION_COUNT 3

typedef NS_OPTIONS(NSInteger,LINE_DIRECTION)
{
    LINE_DIRECTION_NONE = 0,
    LINE_DIRECTION_UP,
    LINE_DIRECTION_RIGHT,
    LINE_DIRECTION_DOWN,
    LINE_DIRECTION_LEFT,
};

@interface LineLineViewController ()
{
    NSArray* _arryColors;
    LineView* _lines[LINE_ROW_COUNT][LINE_COLUMN_COUNT];
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic) LineView* preViousView;
@end

@implementation LineLineViewController


- (void)viewDidLoad
{
    _arryColors = @[ [UIColor redColor],[UIColor blueColor],[UIColor greenColor],[UIColor yellowColor],[UIColor purpleColor],[UIColor blackColor],[UIColor orangeColor],[UIColor cyanColor],[UIColor grayColor],[UIColor magentaColor]];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self newGame];
    
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressHandler:)];
    longPressGesture.minimumPressDuration = 0.01;
    [self.scrollView addGestureRecognizer:longPressGesture];
}

-(void)newGame
{
    [self initLineViews];
    [self randomLineViews];
}

-(void)initLineViews
{
    _preViousView = nil;
    for(UIView *subView in [self.scrollView subviews]){
        [subView removeFromSuperview];
    }
    int colorIndex = 0;
    BOOL even = YES;
    for(int i = 0; i < LINE_ROW_COUNT; i++) {
        for(int j = 0; j < LINE_COLUMN_COUNT; j++) {
            CGRect rect = CGRectMake( LINE_SIZE*j+10 , LINE_SIZE*i+10, LINE_SIZE, LINE_SIZE);
            LineView *view = [[LineView alloc] initWithFrame:rect];
            _lines[i][j] = view;
            [self.scrollView addSubview: view];
            
            view.backgroundColor = [_arryColors objectAtIndex:colorIndex];
            if (even) {
                even = NO;
            }
            else
            {
                view.backgroundColor = [_arryColors objectAtIndex:colorIndex];
                colorIndex ++;
                if (colorIndex>=_arryColors.count) {
                    colorIndex = 0;
                }
                even = YES;
            }
        }
    }
    self.scrollView.contentSize = CGSizeMake(LINE_SIZE*LINE_COLUMN_COUNT+40, LINE_SIZE*LINE_ROW_COUNT +40);
}

-(void)randomLineViews
{
    for(int i = 0; i < LINE_ROW_COUNT; i++) {
        for(int j = 0; j < LINE_COLUMN_COUNT; j++) {
            int randomRow = arc4random() % LINE_ROW_COUNT;
            int randdomColumn = arc4random() % LINE_COLUMN_COUNT;
            UIColor* color = _lines[randomRow][randdomColumn].backgroundColor;
            _lines[randomRow][randdomColumn].backgroundColor = _lines[i][j].backgroundColor;
            _lines[i][j].backgroundColor = color;
        }
    }
    for(int i = 0; i < LINE_ROW_COUNT; i++) {
        for(int j = 0; j < LINE_COLUMN_COUNT; j++) {
             LineView* view = _lines[i][j];
            LineCoordinate* coordinate = [LineCoordinate new];
            coordinate.X = i;
            coordinate.Y = j;
            view.coordinate = coordinate;
        }
    }
}


-(void)pressHandler:(UILongPressGestureRecognizer*)recognizer
{
    CGPoint pressPoint = [recognizer locationInView:self.scrollView];
    if ( recognizer.state != UIGestureRecognizerStateBegan ) {
        return;
    }
    NSLog(@"pressPoint:%f,%f",pressPoint.x,pressPoint.y);
    LineView* touchView = nil;
    for(int i = 0; i < LINE_ROW_COUNT; i++) {
        for(int j = 0; j < LINE_COLUMN_COUNT; j++) {
            LineView* view = _lines[i][j];
            if(view== nil) continue;
            if (CGRectContainsPoint(view.frame,pressPoint)) {
                touchView = view;
            }
        }
    }
    if (touchView == nil || self.preViousView == touchView) {
        return;
    }
    NSLog(@"touchColor:%@",touchView.backgroundColor);
    if (self.preViousView == nil ) {
        self.preViousView = touchView;
        return;
    }
    if (self.preViousView.backgroundColor != touchView.backgroundColor) {
        self.preViousView = nil;
        return;
    }
    NSMutableArray* paths = [NSMutableArray new];
    [paths addObject:self.preViousView.coordinate];
    
    NSLog(@"start:");
    if ([self canReach:self.preViousView.coordinate to:touchView.coordinate paths:paths]) {
        [self.preViousView setBackgroundColor:[UIColor whiteColor]];
        [touchView setBackgroundColor:[UIColor whiteColor]];
        _lines[self.preViousView.coordinate.X][self.preViousView.coordinate.Y]=nil;
        _lines[touchView.coordinate.X][touchView.coordinate.Y]=nil;
        if ([self isWin]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"WINNER" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [self newGame];
        }
    }
    NSLog(@"end:");
    self.preViousView = nil;
}

-(BOOL) isWin
{
    for(int i = 0; i < LINE_ROW_COUNT; i++) {
        for(int j = 0; j < LINE_COLUMN_COUNT; j++) {
            if (_lines[i][j]) {
                return NO;
            }
        }
    }
    return YES;
}
-(BOOL)canReach:(LineCoordinate*)from to:(LineCoordinate*)to paths:(NSMutableArray*)paths
{
#define OPTIMIZE 1
#if OPTIMIZE
    int directions[4][2];
    if (to.Y == from.Y) {
        if (to.X >from .X) {
            int tem[4][2] = {{1,0},{0,1},{0,-1},{-1,0}};
            memcpy(directions, tem, sizeof(tem));
        }
        else
        {
            int tem[4][2] = {{-1,0},{0,1},{0,-1},{1,0}};
            memcpy(directions, tem, sizeof(tem));
        }
    }
    else if(to.X == from.X )
    {
        if (to.Y>from.Y) {
            int tem[4][2] = {{0,1},{1,0},{0,-1},{-1,0}};
            memcpy(directions, tem, sizeof(tem));
        }
        else
        {
            int tem[4][2] = {{-1,0},{0,-1},{1,0},{0,1}};
            memcpy(directions, tem, sizeof(tem));
        }
    }
    else if (to.X>from.X ) {
        if (to.Y>from.Y) {
            int tem[4][2] = {{0,1},{1,0},{0,-1},{-1,0}};
            memcpy(directions, tem, sizeof(tem));
        }
        else
        {
            int tem[4][2] = {{0,1},{-1,0},{1,0},{0,-1}};
            memcpy(directions, tem, sizeof(tem));
        }
    }
    else
    {
        if (to.Y>from.Y) {
            int tem[4][2] = {{0,-1},{1,0},{0,1},{-1,0}};
            memcpy(directions, tem, sizeof(tem));
        }
        else
        {
            int tem[4][2] = {{0,-1},{-1,0},{0,1},{1,0}};
            memcpy(directions, tem, sizeof(tem));
        }
    }
   
    for (int i =0; i<4; i++) {
        if ([self canReach:from to:to paths:paths coordinate:[[LineCoordinate alloc] initWith:(from.X+directions[i][0]) y:from.Y+directions[i][1]]]) {
            return YES;
        }
    }
#else
    if ([self canReach:from to:to paths:paths coordinate:[[LineCoordinate alloc] initWith:from.X-1 y:from.Y]]) {
        return YES;
    }
    if ([self canReach:from to:to paths:paths coordinate:[[LineCoordinate alloc] initWith:from.X+1 y:from.Y]]) {
        return YES;
    }
    if ([self canReach:from to:to paths:paths coordinate:[[LineCoordinate alloc] initWith:from.X y:from.Y+1]]) {
        return YES;
    }
    if ([self canReach:from to:to paths:paths coordinate:[[LineCoordinate alloc] initWith:from.X y:from.Y-1]]) {
        return YES;
    }
#endif
    return NO;
}

-(BOOL)canReach:(LineCoordinate*)from to:(LineCoordinate*)to paths:(NSMutableArray*)paths coordinate:(LineCoordinate*)coordinate
{
    //已经走过的路径不再处理
    for (LineCoordinate* path in paths) {
        if (coordinate.X == path.X && coordinate.Y == path.Y) {
            return NO;
        }
    }
    //超过范围的路径不再处理
    if (coordinate.X < -1 || coordinate.Y < -1 || coordinate.X > LINE_ROW_COUNT || coordinate.Y>LINE_COLUMN_COUNT){
        return NO;
    }
    //当前View如果不为NULL 则不再处理
    if ( !(coordinate.X == to.X && coordinate.Y == to.Y) ) {
        if (coordinate.X >=0 && coordinate.Y >=0 && coordinate.X< LINE_ROW_COUNT && coordinate.Y < LINE_COLUMN_COUNT) {
            LineView* view = _lines[coordinate.X][coordinate.Y];
            if (view != nil ) {
                return NO;
            }
        }
    }
    
    NSMutableArray* newPaths = [[NSMutableArray alloc] initWithArray:paths];
    [newPaths addObject:coordinate];
    
    //超过方向改变指定次数的不再处理
    int directionCount =[self directionCount:newPaths];
    if (directionCount>LINE_MAC_DIRECTION_COUNT) {
        return NO;
    }

    if (coordinate.X == to.X && coordinate.Y == to.Y) {
        for (LineCoordinate* path in newPaths) {
            NSLog(@"PATH:%d,%d",path.X,path.Y);
        }
        return YES;
    }
    
    return [self canReach:coordinate to:to paths:newPaths];
}

-(int)directionCount:(NSArray*)paths
{
    int directionCount = 0;
    LINE_DIRECTION preDirection = LINE_DIRECTION_NONE;
    for (int index=1; index<paths.count; index++) {
        LineCoordinate* currentCoordinate = [paths objectAtIndex:index];
        LineCoordinate* preCoordinate = [paths objectAtIndex:(index-1)];
        LINE_DIRECTION currentDirection;
        if (preCoordinate.X == currentCoordinate.X ) {
            if (preCoordinate.Y >currentCoordinate.Y) {
                currentDirection = LINE_DIRECTION_UP;
            }
            else
            {
                currentDirection = LINE_DIRECTION_DOWN;
            }
        }
        else
        {
            if (preCoordinate.X >currentCoordinate.X) {
                currentDirection = LINE_DIRECTION_LEFT;
            }
            else
            {
                currentDirection = LINE_DIRECTION_RIGHT;
            }
        }
        if (currentDirection!= preDirection) {
            directionCount++;
        }
        
        preDirection = currentDirection;
    }
    return directionCount;
}

- (IBAction)btnNewGameClicked:(id)sender {
    [self newGame];
}

-(void)setPreViousView:(LineView *)preViousView
{
    if (_preViousView != nil) {
        _preViousView.selected = NO;
    }
    _preViousView = preViousView;
    [_preViousView setSelected:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
