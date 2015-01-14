//
//  RecordUtil.m
//  recoder
//
//  Created by Carolyn on 2014/12/12.
//  Copyright (c) 2014年 Carolyn. All rights reserved.
//

#import "RecordUtil.h"


static IQProjectVideo *projectVideo;

@implementation RecordUtil
BOOL isWriting;
+(void)startRecord {
    isWriting = YES;
    projectVideo = [IQProjectVideo sharedController];
    [projectVideo startVideoCapture];
}

+(void)stopRecord {
    if(isWriting){
        [projectVideo stopVideoCaptureWithCompletionHandler:^(NSDictionary *info, NSError *error){
            NSLog(@"%@",info);
        }];
        isWriting = NO;
    }
}
+(void)SetUserName:(NSString *)name{
    projectVideo = [IQProjectVideo sharedController];
    projectVideo.testerName = name;
}
+(void)addStamptime{
    if(isWriting){
        [projectVideo addStampTime];
    }
}

@end
