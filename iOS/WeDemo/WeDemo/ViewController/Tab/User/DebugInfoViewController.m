//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "DebugInfoViewController.h"
#import "ADHistoryViewController.h"
#import "UserInfoDisplayCell.h"
#import "ADGetUserInfoResp.h"
#import "ADUserInfo.h"

/* Text Message */
static NSString *const kDebugInfoCellIdentifier = @"kDebugInfoCellIdentifier";
static NSString *const kButtonCellIdentifier = @"kButtonCellIdentifier";
static NSString* const kOpenIdDescText = @"OpenID";
static NSString* const kUnionIdDescText = @"UnionID";
static NSString* const kAccessTokenDescText =  @"Access token有效期至";
static NSString* const kRefreshTokenDescText = @"Refresh token有效期至";
static NSString* const kSessionKeyDescText =   @"App 登录态有效期至";
static NSString* const kDateFormat = @"yyyy-MM-dd HH:mm";

/* Size */
static const CGFloat kUserInfoCellHeight = 64.0f;
static const CGFloat kButtonCellHeight = 40.0f;

@interface DebugInfoViewController ()

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation DebugInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.title = @"授权信息";
    [self.tableView registerNib:[UINib nibWithNibName:@"UserInfoDisplayCell"
                                               bundle:nil]
         forCellReuseIdentifier:kDebugInfoCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:kButtonCellIdentifier];
    self.tableView.sectionHeaderHeight = self.tableView.sectionFooterHeight = 0.5 * inset;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = inset*1.5;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [self.tableView setTableHeaderView:headerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsArray[] = {5, 1};
    return rowsArray[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        UserInfoDisplayCell *debugInfoCell = [tableView dequeueReusableCellWithIdentifier:kDebugInfoCellIdentifier
                                                                             forIndexPath:indexPath];
        switch (indexPath.row) {
             case 0: { //Open ID
                 debugInfoCell.descLabel.text = kOpenIdDescText;
                 debugInfoCell.valueLabel.text = self.userInfoResp.openid;
                break;
            }
            case 1: //Union ID
                debugInfoCell.descLabel.text = kUnionIdDescText;
                debugInfoCell.valueLabel.text = [self.userInfoResp.unionid length] == 0 ? @"None" : self.userInfoResp.unionid;
                break;
            case 2: //Session Key
                debugInfoCell.descLabel.text = kSessionKeyDescText;
                debugInfoCell.valueLabel.text = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[ADUserInfo currentUser].sessionExpireTime]];
                break;
            case 3: //Access Token
                debugInfoCell.descLabel.text = kAccessTokenDescText;
                debugInfoCell.valueLabel.text = self.userInfoResp.accessTokenExpireTime == kAccessTokenTimeNone ? @"None" : [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.userInfoResp.accessTokenExpireTime]];
                break;
            case 4: { //Refresh Token
                debugInfoCell.descLabel.text = kRefreshTokenDescText;
                if (self.userInfoResp.refreshTokenExpireTime == kRefreshTokenTimeNone) {
                    debugInfoCell.valueLabel.text = @"None";
                } else {
                    debugInfoCell.valueLabel.text = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.userInfoResp.refreshTokenExpireTime]];
                }
                break;
            }
            default:
                break;
        }
        cell = debugInfoCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kButtonCellIdentifier
                                               forIndexPath:indexPath];
        cell.textLabel.font = [UIFont fontWithName:kChineseFont
                                              size:16.0f];
        cell.textLabel.text = @"访问记录";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? kUserInfoCellHeight : kButtonCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self.navigationController pushViewController:[[ADHistoryViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                          AccessLogs:self.userInfoResp.accessLog]
                                             animated:YES];
    }
}

#pragma mark - Lazy Initializer
- (NSDateFormatter *)formatter {
    if (_formatter == nil) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = kDateFormat;
    }
    return _formatter;
}


@end
