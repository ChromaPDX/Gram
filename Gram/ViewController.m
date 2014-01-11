//
//  ViewController.m
//  Gram
//
//  Created by Robby Kraft on 12/20/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    NSMutableDictionary *consumptions;
    float width, height;
    UIScrollView *scrollView;
    float margin;
    UILabel *dateLabel;
    bool dateFader;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self getDate];
    width = [[UIScreen mainScreen] bounds].size.width;
    height = [[UIScreen mainScreen] bounds].size.height;
    margin = [[UIScreen mainScreen] bounds].size.width / 24.;
    // load data
    
    NSArray *imageNames = @[@"coffee", @"water", @"drink", @"meal-sm", @"meal-reg", @"meal-lg", @"dessert", @"snack", @"junkfood"];
    
    consumptions = [[[NSUserDefaults standardUserDefaults] objectForKey:@"consumptions"] mutableCopy];
    if(consumptions == nil){
        consumptions = [NSMutableDictionary dictionary];
        [[NSUserDefaults standardUserDefaults] setObject:consumptions forKey:@"consumptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSLog(@"CONSUMPTIONS (%d): %@",[consumptions count],consumptions);

    NSLog(@"%@",[consumptions sortedValues]);
    // build interface
    
    for(int i = 0; i < 9; i++){
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(margin + (i%3)*width/3.,
                                                                      margin + (height-width)*.5 + floor(i/3.) * width/3.,
                                                                      width/3.-margin*2,
                                                                      width/3.-margin*2)];
        [button setBackgroundColor:[UIColor colorWithHue:i/9. saturation:1.0 brightness:1.0 alpha:1.0]];
        [button setTag:i];
        [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imageNames[i]]] forState:UIControlStateNormal];
        [button.layer setCornerRadius:width/6.-margin];
        [self.view addSubview:button];
    }
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, margin, width, (height-width)*.5 )];
    [dateLabel setFont:[UIFont boldSystemFontOfSize:48]];
    [dateLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:dateLabel];
    dateFader = false;
   
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, (height-width)*.5 + width, width, (height-width)*.5)];
    [scrollView setDelegate:self];
    [scrollView setPagingEnabled:true];
    [scrollView setShowsHorizontalScrollIndicator:false];
    [self.view addSubview:scrollView];
    [self refreshScrollView];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!dateFader){
        dateFader = true;
        [dateLabel setText:@""];
    }
}
//-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    NSLog(@"scrollViewWillBeginDragging");
//}
//-(void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    NSLog(@"scrollViewWillEndDragging");
//}
-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidEndScrollingAnimation");
    dateFader = false;
}
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scroll{
    dateFader = false;
    [dateLabel setText:[self formattedDate:[[consumptions sortedKeys] objectAtIndex:[scroll currentPage]]]];
}

-(void)refreshScrollView{
    [[scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSArray *sortedConsumptions = [consumptions sortedValues];
    [scrollView setContentSize:CGSizeMake(width*[sortedConsumptions count], (height-width)*.5)];
    for(int i = 0; i < [sortedConsumptions count]; i++){
        UIImage *graph = [self getImage:[sortedConsumptions objectAtIndex:i]];
        UIImageView *graphView = [[UIImageView alloc] initWithFrame:CGRectMake(width*(i), 0, width, (height-width)*.5)];
        [graphView setImage:graph];
        [scrollView addSubview:graphView];
    }
    if([sortedConsumptions count]){
        [scrollView scrollRectToVisible:CGRectMake(([sortedConsumptions count]-1)*width, 0, width, (height-width)*.5) animated:YES];
        [dateLabel setText:[self formattedDate:[[consumptions sortedKeys] objectAtIndex:[sortedConsumptions count]-1]]];
    }
}

-(void) buttonPress:(UIButton*)sender{
    // get the array of today's data
    if([consumptions objectForKey:[self getDate]] == nil){
        NSMutableArray *newEntry = [NSMutableArray array];
        [consumptions setObject:newEntry forKey:[self getDate]];
    }
    NSMutableArray *todaysData = [[consumptions objectForKey:[self getDate]] mutableCopy];
    // make a new entry
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    [entry setObject:[NSNumber numberWithInteger:sender.tag] forKey:@"type"];
    [entry setObject:[self getTime] forKey:@"time"];
    // add new entry
    [todaysData addObject:entry];
    [consumptions setObject:todaysData forKey:[self getDate]];
    // synchronize
    NSLog(@"CONSUMPTIONS (%d): %@",[consumptions count],consumptions);
    [[NSUserDefaults standardUserDefaults] setObject:consumptions forKey:@"consumptions"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // refresh
    [self refreshScrollView];
}

-(NSString*)getTime{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *todaysTime = [dateFormatter stringFromDate:currDate];
    return [todaysTime substringWithRange:NSMakeRange(0, 8)];
}

-(NSString*)getDate{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    return [dateFormatter stringFromDate:currDate];
}

-(NSString*)formattedDate:(NSString*)date{
    NSArray *months = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
    NSString *year = [date substringToIndex:4];
    int month = [[date substringWithRange:NSMakeRange(5, 2)] integerValue]-1;
    NSString *day = [date substringWithRange:NSMakeRange(8, 2)];
    return [NSString stringWithFormat:@"%@ %@ %@",months[month], day, year];
}

-(UIImage*)getImage:(NSArray*)data
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, (height-width)*.5), NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, width, (height-width)*.5));

    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextMoveToPoint(context, 0, (height-width)*.25);
    CGContextAddLineToPoint(context, width, (height-width)*.25);
    CGContextStrokePath(context);
    
    for(int i = 0; i < data.count; i++){
        CGContextSetFillColorWithColor(context, [UIColor colorWithHue:[[data[i] objectForKey:@"type"] integerValue]/9. saturation:1.0 brightness:1.0 alpha:1.0].CGColor);
        NSString *timeString = [data[i] objectForKey:@"time"];
        float time = [[timeString substringWithRange:NSMakeRange(0, 2)] integerValue]/24. +
                     [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue]/60./24.;
        CGContextMoveToPoint(context, width*time, (height-width)*.25);
        float triangle = 20;
        int direction = (i%2*2)-1;
        CGContextAddLineToPoint(context, width*time+(triangle*1.15)*.5, (height-width)*.25+triangle*direction);
        CGContextAddLineToPoint(context, width*time-(triangle*1.15)*.5, (height-width)*.25+triangle*direction);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
    UIImage *image = [UIImage imageWithData:UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext())];
    UIGraphicsEndImageContext();
    return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation NSMutableDictionary (GramCategory)

-(NSArray*) sortedValues{
    if([self count]){
    NSArray *keys = [[self allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray* sorted = [NSMutableArray array];
    for(NSString *key in keys)
        [sorted addObject:[self objectForKey:key]];
    return sorted;
    }
    else return [NSArray array];
}

-(NSArray*) sortedKeys{
    if([self count])
        return [[self allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    else
        return [NSArray array];
}

@end

@implementation UIScrollView (CurrentPage)
-(int) currentPage{
    CGFloat pageWidth = self.frame.size.width;
    return floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}
@end
