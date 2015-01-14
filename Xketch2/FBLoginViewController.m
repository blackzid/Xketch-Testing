//
//  FBLoginViewController.m
//  Xketch2
//
//  Created by blackzid on 2014/12/27.
//  Copyright (c) 2014年 blackzid. All rights reserved.
//

#import "FBLoginViewController.h"
#import "LoadFileViewController.h"
@interface FBLoginViewController () <FBLoginViewDelegate>
@property (nonatomic, strong) NSArray *info;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet FBLoginView *loginView;
@property BOOL isPerformed;
@end

@implementation FBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isPerformed =NO;
    _loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.loginView.readPermissions = @[@"user_about_me",@"user_activities"];
    // Do any additional setup after loading the view.

}
- (void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _isPerformed = NO;
    _loginButton.enabled = YES;
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended){
        _loginButton.titleLabel.text = @"Login with Facebook";
        _statusLabel.text = @"You're not logged in!";
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    else{
        _loginButton.titleLabel.text = @"Login with Facebook";
        _statusLabel.text = @"You're not logged in!";
    }
}
-(void)getFacebookIDandName{
    [FBRequestConnection startWithGraphPath:@"/me"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              self.info = @[result[@"id"],result[@"name"]];
                              if(!_isPerformed){
                                  [self performSegueWithIdentifier:@"Login" sender:self];
                                  _isPerformed =YES;
                              }

                          }];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Login"]){
        LoadFileViewController *vc = (LoadFileViewController *)segue.destinationViewController;
        vc.info = self.info;
        self.info = nil;
    }
}
#pragma FBLoginView Delegate
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
        [self getFacebookIDandName];
}
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    _statusLabel.text = @"You're logged in";
    [self getFacebookIDandName];
}
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    _statusLabel.text = @"You're not logged in!";
}
@end
