//
//  LoadFileViewController.m
//  Xketch-Testing
//
//  Created by blackzid on 2014/9/30.
//  Copyright (c) 2014年 blackzid. All rights reserved.
//

#import "LoadFileViewController.h"
#import "OriginalViewController.h"
#import "XMLParser.h"
#import "PagingScrollView.h"
#import "SegmentedControl+ImageVIew.h"
#import "PickerViewWithTextArray.h"
#import "RecordUtil.h"
#import "PrototypeTableViewCell.h"
@interface LoadFileViewController () <XMLParserDelegate>
@property (nonatomic, strong) NSMutableArray* views;
@property (nonatomic, strong) NSMutableArray* componentsOfView;
@property (nonatomic, strong) NSMutableArray* tabBarViewControllers;
@property (nonatomic, strong) NSMutableArray *activeViews;
@property (nonatomic, strong) UITabBarController *tabBarC;
@property (nonatomic, strong) UINavigationController *navigationC;
@property (nonatomic, strong) NSString *filesPath;
@property (nonatomic, strong) NSMutableArray *filesListArray;
@property (nonatomic, strong) NSMutableDictionary *iconDictionary;
@property (nonatomic, strong) NSMutableDictionary *XMLFileObjectID;
@property (nonatomic, strong) XMLParser* xmlParser;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *tableViewIndicator;
@property (strong, nonatomic) UIAlertController *loadingView;
@end

@implementation LoadFileViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.filesListArray = [[NSMutableArray alloc] init];
    self.iconDictionary = [[NSMutableDictionary alloc] init];
    self.XMLFileObjectID = [[NSMutableDictionary alloc] init];
    [self.tableViewIndicator startAnimating];
    [self readFilesFromParsewithUserInfo];
    [RecordUtil SetUserName:self.info[1]];
}

