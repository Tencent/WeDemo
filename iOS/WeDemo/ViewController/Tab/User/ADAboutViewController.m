//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ADAboutViewController.h"
#import "ADShareViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

static NSString* const kTitleText = @"关于我们";
static NSString* const kAboutUsText = @"WeDemo为微信团队开源项目，用于微信开发者进行微信登录、分享功能开发时的参考Demo。微信开发者可以参考项目中的代码来开发应用，也可以直接使用项目中的代码到自己的App中。\n开发者可以自由使用并传播本代码。\n\n源代码下载地址：\n https://github.com/Tencent/WeDemo\n\n联系我们：\nopen@wechat.com";
static NSString* const kSourceCodeAddress = @"https://github.com/Tencent/WeDemo";

@interface ADAboutViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSString *savedString;

@end

@implementation ADAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = kTitleText;
    [self.view addSubview:self.textView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.textView.frame = CGRectMake(inset,
                                     inset,
                                     ScreenWidth-inset * 2,
                                     ScreenHeight-inset-navigationBarHeight-statusBarHeight);
}

#pragma mark - TextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"https"]) {
        // do something with this username
        // ...
        ADShareViewController *shareView = [[ADShareViewController alloc] init];
        shareView.title = @"源码";
        shareView.urlString = [URL absoluteString];
        [self.navigationController pushViewController:shareView
                                             animated:YES];
        return NO;
    }
    return YES; // let the system open this URL
}

#pragma mark - Lazy Initializers
- (UITextView *)textView {
    if (_textView == nil) {
        _textView = [[UITextView alloc] init];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:kAboutUsText attributes:@{
                                                                                                                                  NSFontAttributeName: [UIFont fontWithName:kChineseFont size:17]
                                                                                                                                  }];
        [attributedString addAttribute:NSLinkAttributeName
                                 value:kSourceCodeAddress
                                 range:[[attributedString string] rangeOfString:kSourceCodeAddress]];
        
        NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray* matchURL = [detector matchesInString:[attributedString string]
                                              options:0
                                                range:NSMakeRange(0, [[attributedString string] length])];
        NSLog(@"%@", matchURL);

        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor linkButtonColor],
                                         NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                         NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
        _textView.linkTextAttributes = linkAttributes; // customizes the appearance of links
        _textView.attributedText = attributedString;
        _textView.delegate = self;
        _textView.editable = NO;
    }
    return _textView;
}

@end
