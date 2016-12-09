//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ADReplyList.h"
#import "ADUser.h"


NSString *const kADReplyListUser = @"user";
NSString *const kADReplyListId = @"id";
NSString *const kADReplyListContent = @"content";
NSString *const kADReplyListReplyToId = @"reply_to_id";
NSString *const kADReplyListDate = @"date";


@interface ADReplyList ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ADReplyList

@synthesize user = _user;
@synthesize replyListIdentifier = _replyListIdentifier;
@synthesize content = _content;
@synthesize replyToId = _replyToId;
@synthesize date = _date;


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
            self.user = [ADUser modelObjectWithDictionary:[dict objectForKey:kADReplyListUser]];
            self.replyListIdentifier = [self objectOrNilForKey:kADReplyListId fromDictionary:dict];
            self.content = [self objectOrNilForKey:kADReplyListContent fromDictionary:dict];
            self.replyToId = [self objectOrNilForKey:kADReplyListReplyToId fromDictionary:dict];
            self.date = [[self objectOrNilForKey:kADReplyListDate fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.user dictionaryRepresentation] forKey:kADReplyListUser];
    [mutableDict setValue:self.replyListIdentifier forKey:kADReplyListId];
    [mutableDict setValue:self.content forKey:kADReplyListContent];
    [mutableDict setValue:self.replyToId forKey:kADReplyListReplyToId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.date] forKey:kADReplyListDate];

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

    self.user = [aDecoder decodeObjectForKey:kADReplyListUser];
    self.replyListIdentifier = [aDecoder decodeObjectForKey:kADReplyListId];
    self.content = [aDecoder decodeObjectForKey:kADReplyListContent];
    self.replyToId = [aDecoder decodeObjectForKey:kADReplyListReplyToId];
    self.date = [aDecoder decodeDoubleForKey:kADReplyListDate];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_user forKey:kADReplyListUser];
    [aCoder encodeObject:_replyListIdentifier forKey:kADReplyListId];
    [aCoder encodeObject:_content forKey:kADReplyListContent];
    [aCoder encodeObject:_replyToId forKey:kADReplyListReplyToId];
    [aCoder encodeDouble:_date forKey:kADReplyListDate];
}

- (id)copyWithZone:(NSZone *)zone
{
    ADReplyList *copy = [[ADReplyList alloc] init];
    
    if (copy) {

        copy.user = [self.user copyWithZone:zone];
        copy.replyListIdentifier = [self.replyListIdentifier copyWithZone:zone];
        copy.content = [self.content copyWithZone:zone];
        copy.replyToId = [self.replyToId copyWithZone:zone];
        copy.date = self.date;
    }
    
    return copy;
}


@end
