//
//  OriginalViewController.h
//  Xketch-Testing
//
//  Created by blackzid on 2014/9/30.
//  Copyright (c) 2014年 blackzid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LoadFileViewController.h"
@interface OriginalViewController : UIViewController <UIScrollViewDelegate,UIPickerViewDelegate ,UIPickerViewDataSource,UITabBarDelegate,UINavigationBarDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,MKMapViewDelegate,UITextFieldDelegate,UITextViewDelegate>
@property (strong,nonatomic) id controller;
//@property (strong,nonatomic) UITabBarController *tabBarController;

@property (strong,nonatomic) NSArray *componentsOfViews;
@property (strong,nonatomic) OriginalViewController *firstController;

@property (nonatomic, strong) NSArray *actions;
@property (strong, nonatomic) NSMutableDictionary *objectsWithID;
@property (strong, nonatomic) NSDictionary *objectGroups;
@property (strong, nonatomic) NSMutableArray *activeViews;
@property (weak, nonatomic) LoadFileViewController *loadFileViewController;
@property (nonatomic) BOOL isNavigation;
@property (nonatomic) BOOL isTabBar;
-(id)getController;

-(void)setViewTitle:(NSString *)title;

-(void)addButtonAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height Text:(NSString *)text Action:(NSString *)action isWithID:(NSString *)elementID;

-(void)addLabelAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z Text:(NSString *)text isWithID:(NSString *)elementID;

-(void)addSegmentedControl:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width TextGroup:(NSString *)textGroupid ImagesGroup:(NSString *)imageGroupid BindingView:(NSString *)viewID isWithID:(NSString *)elementID;

-(void)addTextFieldAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width isWithID:(NSString *)elementID;

-(void)addSliderAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Max:(NSString *)max Min:(NSString *)min isWithID:(NSString *)elementID;

-(void)addSwitchAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z isWithID:(NSString *)elementID;

-(void)addPageControlAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width bingingView:(NSString *)viewID isWithID:(NSString *)elementID;

-(void)addTableViewWithTextGroup:(NSString *)textGroupid Z:(NSString *)z isWithID:(NSString *)elementID;

-(void)addImageViewAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height Image:(NSString *)imageUrl Group:(NSString *)group isWithID:(NSString *)elementID;

-(void)addTextViewAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height isWithID:(NSString *)elementID;

-(void)addPickerViewAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height TextGroup:(NSString *)textGroupid isWithID:(NSString *)elementID;

-(void)addMapViewAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height isWithID:(NSString *)elementID;

-(void)addWebViewAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height withURL:(NSString *)url isWithID:(NSString *)elementID;

//-(void)addNavigationBarisWithID:(NSString *)elementID;

-(void)addTabBarItemWithTitle:(NSString *)title order:(NSString *)order isWithID:(NSString *)elementID;

//-(void)addTabBarWithTitle:(NSString *)title Action:(NSString *)action tag:(NSString *)tag isWithID:(NSString *)elementID;
-(void)addBarButtonItemWithTitle:(NSString *)title position:(NSString *)position Action:(NSString *)action isWithID:(NSString *)elementID;

-(void)addSearchBarAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width isWithID:(NSString *)elementID;


@end
