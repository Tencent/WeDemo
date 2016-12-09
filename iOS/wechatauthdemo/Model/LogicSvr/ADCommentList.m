//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ADCommentList.h"
#import "ADUser.h"
#import "ADReplyList.h"


NSString *const kADCommentListDate = @"date";
NSString *const kADCommentListId = @"id";
NSString *const kADCommentListContent = @"content";
NSString *const kADCommentListReplyCount = @"reply_count";
NSString *const kADCommentListUser = @"user";
NSString *const kADCommentListReplyList = @"reply_list";


@interface ADCommentList ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ADCommentList

@synthesize date = _date;
@synthesize commentListIdentifier = _commentListIdentifier;
@synthesize content = _content;
@synthesize replyCount = _replyCount;
@synthesize user = _user;
@synthesize replyList = _replyList;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.date = [[self objectOrNilForKey:kADCommentListDate fromDictionary:dict] doubleValue];
            self.commentListIdentifier = [self objectOrNilForKey:kADCommentListId fromDictionary:dict];
            self.content = [self objectOrNilForKey:kADCommentListContent fromDictionary:dict];
            self.replyCount = [[self objectOrNilForKey:kADCommentListReplyCount fromDictionary:dict] doubleValue];
            self.user = [ADUser modelObjectWithDictionary:[dict objectForKey:kADCommentListUser]];
    NSObject *receivedADReplyList = [dict objectForKey:kADCommentListReplyList];
    NSMutableArray *parsedADReplyList = [NSMutableArray array];
    if ([receivedADReplyList isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedADReplyList) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedADReplyList addObject:[ADReplyList modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedADReplyList isKindOfClass:[NSDictionary class]]) {
       [parsedADReplyList addObject:[ADReplyList modelObjectWithDictionary:(NSDictionary *)receivedADReplyList]];
    }

    self.replyList = [NSArray arrayWithArray:parsedADReplyList];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.date] forKey:kADCommentListDate];
    [mutableDict setValue:self.commentListIdentifier forKey:kADCommentListId];
    [mutableDict setValue:self.content forKey:kADCommentListContent];
    [mutableDict setValue:[NSNumber numberWithDouble:self.replyCount] forKey:kADCommentListReplyCount];
    [mutableDict setValue:[self.user dictionaryRepresentation] forKey:kADCommentListUser];
    NSMutableArray *tempArrayForReplyList = [NSMutableArray array];
    for (NSObject *subArrayObject in self.replyList) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForReplyList addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForReplyList addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForReplyList] forKey:kADCommentListReplyList];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.date = [aDecoder decodeDoubleForKey:kADCommentListDate];
    self.commentListIdentifier = [aDecoder decodeObjectForKey:kADCommentListId];
    self.content = [aDecoder decodeObjectForKey:kADCommentListContent];
    self.replyCount = [aDecoder decodeDoubleForKey:kADCommentListReplyCount];
    self.user = [aDecoder decodeObjectForKey:kADCommentListUser];
    self.replyList = [aDecoder decodeObjectForKey:kADCommentListReplyList];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_date forKey:kADCommentListDate];
    [aCoder encodeObject:_commentListIdentifier forKey:kADCommentListId];
    [aCoder encodeObject:_content forKey:kADCommentListContent];
    [aCoder encodeDouble:_replyCount forKey:kADCommentListReplyCount];
    [aCoder encodeObject:_user forKey:kADCommentListUser];
    [aCoder encodeObject:_replyList forKey:kADCommentListReplyList];
}

- (id)copyWithZone:(NSZone *)zone
{
    ADCommentList *copy = [[ADCommentList alloc] init];
    
    if (copy) {

        copy.date = self.date;
        copy.commentListIdentifier = [self.commentListIdentifier copyWithZone:zone];
        copy.content = [self.content copyWithZone:zone];
        copy.replyCount = self.replyCount;
        copy.user = [self.user copyWithZone:zone];
        copy.replyList = [self.replyList copyWithZone:zone];
    }
    
    return copy;
}


@end
