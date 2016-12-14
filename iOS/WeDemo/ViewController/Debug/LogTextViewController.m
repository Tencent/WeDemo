//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "LogTextViewController.h"
#import "WXApiManager.h"

@interface LogTextViewController ()<UIActionSheetDelegate>

@property (nonatomic, strong) UITextView *textView;

@end

@implementation LogTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"日志";
    [self.view addSubview:self.textView];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出"
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(onClickDismiss:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(onClickMore:)];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.textView.frame = self.view.frame;
}

#pragma mark - User Actions
- (void)onClickDismiss:(UIBarButtonItem *)sender {
    if (sender != self.navigationItem.leftBarButtonItem)
        return;
    self.presented = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickShare:(UIBarButtonItem *)sender {
    if (sender != self.navigationItem.rightBarButtonItem)
        return;
    
    [[WXApiManager sharedManager] sendFileData:[self.textView.text dataUsingEncoding:NSUTF8StringEncoding]
                                 fileExtension:@".txt"
                                         Title:@"来自WeDemo的日志信息"
                                   Description:@"来自WeDemo的日志信息"
                                    ThumbImage:nil
                                       AtScene:WXSceneSession];
}

- (void)onClickMore:(UIBarButtonItem *)sender {
    if (sender != self.navigationItem.rightBarButtonItem)
        return;
    
    [[[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:@"取消"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"发送日志给微信好友", nil] showInView:self.view];
}

#pragma mark - Public Methods
+ (instancetype)sharedLogTextView {
    static dispatch_once_t onceToken;
    static LogTextViewController *instance;
    dispatch_once(&onceToken, ^{
        instance = [[LogTextViewController alloc] init];
        instance.hidesBottomBarWhenPushed = YES;
        instance.presented = NO;
    });
    return instance;
}

- (void)insertLog:(NSString *)log {
    static BOOL ever = NO;
    static CGFloat lastPos = 0;
    
    UIColor *color = ever ? [UIColor whiteColor] : [UIColor redColor];
    NSMutableAttributedString *attributeString = [self.textView.attributedText mutableCopy];
    [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:log]];
    [attributeString addAttribute:NSForegroundColorAttributeName
                            value:color
                            range:NSMakeRange(lastPos, [log length])];
    self.textView.attributedText = attributeString;
    lastPos = lastPos + [log length];
    ever = !ever;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [[WXApiManager sharedManager] sendFileData:[self.textView.text dataUsingEncoding:NSUTF8StringEncoding]
                                         fileExtension:@".txt"
                                                 Title:@"来自WeDemo的日志信息"
                                           Description:@"来自WeDemo的日志信息"
                                            ThumbImage:nil
                                               AtScene:WXSceneSession];
            break;
        default:
            break;
    }
}

#pragma mark - Lazy Initializers
- (UITextView *)textView {
    if (_textView == nil) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont fontWithName:kEnglishNumberFont size:10];
        _textView.backgroundColor = [UIColor blackColor];
        _textView.textColor = [UIColor whiteColor];
        _textView.editable = NO;
    }
    return _textView;
}

@end
