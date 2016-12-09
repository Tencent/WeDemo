//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "MessageBoardContentView.h"
#import "ImageCache.h"
#import "LineColor.h"
#import "ADCommentList.h"
#import "ADReplyList.h"
#import "ADUser.h"
#import "ADNetworkEngine.h"

/* Font */
static const CGFloat kNickNameFontSize = 16.0f;
static const CGFloat kTimeStampFontSize = 14.0f;
static const CGFloat kContentFontSize = 15.0f;

/* Size */
static const CGFloat kNickNameWidth = 176.0f;
static const CGFloat kTimeStampWidth = 88.0f;
static const CGFloat kNickNameHeight = 33.0f;
static const CGFloat kLineHeight = 1.0f;

/* Text */
static NSString* const kTimeStampFormat = @"yyyy-MM-dd";

@interface MessageBoardContentView ()

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) ADCommentList *comment;
@property (nonatomic, strong) ADReplyList *reply;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation MessageBoardContentView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headImage];
        [self addSubview:self.nickName];
        [self addSubview:self.timeStamp];
        [self addSubview:self.content];
        [self addSubview:self.line];
        [self addGestureRecognizer:self.tapGesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.headImage.frame = CGRectMake(inset, inset, kNickNameHeight, kNickNameHeight);
    self.nickName.frame = CGRectMake(CGRectGetMaxX(self.headImage.frame)+inset,
                                     inset*0.5,
                                     kNickNameWidth, kNickNameHeight);
    self.timeStamp.frame = CGRectMake(CGRectGetWidth(self.frame)-inset-kTimeStampWidth,
                                      inset*0.5,
                                      kTimeStampWidth, kNickNameHeight);
    if (self.comment) {
        self.content.frame = CGRectMake(CGRectGetMinX(self.nickName.frame),
                                        CGRectGetMaxY(self.nickName.frame),
                                        CGRectGetWidth(self.frame)-normalHeight-inset, self.comment.height);
        self.line.frame = CGRectMake(inset, 0, ScreenWidth-inset, kLineHeight);
    } else if (self.reply) {
        self.content.frame = CGRectMake(CGRectGetMinX(self.nickName.frame),
                                        CGRectGetMinY(self.nickName.frame)+kNickNameHeight,
                                        CGRectGetWidth(self.frame)-normalHeight-inset, self.reply.height);
        self.line.frame = CGRectMake(inset, 0, ScreenWidth-4*inset, kLineHeight);
    }
}

#pragma mark - User Actions
- (void)onClickContent: (UITapGestureRecognizer *)sender {
    if (sender != self.tapGesture)
        return;
    self.clickCallBack != nil ? self.clickCallBack() : nil;
}

#pragma mark - Public Interface
- (void)configureViewWithComment:(ADCommentList *)comment {
    self.comment = comment;
    [self configureViewWithUser:comment.user
                           Date:comment.date
                        Content:comment.content];
}

- (void)configureViewWithReply:(ADReplyList *)reply {
    self.reply = reply;
    [self configureViewWithUser:reply.user
                           Date:reply.date
                        Content:reply.content];
}

+ (CGFloat)calcHeightForComment:(ADCommentList *)comment {
    if (comment.height == 0) {
        comment.height = [self calcHeightForContent:comment.content WithWidth:ScreenWidth-normalHeight-inset];
    }
    return comment.height + normalHeight + inset;
}

+ (CGFloat)calcHeightForReply:(ADReplyList *)reply {
    if (reply.height == 0) {
        reply.height = [self calcHeightForContent:reply.content
                                        WithWidth: ScreenWidth-4*inset-normalHeight-inset];
    }
    return reply.height + normalHeight + inset;
}

#pragma mark - Private Methods
- (void)configureViewWithUser:(ADUser *)user
                         Date:(NSTimeInterval)date
                      Content:(NSString *)contentString {
    self.headImage.image = [UIImage getCachedImageForUrl:user.headimgurl];
    if (self.headImage.image == nil) {
        [[ADNetworkEngine sharedEngine] downloadImageForUrl:user.headimgurl
                                             WithCompletion:^(UIImage *image) {
                                                 self.headImage.image = image;
                                                 [self setNeedsDisplay];
                                             }];
    }
    self.nickName.text = user.nickname;
    self.timeStamp.text = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:date]];
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.minimumLineHeight = inset * 2;
    NSMutableAttributedString *attrContent = [[NSMutableAttributedString alloc] initWithString:contentString attributes:@{
            NSFontAttributeName: [UIFont fontWithName:kChineseFont
                                                 size:kContentFontSize],
            NSParagraphStyleAttributeName: paraStyle                                                                                                                    }];
    self.content.attributedText = attrContent;
}

+ (CGFloat)calcHeightForContent:(NSString *)contentString
                      WithWidth:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.minimumLineHeight = inset * 2;

    return CGRectGetHeight([contentString boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{
                                                                 NSFontAttributeName: [UIFont fontWithName:kChineseFont
                                                                                                      size:kContentFontSize],
                                                                 NSParagraphStyleAttributeName: paraStyle
                                                                 }
                                                       context:nil]);
}

#pragma mark - Lazy Initializers
- (UIImageView *)headImage {
    if (_headImage == nil) {
        _headImage = [[UIImageView alloc] init];
    }
    return _headImage;
}

- (UILabel *)nickName {
    if (_nickName == nil) {
        _nickName = [[UILabel alloc] init];
        _nickName.font = [UIFont fontWithName:kChineseFont
                                         size:kNickNameFontSize];
    }
    return _nickName;
}

- (UILabel *)timeStamp {
    if (_timeStamp == nil) {
        _timeStamp = [[UILabel alloc] init];
        _timeStamp.font = [UIFont fontWithName:kChineseFont
                                          size:kTimeStampFontSize];
        _timeStamp.textColor = [UIColor lightGrayColor];
        _timeStamp.textAlignment = NSTextAlignmentRight;
    }
    return _timeStamp;
}

- (UILabel *)content {
    if (_content == nil) {
        _content = [[UILabel alloc] init];
        _content.font = [UIFont fontWithName:kChineseFont
                                        size:kContentFontSize];
        _content.lineBreakMode = NSLineBreakByWordWrapping;
        _content.numberOfLines = 0;
    }
    return _content;
}

- (NSDateFormatter *)formatter {
    if (_formatter == nil) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = kTimeStampFormat;
    }
    return _formatter;
}

- (UIView *)line {
    if (_line == nil) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor lineColor];
    }
    return _line;
}

- (UITapGestureRecognizer *)tapGesture {
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(onClickContent:)];
    }
    return _tapGesture;
}

@end
