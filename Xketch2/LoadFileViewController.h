//
//  LoadFileViewController.h
//  Xketch-Testing
//
//  Created by blackzid on 2014/9/30.
//  Copyright (c) 2014年 blackzid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQProjectVideo.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
@interface LoadFileViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) IQProjectVideo *projectVideo;
@property (nonatomic,strong ) NSArray *info;
@end
