//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "DebugViewController.h"
#import "ConfigDetailViewController.h"
#import "ADNetworkConfigItem.h"
#import "ADNetworkConfigManager.h"
#import "ADNetworkEngine.h"
#import "InputWithTextFieldCell.h"
#import "ADConnectResp.h"
#import "ADBaseResp.h"
#import "ADUserInfo.h"

@interface DebugViewController ()

@property (nonatomic, strong) NSArray *allConfigKeysArray;
@property (nonatomic, weak) UITextField *hostTextField;

@end

@implementation DebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.title = @"调试";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(onClickSave:)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"debugCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"InputWithTextFieldCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"hostCell"];
    
    self.allConfigKeysArray = [[ADNetworkConfigManager sharedManager] allConfigKeys];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Actions
- (void)onClickSave: (UIBarButtonItem *)sender {
    if (sender != self.navigationItem.rightBarButtonItem)
        return;
    NSString *preHost = [ADNetworkEngine sharedEngine].host;
    [ADNetworkEngine sharedEngine].host = self.hostTextField.text;
    [[ADNetworkEngine sharedEngine] connectToServerWithCompletion:^(ADConnectResp *resp) {
        if (resp && resp.baseResp.errcode == ADErrorCodeNoError) {
            NSLog(@"Connect Success");
            [ADUserInfo currentUser].uin = resp.tempUin;
            [[ADNetworkConfigManager sharedManager] save];
            [[NSUserDefaults standardUserDefaults] setObject:[ADNetworkEngine sharedEngine].host
                                                      forKey:@"ADNetworkDefaultHost"];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            ADShowErrorAlert(@"appcgi_connect 失败，请检查配置是否正确.");
            [ADNetworkEngine sharedEngine].host = preHost;
        }
    }];
    

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : [self.allConfigKeysArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        InputWithTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hostCell"
                                                                       forIndexPath:indexPath];
        cell.descLabel.text = @"Host";
        cell.descLabel.textColor = [UIColor linkButtonColor];
        cell.textField.text = [ADNetworkEngine sharedEngine].host;
        cell.textField.placeholder = @"";
        self.hostTextField = cell.textField;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"debugCell"
                                                            forIndexPath:indexPath];
        ADNetworkConfigItem *item = [[ADNetworkConfigManager sharedManager] getConfigForKeyPath:self.allConfigKeysArray[indexPath.row]];
        cell.textLabel.text = item.cgiName;
        cell.textLabel.font = [UIFont fontWithName:kChineseFont
                                              size:14];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        ConfigDetailViewController *detailView = [[ConfigDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        detailView.configItem = [[ADNetworkConfigManager sharedManager] getConfigForKeyPath:self.allConfigKeysArray[indexPath.row]];
        [self.navigationController pushViewController:detailView
                                             animated:YES];
    }
}

@end
