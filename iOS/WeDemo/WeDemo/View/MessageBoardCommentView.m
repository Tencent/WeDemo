//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "MessageBoardCommentView.h"
#import "MessageBoardContentView.h"

@implementation MessageBoardCommentView

#pragma mark - Life Cycle
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.commentContent];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.commentContent.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

#pragma mark - Lazy Initializer
- (MessageBoardContentView *)commentContent {
    if (_commentContent == nil) {
        _commentContent = [[MessageBoardContentView alloc] init];
    }
    return _commentContent;
}

@end
