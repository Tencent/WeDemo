//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "WXLoginViewController.h"
#import "DebugViewController.h"
#import "ADNetworkEngine.h"
#import "WXApiManager.h"
#import "ADWXLoginResp.h"
#import "ADCheckLoginResp.h"
#import "ADUserInfo.h"
#import "ADConnectResp.h"
#import "ADGetUserInfoResp.h"
#import "UserInfoViewController.h"
#import "AppDelegate.h"

/* Title Message */
static NSString* const kVisitorLoginTitle = @"游客模式进入";
static NSString* const kConnectErrorTitle = @"连接服务器失败";
static NSString* const kWXAuthDenyTitle = @"授权失败";
static NSString* const kWXLoginErrorTitle = @"微信登录失败";
static NSString* const kTitleLabelText = @"WeDemo";
/* Font */
static const CGFloat kTitleLabelFontSize = 18.0f;
static const CGFloat kWXLoginButtonFontSize = 16.0f;
static const CGFloat kVisitorButtonFontSize = 12.0f;
/* Size */
static const int kLogoImageWidth = 75;
static const int kLogoImageHeight = 52;
static const int kTitleLabelWidth = 150;
static const int kTitleLabelHeight = 44;
static const int kWXLoginButtonWidth = 280;
static const int kWXLoginButtonHeight = 44;
static const int kWXLogoImageWidth = 25;
static const int kWXLogoImageHeight = 20;
static const int kVisitorLoginButtonWidth = 200;
static const int kVisitorLoginButtonHeight = 44;

@interface WXLoginViewController ()<WXAuthDelegate>

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *wxLogoImageView;
@property (nonatomic, strong) UIButton *wxLoginButton;
@property (nonatomic, strong) UIButton *visitorLoginButton;
@property (nonatomic, strong) UIButton *debugButton;

@end

@implementation WXLoginViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationItem.hidesBackButton = YES;
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.wxLoginButton];
    [self.view addSubview:self.wxLogoImageView];
    [self.view addSubview:self.visitorLoginButton];
#ifdef DEBUG
    [self.view addSubview:self.debugButton];
#endif
    /* Setup Network */
    [[ADNetworkEngine sharedEngine] connectToServerWithCompletion:^(ADConnectResp *resp) {
        [self handleConnectResponse:resp];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.backgroundView.frame = self.view.frame;

    CGFloat logoImageCenterY = ScreenHeight / 5;
    self.logoImageView.frame = CGRectMake(0, 0, kLogoImageWidth, kLogoImageHeight);
    self.logoImageView.center = CGPointMake(self.view.center.x, logoImageCenterY);
    
    CGFloat titleLabelCenterY = logoImageCenterY + kLogoImageHeight/2 + inset*2;
    self.titleLabel.frame = CGRectMake(0, 0, kTitleLabelWidth, kTitleLabelHeight);
    self.titleLabel.center = CGPointMake(self.view.center.x, titleLabelCenterY);
    
    CGFloat loginButtonCenterY = ScreenHeight / 3 * 2;
    self.wxLoginButton.frame = CGRectMake(0, 0, kWXLoginButtonWidth, kWXLoginButtonHeight);
    self.wxLoginButton.center = CGPointMake(self.view.center.x, loginButtonCenterY);
    
    CGFloat wxLogoImageCenterX = self.view.center.x - inset * 3;
    self.wxLogoImageView.frame = CGRectMake(0, 0, kWXLogoImageWidth, kWXLogoImageHeight);
    self.wxLogoImageView.center = CGPointMake(wxLogoImageCenterX, loginButtonCenterY);
    
    CGFloat visitorBtnCenterY = ScreenHeight-kVisitorLoginButtonHeight/2-inset;
    self.visitorLoginButton.frame = CGRectMake(0, 0, kVisitorLoginButtonWidth, kVisitorLoginButtonHeight);
    self.visitorLoginButton.center = CGPointMake(self.view.center.x, visitorBtnCenterY);
    
    CGFloat debugBtnCenterX = ScreenWidth - inset * 3;
    CGFloat debugBtnCenterY = statusBarHeight + inset * 2;
    self.debugButton.frame = CGRectMake(0, 0, normalHeight, normalHeight);
    self.debugButton.center = CGPointMake(debugBtnCenterX, debugBtnCenterY);
}

#pragma mark - User Actions
- (void)onClickWXLogin: (UIButton *)sender {
    if (sender != self.wxLoginButton)
        return;
    [[WXApiManager sharedManager] sendAuthRequestWithController:self
                                                        delegate:self];
}

- (void)onClickVisitorLogin: (UIButton *)sender {
    if (sender != self.visitorLoginButton)
        return;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onClickDebug: (UIButton *)sender {
    if (sender != self.debugButton)
        return;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[DebugViewController alloc] initWithStyle:UITableViewStyleGrouped]];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - WXAuthDelegate
- (void)wxAuthSucceed:(NSString *)code {
    [ADUserInfo currentUser].authCode = code;
    ADShowActivity(self.view);
    [[ADNetworkEngine sharedEngine] wxLoginForAuthCode:code
                                        WithCompletion:^(ADWXLoginResp *resp) {
                                            [self handleWXLoginResponse:resp];
                                        }];
}

- (void)wxAuthDenied {
    ADShowErrorAlert(kWXAuthDenyTitle);
}

#pragma mark - Network Handlers
- (void)handleConnectResponse: (ADConnectResp *)resp {
    if (resp && resp.baseResp.errcode == 0) {
        [ADUserInfo currentUser].uin = (UInt32)resp.tempUin;
        [ADUserInfo visitorUser].uin = (UInt32)resp.tempUin;
        NSLog(@"Connect Success");
    } else {
        NSLog(@"Connect Failed");
        NSString *errorTitle = [NSString errorTitleFromResponse:resp.baseResp
                                                   defaultError:kConnectErrorTitle];
        ADShowErrorAlert(errorTitle);
        ADHideActivity;
    }
}

- (void)handleWXLoginResponse:(ADWXLoginResp *)resp {
    if (resp && resp.baseResp.errcode == ADErrorCodeNoError) {
        NSLog(@"WXLogin Success");
        [ADUserInfo currentUser].uin = (UInt32)resp.uin;
        [ADUserInfo currentUser].loginTicket = resp.loginTicket;
        [[ADNetworkEngine sharedEngine] checkLoginForUin:resp.uin
                                             LoginTicket:resp.loginTicket
                                          WithCompletion:^(ADCheckLoginResp *checkLoginResp) {
                                              [self handleCheckLoginResponse:checkLoginResp];
                                          }];
    } else {
        NSLog(@"WXLogin Fail");
        NSString *errorTitle = [NSString errorTitleFromResponse:resp.baseResp
                                                   defaultError:kWXLoginErrorTitle];
        ADShowErrorAlert(errorTitle);
        ADHideActivity;
    }
}

- (void)handleCheckLoginResponse:(ADCheckLoginResp *)resp {
    ADHideActivity;
    if (resp && resp.sessionKey) {
        NSLog(@"Check Login Success");
        [ADUserInfo currentUser].sessionExpireTime = resp.expireTime;
        [[ADUserInfo currentUser] save];
        [[ADNetworkEngine sharedEngine] getUserInfoForUin:[ADUserInfo currentUser].uin
                                              LoginTicket:[ADUserInfo currentUser].loginTicket
                                           WithCompletion:^(ADGetUserInfoResp *resp) {
                                               [ADUserInfo currentUser].nickname = resp.nickname;
                                               [ADUserInfo currentUser].headimgurl = resp.headimgurl;
                                               AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                               delegate.userInfoView.userInfoResp = resp;
                                               [[ADNetworkEngine sharedEngine] downloadImageForUrl:resp.headimgurl
                                                                                    WithCompletion:^(UIImage *image) {
                                                                                        [delegate.userInfoView.tableView reloadData];
                                                                                    }];
                                           }];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        NSLog(@"Check Login Fail");
        NSString *errorTitle = [NSString errorTitleFromResponse:resp.baseResp
                                                   defaultError:kWXLoginErrorTitle];
        ADShowErrorAlert(errorTitle);
        ADHideActivity;
    }
}

#pragma mark - Lazy Initializer
- (UIImageView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wxLoginBackground"]];
    }
    return _backgroundView;
}

