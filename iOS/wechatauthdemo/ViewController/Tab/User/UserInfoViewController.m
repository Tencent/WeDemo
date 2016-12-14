//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "UserInfoViewController.h"
#import "ADUserInfo.h"
#import "UserHeadPhotoCell.h"
#import "UserNickNameCell.h"
#import "ImageCache.h"
#import "DebugInfoViewController.h"
#import "ADAboutViewController.h"
#import "ADGetUserInfoResp.h"
#import "ADNetworkEngine.h"
#import "WXLoginViewController.h"
#import "WXApiManager.h"
#import "ADGetUserInfoResp.h"
#import "ADCheckLoginResp.h"
#import "ADWXLoginResp.h"
#import "AppDelegate.h"
#import "AskLoginViewController.h"

static NSString* const kUserInfoViewTitle = @"我";
static NSString* const kUserInfoCellIdentifier = @"kUserInfoCellIdentifier";
static NSString* const kUserHeadPhotoCellIdentifier = @"kUserHeadPhotoCellIdentifier";
static NSString* const kUserNickNameCellIdentifier = @"kUserNickNameCellIdentifier";
static NSString* const kLogoutButtonText = @"退出登录";
static NSString* const kLogoutTitleText = @"退出不会删除用户数据，下次登录依然可以使用本账号";
static NSString* const kCancelTitleText = @"取消";
static NSString* const kWXAuthDenyTitle = @"授权失败";
static NSString* const kWXLoginErrorTitle = @"微信登录失败";

/* Size */
static const int kWXLoginButtonWidth = 280;
static const int kWXLoginButtonHeight = 44;
static const int kWXLogoImageWidth = 25;
static const int kWXLogoImageHeight = 20;
static const CGFloat kWXLoginButtonFontSize = 16.0f;

@interface UserInfoViewController () <UIActionSheetDelegate, WXAuthDelegate>

@property (nonatomic, readonly, strong) ADUserInfo *userInfo;
@property (nonatomic, strong) UIImageView *wxLogoImageView;
@property (nonatomic, strong) UIButton *wxLoginButton;
@property (nonatomic, strong) UIView *headerView;

@end

@implementation UserInfoViewController

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = kUserInfoViewTitle;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:kUserInfoCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserHeadPhotoCell" bundle:nil]
         forCellReuseIdentifier:kUserHeadPhotoCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserNickNameCell" bundle:nil]
         forCellReuseIdentifier:kUserNickNameCellIdentifier];
    
    self.tableView.sectionHeaderHeight = self.tableView.sectionFooterHeight = inset / 2;
    self.tableView.tableHeaderView = self.headerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsArray[] = {2, 1, 1, 1};
    return rowsArray[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0) {
                UserHeadPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserHeadPhotoCellIdentifier
                                                                          forIndexPath:indexPath];
                cell.headPhoto.image = [UIImage getCachedImageForUrl:self.userInfo.headimgurl];
                if (cell.headPhoto.image == nil)
                    cell.headPhoto.image = [UIImage imageNamed:@"wxLogoGreen"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            } else {
                UserNickNameCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserNickNameCellIdentifier
                                                                         forIndexPath:indexPath];
                cell.nameLabel.text = self.userInfo.nickname;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(inset, 0, ScreenWidth-2*inset, 1)];/// change size as you need.
                separatorLineView.backgroundColor = [UIColor groupTableViewBackgroundColor];// you can also put image here
                [cell.contentView addSubview:separatorLineView];
                return cell;
            }
        }
        case 1: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoCellIdentifier
                                                                    forIndexPath:indexPath];
            cell.textLabel.font = [UIFont fontWithName:kChineseFont
                                                  size:16.0f];
            cell.textLabel.text = @"授权信息";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            return cell;
        }
        case 2: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoCellIdentifier
                                                                    forIndexPath:indexPath];
            cell.textLabel.font = [UIFont fontWithName:kChineseFont
                                                  size:16.0f];
            cell.textLabel.text = @"关于";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            return cell;
        }
        case 3: {
            if (self.userInfo.sessionExpireTime > 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoCellIdentifier
                                                                    forIndexPath:indexPath];
                cell.textLabel.font = [UIFont fontWithName:kChineseFont
                                                  size:16.0f];
                cell.textLabel.textColor = [UIColor redColor];
                cell.textLabel.text = @"退出登录";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
                return cell;
            } else {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell addSubview:self.wxLoginButton];
                [cell addSubview:self.wxLogoImageView];
                
                return cell;
            }
        }
        default:
            return nil;
    }
}

#pragma mark - UITabelViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 72.0f;
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) { //Debug Log
        if (self.userInfo.sessionExpireTime > 0) {
            DebugInfoViewController *debugInfoView = [[DebugInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
            debugInfoView.userInfoResp = self.userInfoResp;
            debugInfoView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:debugInfoView
                                                 animated:YES];
        } else {
            AskLoginViewController *askLoginView = [[AskLoginViewController alloc] init];
            askLoginView.founctionName = @"授权信息";
            askLoginView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:askLoginView
                                                 animated:YES];
        }
    } else if (indexPath.section == 2) { //About
        ADAboutViewController *aboutView = [[ADAboutViewController alloc] init];
        aboutView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:aboutView animated:YES];
    } else if (indexPath.section == 3) { //Logout Or Login
        if (self.userInfo.sessionExpireTime > 0) {
            [[[UIActionSheet alloc] initWithTitle:kLogoutTitleText
                                         delegate:self
                                cancelButtonTitle:kCancelTitleText
                           destructiveButtonTitle:kLogoutButtonText
                                otherButtonTitles:nil] showInView:self.view];
        } else {
            
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [[ADNetworkEngine sharedEngine] disConnect];
        [[ADUserInfo currentUser] clear];
        WXLoginViewController *wxLoginView = [[WXLoginViewController alloc] init];
        wxLoginView.hidesBottomBarWhenPushed = YES;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController pushViewController:wxLoginView
                                             animated:YES];
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
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
                                                                                        ADHideActivity;
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


#pragma mark -Lazy Initializer
- (ADUserInfo *)userInfo {
    return [ADUserInfo currentUser].sessionExpireTime > 0 ? [ADUserInfo currentUser] : [ADUserInfo visitorUser];
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
        
        _wxLoginButton.frame = CGRectMake(0, 0, kWXLoginButtonWidth, kWXLoginButtonHeight);
        _wxLoginButton.center = CGPointMake(self.view.center.x, 22);
    }
    return _wxLoginButton;
}

- (UIImageView *)wxLogoImageView {
    if (_wxLogoImageView == nil) {
        _wxLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wxLogo"]];
        CGFloat wxLogoImageCenterX = self.view.center.x - inset * 3;
        _wxLogoImageView.frame = CGRectMake(0, 0, kWXLogoImageWidth, kWXLogoImageHeight);
        _wxLogoImageView.center = CGPointMake(wxLogoImageCenterX, 22);
    }
    return _wxLogoImageView;
}

- (UIView *)headerView {
    if (_headerView == nil) {
        CGRect frame = self.tableView.tableHeaderView.frame;
        frame.size.height = inset*1.5;
        _headerView = [[UIView alloc] initWithFrame:frame];
    }
    return _headerView;
}

@end
