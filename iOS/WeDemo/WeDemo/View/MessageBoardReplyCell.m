//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "MessageBoardReplyCell.h"
#import "MessageBoardContentView.h"

@implementation MessageBoardReplyCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.replyContentView = [[MessageBoardContentView alloc] init];
        [self.contentView addSubview:self.replyContentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.replyContentView.frame = CGRectMake(inset*4,
                                             0,
                                             CGRectGetWidth(self.frame)-inset*4,
                                             CGRectGetHeight(self.frame));
}

@end