-(void)readFilesFromParsewithUserInfo{
    PFQuery *query = [PFQuery queryWithClassName:@"XMLFile"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            for (PFObject *object in objects) {
                NSString *projectName = [object objectForKey:@"ProjectName"];
                NSArray *testerList =[object objectForKey:@"TestUsers"];
                for(int i = 0; i < testerList.count; i++){
                    if([self.info[0] isEqualToString:testerList[i]]){
                        [self.filesListArray addObject:[NSString stringWithString:projectName]];
                        [self.XMLFileObjectID setObject:object.objectId forKey:projectName];
                        PFFile *icon = [object objectForKey:@"icon"];
                        [icon getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            if(!error){
                                UIImage *image = [UIImage imageWithData:data];
                                [self.iconDictionary setObject:image forKey:projectName];
                                [self.tableView reloadData];
                            }
                        }];
                        break;
                    }
                }
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        [self.tableView reloadData];
        [self.tableViewIndicator stopAnimating];
    }];
}
- (IBAction)dismissThisController:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filesListArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [[UITableViewCell alloc] init];
//    cell.textLabel.text = [self.filesListArray objectAtIndex:indexPath.row];
    PrototypeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"prototype" forIndexPath:indexPath];
    NSString *projectName =[self.filesListArray objectAtIndex:indexPath.row];
    cell.appName.text = projectName;
    cell.icon.image = [self.iconDictionary objectForKey:projectName];
    
    return cell;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.loadingView = [UIAlertController alertControllerWithTitle:nil message:@"Loading\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
     UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(130.5, 65.5);
    spinner.color = [UIColor blackColor];
    [spinner startAnimating];
    [self.loadingView.view addSubview:spinner];
    [self presentViewController:self.loadingView animated:NO completion:nil];
    PrototypeTableViewCell *cell = (PrototypeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    PFQuery *query = [PFQuery queryWithClassName:@"XMLFile"];
    [query getObjectInBackgroundWithId:[self.XMLFileObjectID objectForKey:cell.appName.text] block:^(PFObject *object, NSError *error) {
        if(error)
            NSLog(@"%@",error);
        else{
            PFFile *viewsFile = [object objectForKey:@"ViewsXML"];
            PFFile *actionsFile = [object objectForKey:@"ActionsXML"];
            [viewsFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                NSData *viewsData = data;
                [actionsFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    NSData *actionsData = data;
                    [self startParseViewsData:viewsData ActionData:actionsData];
                }];
            }];
        }
    }];
}
-(void)setup{
    self.xmlParser = [[XMLParser alloc]init];
    self.xmlParser.delegate = self;
    self.views = [[NSMutableArray alloc] init];
    self.componentsOfView = [[NSMutableArray alloc]init];
    self.tabBarViewControllers = [[NSMutableArray alloc] init];
    self.activeViews = [[NSMutableArray alloc] init];
}
-(void)startParseViewsData:(NSData *)viewsData ActionData:(NSData *)actionsData{
    [self setup];
    [self.xmlParser parseXMLFileFromData:actionsData];
    [self.xmlParser parseXMLFileFromData:viewsData];

}
-(void)setViewComponents{
    if(self.xmlParser.isTabBarController)
        self.tabBarC = [[UITabBarController alloc]init];
    for(int i = 0 ; i < self.views.count ; i++){
        OriginalViewController *ovc = [self.views objectAtIndex:i];
        NSDictionary *components = [self.componentsOfView objectAtIndex:i];
        [self addIDofComponents:components ToView:ovc];
    }
    for(int i = 0 ; i < self.views.count ; i++){
        OriginalViewController *ovc = [self.views objectAtIndex:i];
        NSDictionary *components = [self.componentsOfView objectAtIndex:i];
        [self addComponents:components ToView:ovc];
    }
    OriginalViewController *firstView = [self.views objectAtIndex:0] ;
    if (self.xmlParser.isNavigationController && self.xmlParser.isTabBarController) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for(int i =0; i < self.tabBarViewControllers.count ; i++ ){
            UINavigationController *navigationC = [[UINavigationController alloc] initWithRootViewController:[self.tabBarViewControllers objectAtIndex:i]];
            [tempArray addObject:navigationC];
        }
        self.tabBarViewControllers = tempArray;
        [self.tabBarC setViewControllers:self.tabBarViewControllers];
        [self presentViewController:self.tabBarC animated:YES completion:^{
                [RecordUtil startRecord];
        }];
    }
    else if(self.xmlParser.isNavigationController){
        UINavigationController *navigationC = [[UINavigationController alloc] initWithRootViewController:firstView];
        [self presentViewController:navigationC animated:YES completion:^{
                [RecordUtil startRecord];
        }];
    }
    else if(self.xmlParser.isTabBarController){
        [self presentViewController:self.tabBarC animated:YES completion:^{
                [RecordUtil startRecord];
        }];
    }
    else{
        [self presentViewController:[firstView getController] animated:YES completion:^{
            [RecordUtil startRecord];
        }];
    }
}
-(void)addIDofComponents:(NSDictionary *)components ToView:(OriginalViewController *)ovc{
    NSArray *elements = [components objectForKey:@"elements"];
    NSString *title = [components objectForKey:@"title"];
    [ovc setViewTitle:title];
    for (int i = 0; i < [elements count]; i++) {
        NSDictionary *dic = [elements objectAtIndex:i];
        NSString *type = [dic objectForKey:@"type"];
        NSString *elementID = [dic objectForKey:@"id"];
        if(elementID){
            if([type isEqualToString:@"Button"]){
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                [ovc.objectsWithID setObject:button forKey:elementID];
            }
            else if([type isEqualToString:@"SegmentedControl"]){
                SegmentedControl_ImageVIew *segmentedControl = [[SegmentedControl_ImageVIew alloc] init ];
                [ovc.objectsWithID setObject:segmentedControl forKey:elementID];
            }
            else if ([type isEqualToString:@"Label"]){
                UILabel *label = [[UILabel alloc]init];
                [ovc.objectsWithID setObject:label forKey:elementID];
            }
            else if ([type isEqualToString:@"TextField"]){
                UITextField *textField = [[UITextField alloc] init];
                [ovc.objectsWithID setObject:textField forKey:elementID];
            }
            else if ([type isEqualToString:@"Slider"]){
                UISlider *slider = [[UISlider alloc]init];
                [ovc.objectsWithID setObject:slider forKey:elementID];
            }
            else if ([type isEqualToString:@"Switch"]){
                UISwitch *uiSwitch = [[UISwitch alloc]init];
                [ovc.objectsWithID setObject:uiSwitch  forKey:elementID];
            }
            else if ([type isEqualToString:@"PageControl"]){
                UIPageControl *pageControl = [[UIPageControl alloc] init];
                [ovc.objectsWithID setObject:pageControl forKey:elementID];
            }
            else if ([type isEqualToString:@"TableView"]){
                UITableView *tableView = [[UITableView alloc] init];
                [ovc.objectsWithID setObject:tableView forKey:elementID];
            }
            else if ([type isEqualToString:@"ImageView"]){
                if([dic objectForKey:@"imagesGroup"]){
                    PagingScrollView *scrollView = [[PagingScrollView alloc] init];
                    [ovc.objectsWithID setObject:scrollView forKey:elementID];
                }
                else{
                    UIImageView *imageView = [[UIImageView alloc] init];
                    [ovc.objectsWithID setObject:imageView forKey:elementID];
                }
            }
            else if ([type isEqualToString:@"TextView"]){
                UITextView *textView = [[UITextView alloc] init];
                [ovc.objectsWithID setObject:textView forKey:elementID];
            }
            else if ([type isEqualToString:@"PickerView"]){
                PickerViewWithTextArray *pickerView = [[PickerViewWithTextArray alloc] init];
                [ovc.objectsWithID setObject:pickerView forKey:elementID];
            }
            else if ([type isEqualToString:@"MapView"]){
                MKMapView *mapView = [[MKMapView alloc] init];
                [ovc.objectsWithID setObject:mapView forKey:elementID];
            }
            else if ([type isEqualToString:@"WebView"]){
                UIWebView *webView = [[UIWebView alloc] init];
                [ovc.objectsWithID setObject:webView forKey:elementID];
            }
            else if([type isEqualToString:@"BarButtonItem"]){
                UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] init];
                [ovc.objectsWithID setObject:barButtonItem  forKey:elementID];
            }
            else if([type isEqualToString:@"SearchBar"]){
                UISearchBar *searchBar = [[UISearchBar alloc] init];
                [ovc.objectsWithID setObject:searchBar forKey:elementID];
            }
        }
        
    }
}

