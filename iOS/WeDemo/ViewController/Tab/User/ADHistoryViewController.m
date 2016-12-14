//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ADHistoryViewController.h"

static const int kTableHeaderHeight = 60;

static NSString* const kCellIdentifer = @"kCellIdentifer";
static NSString* const kDateFormat = @"yyyy年MM月dd日 HH:mm:ss";
static NSString* const kTitleText = @"访问记录";
static NSString* const kTableHeaderText = @"以下是您最近一段时间的访问记录";
//static NSString* const kFromAppLogin = @"从账号密码登录";
//static NSString* const kFromWXLogin =  @"从微信授权登录";

@interface ADHistoryViewController ()

@property (nonatomic, strong) NSArray *accessLogArray;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) UITableViewHeaderFooterView *headerView;

@end

@implementation ADHistoryViewController

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewStyle)style
                   AccessLogs:(NSArray *)accessLogArray {
    if (self = [self initWithStyle:style]) {
        self.accessLogArray = accessLogArray == nil ? [[NSArray alloc] init] : accessLogArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = kTitleText;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:kCellIdentifer];
}

#pragma mark - User Actions
- (void)onClickBack: (UIBarButtonItem *)sender {
    if (sender != self.navigationItem.leftBarButtonItem)
        return;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.accessLogArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer
                                                            forIndexPath:indexPath];
    ADAccessLog *accessLog = [self.accessLogArray objectAtIndex:indexPath.row];
    NSDate *loginDate = [NSDate dateWithTimeIntervalSince1970:accessLog.loginTime];
    NSString *loginDateString = [self.formatter stringFromDate:loginDate];
    NSString *loginTypeString = @"微信登录";
    cell.textLabel.text = [NSString stringWithFormat:@" %@  %@", loginTypeString, loginDateString];
    cell.textLabel.font = [UIFont fontWithName:kChineseFont
                                          size:14];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableView Delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kTableHeaderHeight;
}

#pragma mark - Lazy Initializers
- (NSDateFormatter *)formatter {
    if (_formatter == nil) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = kDateFormat;
    }
    return _formatter;
}

- (UITableViewHeaderFooterView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0,
                                                                                    0,
                                                                                    ScreenWidth,
                                                                                    kTableHeaderHeight)];
        _headerView.textLabel.font = [UIFont fontWithName:kChineseFont
                                                    size:14];
        _headerView.textLabel.text = kTableHeaderText;
    }
    return _headerView;
}
@end
