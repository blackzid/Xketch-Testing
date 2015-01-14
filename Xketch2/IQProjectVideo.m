//
//  IQProjectVideo
//
//  Created by Iftekhar Mac Pro on 9/26/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.


#import "IQProjectVideo.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MLScreenshot/UIView+MLScreenshot.h>
NSString *const IQFilePathKey       = @"IQFilePath";
NSString *const IQFileSizeKey       = @"IQFileSize";
NSString *const IQFileCreateDateKey = @"IQFileCreateDate";
NSString *const IQFileDurationKey   = @"IQFileDurationKey";

static IQProjectVideo *shareObject;
BOOL isStamptime = NO;
@implementation IQProjectVideo
{
    NSOperationQueue    *_readOperationQueue;
    NSOperationQueue    *_writeOperationQueue;
    
    NSTimer             *_stopTimer;
    NSTimer             *_startTimer;
    
    NSDate *_startDate;
    NSDate *_previousDate;
    NSDate *_currentDate;
    
    AVAssetWriter *videoWriter;
    AVAssetWriterInput* writerInput;
    AVAssetWriterInputPixelBufferAdaptor *adaptor;
    CVPixelBufferRef buffer;

    CGFloat currentSeconds;
    NSTimer *timer;
}


+(IQProjectVideo*)sharedController
{
    if (shareObject == nil)
    {
        shareObject = [[IQProjectVideo alloc] init];
    }
    
    return shareObject;
}


- (id)init
{
    //取時間作為file name
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    //去pare拿資料
    PFQuery *query = [PFQuery queryWithClassName:@"Version"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                if([[object objectForKey:@"version_name"] isEqual: @"v2.0"]){
                        NSLog(@"%@",object.objectId);//要到這個版本的這個受測者的objectId
                        _ThisObject = object;
                }
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }
    }];

    self = [super init];
    if (self)
    {
        _readOperationQueue = [[NSOperationQueue alloc] init];
        _readOperationQueue.name = @"Read Operation Queue";
        [_readOperationQueue setMaxConcurrentOperationCount:1];
        
        _writeOperationQueue = [[NSOperationQueue alloc] init];
        _writeOperationQueue.name = @"Write Operation Queue";
        [_writeOperationQueue setMaxConcurrentOperationCount:1];
        
        buffer = NULL;
        videofileName = [dateString stringByAppendingString:@".mp4"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        _path = [NSString stringWithFormat:@"%@/video.mp4",documentsDirectory];
    }
    return self;
}

-(void)cancel
{
    [_startTimer invalidate];
    [_stopTimer invalidate];

    buffer = NULL;
    _completionBlock = NULL;
}

-(void)startCapturingScreenshots
{
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{

        if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
            [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
        
        NSError *error = nil;
        videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:_path]
                                                fileType:AVFileTypeMPEG4
                                                   error:&error];
        
        UIWindow*   _window = [[UIApplication sharedApplication] keyWindow];
        NSDictionary *videoSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       AVVideoCodecH264, AVVideoCodecKey,
                                       [NSNumber numberWithInt:_window.bounds.size.width], AVVideoWidthKey,
                                       [NSNumber numberWithInt:_window.bounds.size.height], AVVideoHeightKey,
                                       nil];
        
        writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        
        adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
        
        [videoWriter addInput:writerInput];
        
        //Start a session:
        [videoWriter startWriting];
        [videoWriter startSessionAtSourceTime:kCMTimeZero];
    }];
    
    if (_writeOperationQueue.operationCount)    [blockOperation addDependency:_writeOperationQueue.operations.lastObject];
    [_writeOperationQueue addOperation:blockOperation];
    
    _startDate = [NSDate date];
    _currentDate = _startDate;

    _startTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(screenshot) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_startTimer forMode:NSRunLoopCommonModes];
}

-(void)startVideoCaptureOfDuration:(NSInteger)seconds completionBlock:(CompletionBlock)completionBlock
{
    [self cancel];
    _completionBlock = completionBlock;
    
    [self startCapturingScreenshots];
    
    _stopTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(stopVideoCapture) userInfo:nil repeats:NO];
}

-(void)startVideoCapture
{
    NSLog(@"startVideoCapture");
    self.stampTime = [[NSMutableArray alloc] init];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(addTime) userInfo:nil repeats:YES];
    currentSeconds = 0;

    [self cancel];
    [self startCapturingScreenshots];
}
-(void)addTime{
    currentSeconds +=0.5;
}
-(void)stopVideoCaptureWithCompletionHandler:(CompletionBlock)completionBlock
{
    _completionBlock = completionBlock;
    [self stopVideoCapture];
}
-(void)stopVideoCapture
{
    //    [_displayLink invalidate];
    NSLog(@"stopVideoCapture");
    currentSeconds = 0;
    [timer invalidate];
    [_startTimer invalidate];
    [_stopTimer invalidate];
    [self markFinishAndWriteMovie];
}
-(void)addStampTime{
    NSString *t =[NSString stringWithFormat:@"%f",currentSeconds+1];
    [self.stampTime addObject:t];
}
- (UIImage *) snapshot {
    UIView* view = [UIApplication sharedApplication].keyWindow ;
    
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
//    {
//        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
//    } else {
//        UIGraphicsBeginImageContext(view.bounds.size);
//    }
//    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
////    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
    UIImage *image = [view screenshot];
    return image;
}

