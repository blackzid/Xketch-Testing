//
//  XMLParser.h
//  Xketch-Testing
//
//  Created by blackzid on 2014/10/16.
//  Copyright (c) 2014年 blackzid. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XMLParser;

@protocol XMLParserDelegate <NSObject>

@optional
-(void)didFinishParsingViewController;
-(void)didFinishLoadingImages;
-(void)progressBlock:(NSInteger) percentDone;
@end

@interface XMLParser : NSObject 
@property (strong, nonatomic) NSMutableArray *array;
@property (strong, nonatomic) NSString *viewNumber;
@property (strong, nonatomic) NSString *viewTitle;
@property (strong, nonatomic) NSMutableArray *actions;
@property (strong, nonatomic) NSMutableDictionary *objectGroups;

@property (strong,nonatomic) id<XMLParserDelegate> delegate;
@property (nonatomic) BOOL isNavigationController;
@property (nonatomic) BOOL isTabBarController;
- (void)parseXMLFileFromPath:(NSString *)path;
- (void)parseXMLFileFromData:(NSData *)data;
@end
