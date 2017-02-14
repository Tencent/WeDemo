//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "NewCommentViewController.h"
#import "ADNetworkEngine.h"
#import "ADUserInfo.h"
#import "UITextView+Placeholder.h"

static const CGFloat kTextFontSize = 15.0f;

@interface NewCommentViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation NewCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"写留言";
    [self.view addSubview:self.textView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onClickPublish:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - User Actions
- (void)onClickPublish: (UIBarButtonItem *)sender {
    if (sender != self.navigationItem.rightBarButtonItem)
        return;
    
    NSString *content = self.textView.text;
    /* 检查字数 */
    if ([self.textView.text length] == 0) {
        ADShowErrorAlert(@"内容不能为空");
        return;
    }
    
    /* 检查URL */
    NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray* matchURL = [detector matchesInString:content
                                          options:0
                                            range:NSMakeRange(0, [content length])];
    if ([matchURL count] > 0) {
        ADShowErrorAlert(@"内容中不能包含链接");
        return;
    }
    
    [[ADNetworkEngine sharedEngine] addCommentContent:self.textView.text
                                               ForUin:[ADUserInfo currentUser].uin
                                          LoginTicket:[ADUserInfo currentUser].loginTicket
                                       WithCompletion:^(ADAddCommentResp *resp) {
                                           if (self.delegate &&
                                               [self.delegate respondsToSelector:@selector(onNewCommentDidFinish)]) {
                                               [self.delegate onNewCommentDidFinish];
                                           }
                                           [self.navigationController popViewControllerAnimated:YES];
                                       }];
}

#pragma mark - Lazy Initializers
- (UITextView *)textView {
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(inset, inset, ScreenWidth-inset*2, ScreenHeight-inset*2)];
        _textView.font = [UIFont fontWithName:kChineseFont
                                         size:kTextFontSize];
        _textView.placeholder = @"请输入要发表的内容。";
    }
    return _textView;
}

@end
