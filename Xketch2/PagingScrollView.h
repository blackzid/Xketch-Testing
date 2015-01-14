//
//  PagingScrollView.h
//  Xketch-Testing
//
//  Created by blackzid on 2014/12/13.
//  Copyright (c) 2014年 blackzid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagingScrollView : UIScrollView
@property (strong, nonatomic) UIPageControl *pageControl;
@property (nonatomic) NSInteger numberOfImages;
@end
