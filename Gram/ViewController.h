//
//  ViewController.h
//  Gram
//
//  Created by Robby Kraft on 12/20/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIScrollViewDelegate>

@end

@interface NSMutableDictionary (GramCategory)
-(NSArray*) sortedValues;
-(NSArray*) sortedKeys;
@end

@interface UIScrollView (CurrentPage)
-(int) currentPage;
@end