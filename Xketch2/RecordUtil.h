//
//  RecordUtil.h
//  recoder
//
//  Created by Carolyn on 2014/12/12.
//  Copyright (c) 2014年 Carolyn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQProjectVideo.h"
#import <MediaPlayer/MediaPlayer.h>

@interface RecordUtil : NSObject
+(void)startRecord;
+(void)stopRecord;
+(void)addStamptime;
+(void)SetUserName:(NSString *)name;
@end
