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
   
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, (height-width)*.5 + width, width, (height-width)*.5)];
    [scrollView setDelegate:self];
    [scrollView setPagingEnabled:true];
    [scrollView setShowsHorizontalScrollIndicator:false];
    [self.view addSubview:scrollView];
    [self refreshScrollView];
}

-(void)refreshScrollView{
    [scrollView setContentSize:CGSizeMake(width*[consumptions count], (height-width)*.5)];
    for(int i = 0; i < [consumptions count]; i++){
        UIImage *graph = [self getImage:[[consumptions allValues] objectAtIndex:i]];
        UIImageView *graphView = [[UIImageView alloc] initWithFrame:CGRectMake(width*(i), 0, width, (height-width)*.5)];
        [graphView setImage:graph];
        [scrollView addSubview:graphView];
    }
    [scrollView scrollRectToVisible:CGRectMake([consumptions count]*width, 0, width, (height-width)*.5) animated:YES];
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
