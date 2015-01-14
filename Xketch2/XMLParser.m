//
//  XMLParser.m
//  Xketch-Testing
//
//  Created by blackzid on 2014/10/16.
//  Copyright (c) 2014年 blackzid. All rights reserved.
//

#import "XMLParser.h"
#import "OriginalViewController.h"
#import <Parse/Parse.h>

@interface XMLParser () <NSXMLParserDelegate>

@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSMutableString *ElementValue;
@property (strong, nonatomic) NSMutableDictionary *dictionary;

@property (strong, nonatomic) NSMutableArray *objectGroup;
@property (strong, nonatomic) NSMutableArray *imageIDArray;
@property (strong, nonatomic) NSString *groupID;
@property (nonatomic, strong) NSString *imagesPath;
@property (nonatomic) BOOL isActions;
@property BOOL errorParsing;
@end
@implementation XMLParser

int groupCount;
int finishCount;
- (id)init {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.imagesPath = [documentsDirectory stringByAppendingString:@"/Xketch_Files/images"];
        groupCount = 0;
    }
    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"File found and parsing started");
}
- (void)parseXMLFileFromPath:(NSString *)path{
    self.parser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:path]];
    self.errorParsing = NO;
    self.isActions = NO;
    [self.parser setDelegate:self];
    [self.parser setShouldProcessNamespaces:NO];
    [self.parser setShouldReportNamespacePrefixes:NO];
    [self.parser setShouldResolveExternalEntities:NO];
    [self.parser parse];
}
- (void)parseXMLFileFromData:(NSData *)data{
    self.parser = [[NSXMLParser alloc] initWithData:data];
    self.errorParsing = NO;
    self.isActions = NO;
    [self.parser setDelegate:self];
    [self.parser setShouldProcessNamespaces:NO];
    [self.parser setShouldReportNamespacePrefixes:NO];
    [self.parser setShouldResolveExternalEntities:NO];
    [self.parser parse];
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSString *errorString = [NSString stringWithFormat:@"Error code %li", (long)[parseError code]];
    NSLog(@"Error parsing XML: %@", errorString);
    self.ElementValue = [[NSMutableString alloc] init];
    self.errorParsing=YES;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if([elementName isEqualToString:@"ViewControllers"])
    {
        self.isActions = NO;
        NSString *isNC = [attributeDict objectForKey:@"NavigationController"];
        NSString *isTC = [attributeDict objectForKey:@"TabBarController"];
        if([isNC isEqualToString:@"ON"])
            self.isNavigationController = YES;
        else
            self.isNavigationController = NO;
        if([isTC isEqualToString:@"ON"])
            self.isTabBarController = YES;
        else
            self.isTabBarController = NO;
        return;
    }
    else if([elementName isEqualToString:@"Actions"]){
        self.isActions = YES;
        self.actions = [[NSMutableArray alloc] init];
        return;
    }
    if(!self.isActions){
        if([elementName isEqualToString:@"ViewController"]){
            self.array = [[NSMutableArray alloc] init];
            self.objectGroups = [[NSMutableDictionary alloc] init];
            self.viewNumber = [attributeDict objectForKey:@"number"];
            self.viewTitle = [attributeDict objectForKey:@"title"];
        }
        else if([elementName isEqualToString:@"Group"]){
            NSString *type = [attributeDict objectForKey:@"type"];
            if([type isEqualToString:@"image"]){
                self.imageIDArray = [[NSMutableArray alloc] init];
                NSString *groupID = [attributeDict objectForKey:@"groupid"];
                self.groupID = groupID;
                groupCount++;
            }
            else{
                self.objectGroup = [[NSMutableArray alloc] init];
                NSString *groupID = [attributeDict objectForKey:@"groupid"];
                self.groupID = groupID;
            }
        }
        else if([elementName isEqualToString:@"Image"]){
            NSString *imageID =[attributeDict objectForKey:@"id"];
            [self.imageIDArray addObject:imageID];
        }
        else if([elementName isEqualToString:@"Text"]){
            NSString *string = [attributeDict objectForKey:@"string"];
            [self.objectGroup addObject:string];
        }
        else{
            self.dictionary = [[NSMutableDictionary alloc] initWithDictionary:attributeDict];
            [self.dictionary setObject:elementName forKey:@"type"];
        }
        
    }
    else{
        if([elementName isEqualToString:@"Action"]){
            [self.actions addObject:attributeDict];
        }
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if([elementName isEqualToString:@"ViewControllers"]){
        if(groupCount == 0)
            [self.delegate didFinishLoadingImages];
        return;
    }
    else if([elementName isEqualToString:@"Actions"]){
        return;
    }
    if(!self.isActions){
        if([elementName isEqualToString:@"ViewController"]){
            [self.delegate didFinishParsingViewController];
            self.objectGroups = nil;
            NSLog(@"view :%@",self.viewNumber);

        }
        else if([elementName isEqualToString:@"Group"]){
            if(self.objectGroup){
                [self.objectGroups setObject:self.objectGroup forKey:self.groupID];
                self.objectGroup = nil;
            }
            else{
                [self getImageFromParse:self.imageIDArray groupID:[NSString stringWithString:self.groupID] toGroups:self.objectGroups];
            }
        }
        else if([elementName isEqualToString:@"Image"]||[elementName isEqualToString:@"Text"]){
            
        }
        else{
            [self.array addObject:self.dictionary];
            self.dictionary = nil;
        }
    }
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    if (self.errorParsing == NO)
    {
        NSLog(@"XML processing done!");
        
    }
    else {
        NSLog(@"Error occurred during XML processing");
    }
}
-(void)getImageFromParse:(NSArray *)imageIDArray groupID:(NSString *)groupid toGroups:(NSMutableDictionary *)groups{
    NSMutableArray *imageArray = [[NSMutableArray alloc]init];
    for(NSString *imageID in imageIDArray){
        PFQuery *query = [PFQuery queryWithClassName:@"ImageFiles"];
        [query getObjectInBackgroundWithId:imageID block:^(PFObject *object, NSError *error) {
            if(!error){
                PFFile *imageFile = object[@"ImageFile"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    UIImage *image = [UIImage imageWithData:data];
                    [imageArray addObject:image];
                    if(imageArray.count==imageIDArray.count){
                       
                        [groups setObject:imageArray forKey:groupid];
                        groupCount--;
                        if(groupCount == 0){
                            dispatch_async(dispatch_get_main_queue(),^{
                                [self.delegate didFinishLoadingImages];
                            });
                        }
                    }
                }];
            }
        }];
    }
}
@end