- (UIImageView *)logoImageView {
    if (_logoImageView == nil) {
        _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppLogo"]];
    }
    return _logoImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = kTitleLabelText;
        _titleLabel.font = [UIFont fontWithName:kChineseFont
                                           size:kTitleLabelFontSize];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UIButton *)wxLoginButton {
    if (_wxLoginButton == nil) {
        _wxLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _wxLoginButton.backgroundColor = [UIColor loginButtonColor];
        _wxLoginButton.layer.cornerRadius = kLoginButtonCornerRadius;
        [_wxLoginButton setTitle:@"        微信登录" forState:UIControlStateNormal];
        [_wxLoginButton addTarget:self
                           action:@selector(onClickWXLogin:)
                 forControlEvents:UIControlEventTouchUpInside];
        _wxLoginButton.titleLabel.font = [UIFont fontWithName:kChineseFont
                                                         size:kWXLoginButtonFontSize];
    }
    return _wxLoginButton;
}

- (UIImageView *)wxLogoImageView {
    if (_wxLogoImageView == nil) {
        _wxLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wxLogo"]];
    }
    return _wxLogoImageView;
}

- (UIButton *)visitorLoginButton {
    if (_visitorLoginButton == nil) {
        _visitorLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_visitorLoginButton addTarget:self
                                action:@selector(onClickVisitorLogin:)
                      forControlEvents:UIControlEventTouchUpInside];
        [_visitorLoginButton setTitle:kVisitorLoginTitle
                             forState:UIControlStateNormal];
        [_visitorLoginButton setTitleColor:[UIColor linkButtonColor]
                                  forState:UIControlStateNormal];
        _visitorLoginButton.titleLabel.font = [UIFont fontWithName:kChineseFont
                                                             size:kVisitorButtonFontSize];
    }
    return _visitorLoginButton;
}

- (UIButton *)debugButton {
    if (_debugButton == nil) {
        _debugButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_debugButton addTarget:self
                         action:@selector(onClickDebug:)
               forControlEvents:UIControlEventTouchUpInside];
        [_debugButton setTitle:@"调试"
                      forState:UIControlStateNormal];
        _debugButton.titleLabel.font = [UIFont fontWithName:kChineseFont
                                                       size:kWXLoginButtonFontSize];
    }
    return _debugButton;
}

@end
