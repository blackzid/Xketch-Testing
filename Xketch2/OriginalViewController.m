//
//  OriginalViewController.m
//  Xketch-Testing
//
//  Created by blackzid on 2014/9/30.
//  Copyright (c) 2014年 blackzid. All rights reserved.
//

#import "OriginalViewController.h"
#import "PagingScrollView.h"
#import "SegmentedControl+ImageVIew.h"
#import "PickerViewWithTextArray.h"
#import "RecordUtil.h"
@interface OriginalViewController ()
@property NSMutableArray *pickerData;
@property (strong, nonatomic) NSMutableDictionary *buttonTarget;
@property (strong, nonatomic) NSMutableDictionary *components;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *tableViewData;
@property (strong, nonatomic) UITabBar *tabBar;

@end

@implementation OriginalViewController

const int ISRECORD =1;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.buttonTarget = [[NSMutableDictionary alloc]init];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (id)init {
    self = [super init];
    if (self) {
        self.controller = self;
        self.objectsWithID = [[NSMutableDictionary alloc]init];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.tabBar){
        self.tabBar.selectedItem = nil;
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(ISRECORD)
        [RecordUtil addStamptime];
}
-(void)setViewTitle:(NSString *)title{
    self.title= title;
}
#pragma get right controller pointer
-(id)getController{
    if(self.tabBarController)
        return self.tabBarController;
    else if (self.navigationController)
        return self.navigationController;
    else
        return self.controller;
}
#pragma add Button
-(void)addButtonAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height Text:(NSString *)text Action:(NSString *)action isWithID:(NSString *)elementID{
    UIButton *button;
    if(elementID){
        button = [self.objectsWithID objectForKey:elementID];
    }
    else
        button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self
               action:@selector(aMethod:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:text forState:UIControlStateNormal];
    button.frame = CGRectMake([x floatValue],[y floatValue], (width)? [width floatValue]:160 , (height)? [height floatValue] :40.0);
    if(z)
        button.layer.zPosition = [z floatValue];
    if(action){
        button.tag = [action integerValue];
    }
//    [button sizeToFit];
    [self.view addSubview:button];
}
-(void)aMethod:(id)sender{
    UIButton *btn = sender;
    OriginalViewController *target;
    for(int i = 0; i < self.actions.count ; i ++){
        NSDictionary *action = [self.actions objectAtIndex:i];
        NSInteger name = [(NSString*)[action objectForKey:@"name"] integerValue];
        NSString *type = [action objectForKey:@"type"];
        if(btn.tag == name){
            if([type isEqualToString:@"presentView"]){
                NSString *targetNumber = [action objectForKey:@"target"];
                NSString *segue = [action objectForKey:@"segue"];
                for(NSDictionary *components in self.componentsOfViews){
                    if ([targetNumber isEqualToString:[components objectForKey:@"number"]]){
                        target = [components objectForKey:@"view"];
                        target = [target getController];
                        break;
                    }
                }
                NSInteger transtionStyle =[(NSString*)[action objectForKey:@"transitionStyle"] integerValue];
                target.modalTransitionStyle = transtionStyle;
                
                if (target && target!=self) {
                    if(!self.isNavigation){
                        BOOL isAnimated = [(NSString *)[action objectForKey:@"animated"] boolValue];
                        if(target != self.presentingViewController)
                            [self presentViewController:target animated:isAnimated completion:nil];
                        else
                            [self dismissViewControllerAnimated:isAnimated completion:nil];
                    }
                    else{
                        BOOL isAnimated = [(NSString *)[action objectForKey:@"animated"] boolValue];
                        if([segue isEqualToString:@"modal"]){
                            [self.navigationController presentViewController:target animated:isAnimated completion:nil];
                        }
                        else
                            [self.navigationController pushViewController:target animated:isAnimated];
                    }
                }
            }
            else if([type isEqualToString:@"hide/show"]){
                NSString *targetID = [action objectForKey:@"target"];
                UIView *object = [self.objectsWithID objectForKey:targetID];
                object.hidden = !(object.hidden);
            }
            else if ([type isEqualToString:@"showAlert"]){
                NSString *message = [action objectForKey:@"message"];
                NSString *title = [action objectForKey:@"title"];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertController addAction:alertAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
    
}

#pragma add Segment Control
-(void)addSegmentedControl:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width TextGroup:(NSString *)textGroupid ImagesGroup:(NSString *)imageGroupid BindingView:(NSString *)viewID isWithID:(NSString *)elementID{
    NSArray *stringArray = [self.objectGroups objectForKey:textGroupid];
    SegmentedControl_ImageVIew *segmentedControl;
    if(elementID){
        segmentedControl = [self.objectsWithID objectForKey:elementID];
        for (int i = 0; i < stringArray.count; i++) {
            [segmentedControl insertSegmentWithTitle:[stringArray objectAtIndex:i] atIndex:i animated:NO];
        }
    }
    else
        segmentedControl = [[SegmentedControl_ImageVIew alloc] initWithItems:stringArray];
    [segmentedControl addTarget:self action:@selector(segmentControlAction:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake([x floatValue], [y floatValue], [width floatValue], 29);
    if(z)
        segmentedControl.layer.zPosition = [z floatValue];
    segmentedControl.selectedSegmentIndex = 0;
    if(imageGroupid && viewID){
        segmentedControl.imageArray = [self.objectGroups objectForKey:imageGroupid];
        segmentedControl.bindingView = [self.objectsWithID objectForKey:viewID];
        if([segmentedControl.bindingView isKindOfClass:[UIImageView class]] && segmentedControl.imageArray )
            ((UIImageView *)segmentedControl.bindingView).image = [segmentedControl.imageArray objectAtIndex:0];
    }
    [self.view addSubview:segmentedControl];
    
}
- (void)segmentControlAction:(UISegmentedControl *)segment
{
    SegmentedControl_ImageVIew *segControl = (SegmentedControl_ImageVIew *)segment;
    if(segControl.bindingView)
        segControl.bindingView.image = [segControl.imageArray objectAtIndex:segControl.selectedSegmentIndex];
}
#pragma add Label
-(void)addLabelAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z Text:(NSString *)text isWithID:(NSString *)elementID{
    
    UILabel *label;
    if(elementID){
        label = [self.objectsWithID objectForKey:elementID];
    }
    else
        label  = [[UILabel alloc] init];
    label.frame = CGRectMake([x floatValue],[y floatValue], 160.0, 40.0);
    if(z)
        label.layer.zPosition = [z floatValue];
    label.tintColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"%@",text];
    [self.view addSubview:label];
    
}

#pragma TextField
-(void)addTextFieldAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width isWithID:(NSString *)elementID{
    UITextField *textField;
    if(elementID){
        textField =  [self.objectsWithID objectForKey:elementID];
    }
    else{
        textField = [[UITextField alloc] init];
    }
    [textField setFrame:CGRectMake([x floatValue],[y floatValue], [width floatValue], 30.0)];
    if(z)
        textField.layer.zPosition = [z floatValue];
    textField.delegate = self;
    [textField setPlaceholder:@"type something"];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:textField];
    if(elementID){
        [self.objectsWithID setObject:textField forKey:elementID];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches  withEvent:event];
}
#pragma Slider Bar
-(void)addSliderAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Max:(NSString *)max Min:(NSString *)min isWithID:(NSString *)elementID{
    
    UISlider *slider;
    if(elementID){
       slider =  [self.objectsWithID objectForKey:elementID];
    }
    else {
        slider = [[UISlider alloc] init];
    }
    [slider setFrame:CGRectMake([x floatValue],[y floatValue], [width floatValue],31)];
    if(z)
        slider.layer.zPosition = [z floatValue];
    slider.maximumValue=[max floatValue];
    slider.minimumValue = [min floatValue];
    slider.value = (slider.maximumValue+slider.minimumValue)/2;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
}
-(void)sliderValueChanged:(UISlider *)slider{
}
#pragma Switch
-(void)addSwitchAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z isWithID:(NSString *)elementID {
    UISwitch *uiSwitch ;
    if(elementID){
        uiSwitch = [self.objectsWithID objectForKey:elementID];
    }
    else
        uiSwitch = [[UISwitch alloc] init];
    [uiSwitch setFrame:CGRectMake([x floatValue],[y floatValue], 51,31) ];
    if(z)
        uiSwitch.layer.zPosition = [z floatValue];
    [uiSwitch setOn:YES];
    [self.view addSubview:uiSwitch];
    [uiSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    
}
- (void)changeSwitch:(id)sender{
    
    if([sender isOn]){
    } else{
    }
    
}
#pragma Page Control
-(void)addPageControlAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width bingingView:(NSString *)viewID isWithID:(NSString *)elementID{
    
    UIPageControl *pageControl;
    if(elementID){
        pageControl = [self.objectsWithID objectForKey:elementID];
    }
    else
        pageControl = [[UIPageControl alloc] init ];
    
    [pageControl setFrame:CGRectMake([x floatValue],[y floatValue],[width floatValue], 37.0)];
    if(z)
        pageControl.layer.zPosition = [z floatValue];
    pageControl.currentPage = 0;
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    if(viewID){
        PagingScrollView *scrollView = [self.objectsWithID objectForKey:viewID];
        scrollView.pageControl = pageControl;
        pageControl.numberOfPages = scrollView.numberOfImages;
    }
    else
        pageControl.numberOfPages = 3;
    [self.view addSubview:pageControl];
    
    
}


#pragma add TableView
-(void)addTableViewWithTextGroup:(NSString *)textGroupid Z:(NSString *)z isWithID:(NSString *)elementID{
    if(elementID){
        self.tableView = [self.objectsWithID  objectForKey:elementID];
    }
    else
        self.tableView = [[UITableView alloc] init];
    [self.tableView setFrame:self.view.bounds];
    if(z)
        self.tableView.layer.zPosition = [z floatValue];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableViewData = [self.objectGroups objectForKey:textGroupid];
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
    
}
//#pragma TableViewDelegate
#pragma TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewData.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.text = [self.tableViewData objectAtIndex:indexPath.row];
    return cell;
}

#pragma add ImageView
-(void)addImageViewAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height Image:(NSString *)imageUrl Group:(NSString *)group isWithID:(NSString *)elementID{
    if(group){
        NSArray *imageGroup = [self.objectGroups objectForKey:group];
        PagingScrollView *scrollView;
        if(elementID){
            scrollView =  [self.objectsWithID objectForKey:elementID];
        }
        else
            scrollView = [[PagingScrollView alloc] init];
        
        [scrollView setFrame:CGRectMake([x floatValue],[y floatValue], [width floatValue], [height floatValue] )];
        if(z)
            scrollView.layer.zPosition = [z floatValue];
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        
        [scrollView setAlwaysBounceVertical:NO];
        for(int i = 0; i <imageGroup.count ; i++){
            CGFloat xOrigin = i*[width floatValue];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:
                                  CGRectMake(xOrigin,0, [width floatValue], [height floatValue])];
            imageView.image = [imageGroup objectAtIndex:i];
            imageView.contentMode = UIViewContentModeScaleToFill;
            [scrollView addSubview:imageView];
        }
        scrollView.numberOfImages = imageGroup.count;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake([width floatValue] *
                                            imageGroup.count,
                                            [height floatValue]);
        self.automaticallyAdjustsScrollViewInsets =NO;
        [self.view addSubview:scrollView];
        
    }
    else{
        UIImageView *imageView;
        if(elementID){
            imageView = [self.objectsWithID objectForKey:elementID];
        }
        else
            imageView = [[UIImageView alloc] init];
        [imageView setFrame:CGRectMake([x floatValue],[y floatValue], [width floatValue], [height floatValue])];
        if(z)
            imageView.layer.zPosition = [z floatValue];
        if(imageUrl){
            UIImage *image = [UIImage imageWithContentsOfFile:imageUrl];
            imageView.image = image;
        }
        [self.view addSubview:imageView];
    }
}
#pragma scrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([scrollView isKindOfClass:[PagingScrollView class]]){
        PagingScrollView *pagingScrollView = (PagingScrollView *)scrollView;
        CGFloat pageWidth = pagingScrollView.frame.size.width;
        float fractionalPage = pagingScrollView.contentOffset.x / pageWidth;
        NSInteger page = lround(fractionalPage);
        pagingScrollView.pageControl.currentPage = page;
    }
}
#pragma add TextView
-(void)addTextViewAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height isWithID:(NSString *)elementID{
    UITextView *textView;
    if(elementID){
        textView =  [self.objectsWithID objectForKey:elementID];
    }
    else
        textView = [[UITextView alloc] init];
    [textView setFrame:CGRectMake([x floatValue],[y floatValue], [width floatValue], [height floatValue])];
    if(z)
        textView.layer.zPosition = [z floatValue];
    [textView setText:@"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."];
    [self.view addSubview:textView];
}

#pragma add PickerView
-(void)addPickerViewAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height TextGroup:(NSString *)textGroupid isWithID:(NSString *)elementID{
    PickerViewWithTextArray *picker;
    if(elementID){
        picker =  [self.objectsWithID objectForKey:elementID];
    }
    else
        picker = [[PickerViewWithTextArray alloc] init];
    if([height floatValue]<162.0)
        height = @"162.0";
    [picker setFrame:CGRectMake([x floatValue],[y floatValue], [width floatValue], [height floatValue])];
    if(z)
        picker.layer.zPosition = [z floatValue];
    picker.delegate = self;
    picker.dataSource = self;
    NSArray *array = [self.objectGroups objectForKey:textGroupid];
    picker.textArray = array;
    [self.view addSubview:picker];
}
#pragma PickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    PickerViewWithTextArray *picker = (PickerViewWithTextArray  *)pickerView;
    return picker.textArray.count;
}
#pragma PickerViewDataSource
// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PickerViewWithTextArray *picker = (PickerViewWithTextArray  *)pickerView;
    return [picker.textArray objectAtIndex:row];
}
#pragma add MapView
-(void)addMapViewAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height isWithID:(NSString *)elementID{
    MKMapView *map;
    if(elementID){
        map = [self.objectsWithID objectForKey:elementID];
    }
    else
        map = [[MKMapView alloc] init];
    [map setFrame:CGRectMake([x floatValue],[y floatValue],[width floatValue],[height floatValue])];
    if(z)
        map.layer.zPosition = [z floatValue];
    MKUserLocation *userLocation = map.userLocation;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (
                                        userLocation.location.coordinate, 20000, 20000);
    [map setRegion:region animated:NO];
    
    [self.view addSubview:map];
    
    
}
#pragma add WebView
-(void)addWebViewAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width Height:(NSString *)height withURL:(NSString *)url isWithID:(NSString *)elementID{
    UIWebView *webView;
    if(elementID){
        webView = [self.objectsWithID objectForKey:elementID];
    }
    else
        webView = [[UIWebView alloc ] init];
    [webView setFrame:CGRectMake([x floatValue],[y floatValue], [width floatValue], [height floatValue])];
    if(z)
        webView.layer.zPosition = [z floatValue];
    webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

//#pragma add NavigationBar
//
//-(void)addNavigationBarisWithID:(NSString *)elementID{
//    UINavigationController *navigationController= [[UINavigationController alloc] initWithRootViewController:self];
////    self.navigationController = navigationController;
//    
//}
#pragma add BarButtonItem
-(void)addBarButtonItemWithTitle:(NSString *)title position:(NSString *)position Action:(NSString *)action isWithID:(NSString *)elementID{
    UIBarButtonItem *barButtonItem =[[UIBarButtonItem alloc] initWithTitle:title
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(barButtonItemMethod:)];
    if(action)
        barButtonItem.tag = [action integerValue];
    if(self.navigationItem){
        if([position isEqualToString:@"right"]){
            self.navigationItem.rightBarButtonItem = barButtonItem;
        }
        else if([position isEqualToString:@"left"]){
            self.navigationItem.leftBarButtonItem = barButtonItem;
        }
    }
}
-(void)barButtonItemMethod:(id)sender{
    UIBarButtonItem *btn = sender;
    OriginalViewController *target;
    for(int i = 0; i < self.actions.count ; i ++){
        NSDictionary *action = [self.actions objectAtIndex:i];
        NSInteger name = [(NSString*)[action objectForKey:@"name"] integerValue];
        NSString *type = [action objectForKey:@"type"];

        if(btn.tag == name){
            if([type isEqualToString:@"presentView"]){
                NSString *targetNumber = [action objectForKey:@"target"];
                NSString *segue = [action objectForKey:@"segue"];
                for(NSDictionary *components in self.componentsOfViews){
                    if ([targetNumber isEqualToString:[components objectForKey:@"number"]]){
                        target = [components objectForKey:@"view"];
                        target = [target getController];
                        break;
                    }
                }
                NSInteger transtionStyle =[(NSString*)[action objectForKey:@"transitionStyle"] integerValue];
                target.modalTransitionStyle = transtionStyle;
                
                if (target && target!=self) {
                    if(!self.isNavigation){
                        BOOL isAnimated = [(NSString *)[action objectForKey:@"animated"] boolValue];
                        if(target != self.presentingViewController)
                            [self presentViewController:target animated:isAnimated completion:nil];
                        else
                            [self dismissViewControllerAnimated:isAnimated completion:nil];
                    }
                    else{
                        BOOL isAnimated = [(NSString *)[action objectForKey:@"animated"] boolValue];
                        if([segue isEqualToString:@"modal"]){
                            [self presentViewController:target animated:isAnimated completion:nil];
                        }
                        [self.navigationController pushViewController:target animated:isAnimated];
                    }
                }
            }
            else if([type isEqualToString:@"hide/show"]){
                NSString *targetID = [action objectForKey:@"target"];
                UIView *object = [self.objectsWithID objectForKey:targetID];
                object.hidden = !(object.hidden);
            }
            else if ([type isEqualToString:@"showAlert"]){
                NSString *message = [action objectForKey:@"message"];
                NSString *title = [action objectForKey:@"title"];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertController addAction:alertAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
    
}
#pragma add Tab Bar Controller
-(void)addTabBarItemWithTitle:(NSString *)title order:(NSString *)order isWithID:(NSString *)elementID{
    
    self.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:title
                                  image:nil
                                    tag:[order integerValue]];
}

#pragma add Search Bar
-(void)addSearchBarAtPositionX:(NSString *)x Y:(NSString *)y Z:(NSString *)z WithWidth:(NSString *)width isWithID:(NSString *)elementID{
    UISearchBar *searchBar;
    if(elementID){
        searchBar =  [self.objectsWithID objectForKey:elementID];
    }
    else
        searchBar = [[UISearchBar alloc] init];
    [searchBar setFrame:CGRectMake([x floatValue],[y floatValue], [width floatValue], 44)];
    if(z)
        searchBar.layer.zPosition = [z floatValue];
    //UISearchController *controller = [[UISearchController alloc] initWithSearchResultsController:self];
    [self.view addSubview:searchBar];
}

@end