-(void)addComponents:(NSDictionary *)components ToView:(OriginalViewController *)ovc{
    NSArray *elements = [components objectForKey:@"elements"];
    for (int i = 0; i < [elements count]; i++) {
        NSDictionary *dic = [elements objectAtIndex:i];
        NSString *type = [dic objectForKey:@"type"];
        NSString *elementID = [dic objectForKey:@"id"];
        if([type isEqualToString:@"Button"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *width = [dic objectForKey:@"layout_width"];
            NSString *height = [dic objectForKey:@"layout_height"];
            NSString *text = [dic objectForKey:@"text"];
            NSString *action = [dic objectForKey:@"action"];
            [ovc addButtonAtPositionX:x Y:y Z:z WithWidth:width Height:height Text:text Action:action isWithID:elementID];
        }
        else if([type isEqualToString:@"SegmentedControl"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *width = [dic objectForKey:@"layout_width"];
            NSString *imagesGroup =[dic objectForKey:@"imagesGroup"];
            NSString *textGroup = [dic objectForKey:@"textGroup"];
            NSString *viewID = [dic objectForKey:@"bindingView"];
            [ovc addSegmentedControl:x Y:y Z:z WithWidth:width TextGroup:textGroup ImagesGroup:imagesGroup  BindingView:viewID isWithID:elementID];
        }
        else if ([type isEqualToString:@"Label"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *text = [dic objectForKey:@"text"];
            [ovc addLabelAtPositionX:x Y:y Z:z Text:text isWithID:elementID];
        }
        else if ([type isEqualToString:@"TextField"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *width= [dic objectForKey:@"layout_width"];
            [ovc addTextFieldAtPositionX:x Y:y Z:z WithWidth:width isWithID:elementID];
        }
        else if ([type isEqualToString:@"Slider"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *width= [dic objectForKey:@"layout_width"];
            NSString *max =[dic objectForKey:@"max"];
            NSString *min =[dic objectForKey:@"min"];
            [ovc addSliderAtPositionX:x Y:y Z:z WithWidth:width Max:max Min:min isWithID:elementID];
        }
        else if ([type isEqualToString:@"Switch"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            [ovc addSwitchAtPositionX:x Y:y Z:z isWithID:elementID];
        }
        else if ([type isEqualToString:@"PageControl"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *width= [dic objectForKey:@"layout_width"];
            NSString *viewID = [dic objectForKey:@"bindingView"];
            [ovc addPageControlAtPositionX:x Y:y Z:z WithWidth:width bingingView:viewID isWithID:elementID];
        }
        else if ([type isEqualToString:@"TableView"]){
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *textGroupid = [dic objectForKey:@"textGroup"];
            [ovc addTableViewWithTextGroup:textGroupid Z:z isWithID:elementID];
        }
        else if ([type isEqualToString:@"ImageView"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *width= [dic objectForKey:@"layout_width"];
            NSString *height = [dic objectForKey:@"layout_height"];
            NSString *imageUrl = [dic objectForKey:@"imageUrl"];
            NSString *imagesGroup =[dic objectForKey:@"imagesGroup"];
            [ovc addImageViewAtPositionX:x Y:y Z:z WithWidth:width Height:height Image:imageUrl Group:imagesGroup isWithID:elementID];
        }
        else if ([type isEqualToString:@"TextView"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *width= [dic objectForKey:@"layout_width"];
            NSString *height = [dic objectForKey:@"layout_height"];
            [ovc addTextViewAtPositionX:x Y:y Z:z WithWidth:width Height:height isWithID:elementID];
        }
        else if ([type isEqualToString:@"PickerView"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *width= [dic objectForKey:@"layout_width"];
            NSString *height = [dic objectForKey:@"layout_height"];
            NSString *textGroupid = [dic objectForKey:@"textGroup"];
            [ovc addPickerViewAtPositionX:x Y:y Z:z WithWidth:width Height:height TextGroup:textGroupid isWithID:elementID];
        }
        else if ([type isEqualToString:@"MapView"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *width= [dic objectForKey:@"layout_width"];
            NSString *height = [dic objectForKey:@"layout_height"];
            [ovc addMapViewAtPositionX:x Y:y Z:z WithWidth:width Height:height isWithID:elementID];
        }
        else if ([type isEqualToString:@"WebView"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *width= [dic objectForKey:@"layout_width"];
            NSString *height = [dic objectForKey:@"layout_height"];
            NSString *url = [dic objectForKey:@"url"];
            [ovc addWebViewAtPositionX:x Y:y Z:z WithWidth:width Height:height withURL:url isWithID:elementID];
        }
//        else if ([type isEqualToString:@"NavigationController"]){
////            [ovc addNavigationBarisWithID:elementID];
//        }
        else if ([type isEqualToString:@"TabBarItem"] && self.xmlParser.isTabBarController){
            NSString *title = [dic objectForKey:@"title"];
            NSString *order = [dic objectForKey:@"order"];
            if([order intValue]<=[self.tabBarViewControllers count])
                [self.tabBarViewControllers insertObject:[ovc getController] atIndex:[order intValue]];
            else
                [self.tabBarViewControllers addObject:[ovc getController]];
            
            [self.tabBarC setViewControllers:self.tabBarViewControllers];
            [ovc addTabBarItemWithTitle:title order:order isWithID:elementID];
            self.tabBarC.selectedIndex = 0;
        }
        else if([type isEqualToString:@"BarButtonItem"]){
            NSString *title = [dic objectForKey:@"title"];
            NSString *position = [dic objectForKey:@"position"];
            NSString *action = [dic objectForKey:@"action"];
            [ovc addBarButtonItemWithTitle:title position:position Action:action isWithID:elementID];
        }
        else if([type isEqualToString:@"SearchBar"]){
            NSString *x = [dic objectForKey:@"layout_x"];
            NSString *y = [dic objectForKey:@"layout_y"];
            NSString *z = [dic objectForKey:@"layout_z"];
            NSString *width= [dic objectForKey:@"layout_width"];
            [ovc addSearchBarAtPositionX:x Y:y Z:z WithWidth:width isWithID:elementID];
        }
    }
}



#pragma XMLParserDelegate
-(void)didFinishParsingViewController{
    OriginalViewController *ovc = [[OriginalViewController alloc] init];
    [ovc.view setBackgroundColor:[UIColor whiteColor]];
    NSArray *array = [NSArray arrayWithArray:self.xmlParser.array];
    NSMutableDictionary *viewComponents = [[NSMutableDictionary alloc]init];
    [viewComponents setObject:self.xmlParser.viewNumber forKey:@"number"];
    [viewComponents setObject:self.xmlParser.viewTitle forKey:@"title"];
    [viewComponents setObject:array forKey:@"elements"];
    [viewComponents setObject:ovc forKey:@"view"];
    [self.views addObject:ovc];
    [self.componentsOfView addObject:viewComponents];
    ovc.componentsOfViews = self.componentsOfView;
    ovc.actions = self.xmlParser.actions;
    ovc.objectGroups = self.xmlParser.objectGroups;
    ovc.firstController = [self.views objectAtIndex:0];
    ovc.isNavigation = self.xmlParser.isNavigationController;
    ovc.isTabBar = self.xmlParser.isTabBarController;
    ovc.loadFileViewController = self;
}
-(void)didFinishLoadingImages{
    [self.loadingView dismissViewControllerAnimated:NO completion:^{
        [self setViewComponents];
    }];
}
@end
