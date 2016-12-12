//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "AskLoginViewController.h"
#import "WXApiManager.h"
#import "ADNetworkEngine.h"
#import "ADGetUserInfoResp.h"
#import "ADWXLoginResp.h"
#import "ADCheckLoginResp.h"
#import "ADUserInfo.h"
#import "AppDelegate.h"
#import "UserInfoViewController.h"

/* Text Message */
static NSString* const kWXAuthDenyTitle = @"授权失败";
static NSString* const kWXLoginErrorTitle = @"微信登录失败";
static NSString* const kTitleLabelText = @"如需使用%@功能，请先登录";
/* Font */
static const CGFloat kTitleLabelFontSize = 16.0f;
static const CGFloat kWXLoginButtonFontSize = 16.0f;
/* Size */
static const int kLogoImageWidth = 67;
static const int kLogoImageHeight = 67;
static const int kTitleLabelWidth = 300;
static const int kTitleLabelHeight = 44;
static const int kWXLoginButtonWidth = 280;
static const int kWXLoginButtonHeight = 44;
static const int kWXLogoImageWidth = 25;
static const int kWXLogoImageHeight = 20;

@interface AskLoginViewController ()<WXAuthDelegate>

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *wxLogoImageView;
@property (nonatomic, strong) UIButton *wxLoginButton;

@end

@implementation AskLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"授权信息";
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.wxLoginButton];
    [self.view addSubview:self.wxLogoImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat logoImageCenterY = ScreenHeight / 5;
    self.logoImageView.frame = CGRectMake(0, 0, kLogoImageWidth, kLogoImageHeight);
    self.logoImageView.center = CGPointMake(self.view.center.x, logoImageCenterY);
    
    CGFloat titleLabelCenterY = logoImageCenterY + kLogoImageHeight/2 + inset*2;
    self.titleLabel.frame = CGRectMake(0, 0, kTitleLabelWidth, kTitleLabelHeight);
    self.titleLabel.center = CGPointMake(self.view.center.x, titleLabelCenterY);
    
    CGFloat loginButtonCenterY = ScreenHeight / 5 * 2;
    self.wxLoginButton.frame = CGRectMake(0, 0, kWXLoginButtonWidth, kWXLoginButtonHeight);
    self.wxLoginButton.center = CGPointMake(self.view.center.x, loginButtonCenterY);
    
    CGFloat wxLogoImageCenterX = self.view.center.x - inset * 3;
    self.wxLogoImageView.frame = CGRectMake(0, 0, kWXLogoImageWidth, kWXLogoImageHeight);
    self.wxLogoImageView.center = CGPointMake(wxLogoImageCenterX, loginButtonCenterY);
}

#pragma mark - User Actions
- (void)onClickWXLogin: (UIButton *)sender {
    if (sender != self.wxLoginButton)
        return;
    [[WXApiManager sharedManager] sendAuthRequestWithController:self
                                                       delegate:self];
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
    }
}

#pragma mark - Lazy Initializer
- (UIImageView *)logoImageView {
    if (_logoImageView == nil) {
        _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AskLoginIcon"]];
    }
    return _logoImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = [NSString stringWithFormat:kTitleLabelText, self.founctionName];
        _titleLabel.font = [UIFont fontWithName:kChineseFont
                                           size:kTitleLabelFontSize];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
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


@end