-(void)screenshot
{
//    CGImageRef screen = UIGetScreenImage();
//    UIWindow *screen = [[UIApplication sharedApplication]keyWindow];
    UIImage *image = [self snapshot];
    _previousDate = _currentDate;
    _currentDate = [NSDate date];
    NSBlockOperation *imageReadOperation = [NSBlockOperation blockOperationWithBlock:^{
      
        if(image)
        {
            NSBlockOperation *imageWriteOperation = [NSBlockOperation blockOperationWithBlock:^{
                
                while (writerInput.readyForMoreMediaData == NO)
                {
                    sleep(0.01);
                    continue;
                }
                
                //First time only
                if (buffer == NULL) CVPixelBufferPoolCreatePixelBuffer (NULL, adaptor.pixelBufferPool, &buffer);
                
                buffer = [IQProjectVideo pixelBufferFromCGImage:image.CGImage];
                
                if (buffer)
                {
                    Float64 interval = [_currentDate timeIntervalSinceDate:_startDate];
                    int32_t timeScale = 1.0/([_currentDate timeIntervalSinceDate:_previousDate]);
                    
                    /**/
                    CMTime presentTime=CMTimeMakeWithSeconds(interval, MAX(33, timeScale));
//                    NSLog(@"presentTime:%@",(__bridge NSString *)CMTimeCopyDescription(kCFAllocatorDefault, presentTime));
                    
                    // append buffer
//                    currentSeconds  = CMTimeGetSeconds(presentTime);

                    [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
                    CVPixelBufferRelease(buffer);
                }

            }];

            if (_writeOperationQueue.operationCount)    [imageWriteOperation addDependency:_writeOperationQueue.operations.lastObject];
            [_writeOperationQueue addOperation:imageWriteOperation];
        }
    }];
    
    if (_readOperationQueue.operationCount) [imageReadOperation addDependency:_readOperationQueue.operations.lastObject];
    [_readOperationQueue addOperation:imageReadOperation];
}

-(void)markFinishAndWriteMovie
{
    NSBlockOperation *finishOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        //Finish the session:
        [writerInput markAsFinished];
        /**
         *  fix bug on iOS7 is not work, finishWritingWithCompletionHandler method is not work
         */
        // http://stackoverflow.com/questions/18885735/avassetwriter-fails-when-calling-finishwritingwithcompletionhandler
        Float64 interval = [_currentDate timeIntervalSinceDate:_startDate];
        
        CMTime cmTime = CMTimeMake(interval, 1);
        [videoWriter endSessionAtSourceTime:cmTime];
        
        if ([videoWriter respondsToSelector:@selector(finishWritingWithCompletionHandler:)])
        {
            NSLog(@"finishWritingWithCompletionHandler");
            [videoWriter finishWritingWithCompletionHandler:^{
                CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                [self _completed];
                
            }];
        }
        else
        {
            [videoWriter finishWriting];
            CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
            [self _completed];
        }
        
        
    }];
    
    NSLog(@"Read Operations Left: %lu",(unsigned long)_readOperationQueue.operationCount);
    for (NSOperation *readOperation in _readOperationQueue.operations)
    {
        [finishOperation addDependency:readOperation];
    }
    
    NSLog(@"Write Operations Left: %lu",(unsigned long)_writeOperationQueue.operationCount);
    for (NSOperation *writeOperation in _writeOperationQueue.operations)
    {
        [finishOperation addDependency:writeOperation];
    }
    
    [_writeOperationQueue addOperation:finishOperation];
}

- (void)_completed
{
    NSLog(@"stringFromSelector:%@",NSStringFromSelector(_cmd));

    NSDictionary *fileAttrubutes = [[NSFileManager defaultManager] attributesOfItemAtPath:_path error:nil];

    
    AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_path]];
    
    NSTimeInterval duration = 0.0;
    
    if (CMTIME_IS_VALID(videoAsset.duration))   duration = CMTimeGetSeconds(videoAsset.duration);
    
    NSDictionary *dictInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              _path,IQFilePathKey,
                              [fileAttrubutes objectForKey:NSFileSize], IQFileSizeKey,
                              [fileAttrubutes objectForKey:NSFileCreationDate], IQFileCreateDateKey,
                              @(duration),IQFileDurationKey,
                              nil];
    
    
    
    if (_completionBlock != NULL)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            _completionBlock(dictInfo,videoWriter.error);
        });
        
    }
    
    NSString *openCommand = [NSString stringWithFormat:@"/usr/bin/open \"%@\"", NSTemporaryDirectory()];
    system([openCommand fileSystemRepresentation]);
//    [self cancel];
    
    //parse upload video
    PFObject *videoObject = [PFObject objectWithClassName:@"Tester"];
    
    PFFile *videoFile =[PFFile fileWithName:videofileName contentsAtPath:_path];
    
    //先寫死受測者的 測試版本＝v2.0 以及 受測者= Carolyn Yu
    [videoObject setObject:_ThisObject forKey:@"version_id"];
    [videoObject setObject:self.testerName forKey:@"tester_name"];
    [videoObject setObject:videoFile forKey:@"video_file"];
    [videoObject setObject:self.stampTime forKey:@"stampTime"];
    [videoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            NSLog(@"upload successful");
        }else{
            NSLog(@"upload error");
        }
    }];
    [self cancel];
}

//Helper functions
+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef) image
{
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                        CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                        &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),CGImageGetHeight(image)), image);

    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
