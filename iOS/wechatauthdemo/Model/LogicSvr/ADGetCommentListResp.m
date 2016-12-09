//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ADGetCommentListResp.h"
#import "ADBaseResp.h"
#import "ADCommentList.h"


NSString *const kADGetCommentListRespBaseResp = @"base_resp";
NSString *const kADGetCommentListRespCommentList = @"comment_list";
NSString *const kADGetCommentListRespCommentCount = @"comment_count";
NSString *const kADGetCommentListRespPerpage = @"perpage";


@interface ADGetCommentListResp ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ADGetCommentListResp

@synthesize baseResp = _baseResp;
@synthesize commentList = _commentList;
@synthesize commentCount = _commentCount;
@synthesize perpage = _perpage;


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
            self.baseResp = [ADBaseResp modelObjectWithDictionary:[dict objectForKey:kADGetCommentListRespBaseResp]];
    NSObject *receivedADCommentList = [dict objectForKey:kADGetCommentListRespCommentList];
    NSMutableArray *parsedADCommentList = [NSMutableArray array];
    if ([receivedADCommentList isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedADCommentList) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedADCommentList addObject:[ADCommentList modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedADCommentList isKindOfClass:[NSDictionary class]]) {
       [parsedADCommentList addObject:[ADCommentList modelObjectWithDictionary:(NSDictionary *)receivedADCommentList]];
    }

    self.commentList = [NSArray arrayWithArray:parsedADCommentList];
            self.commentCount = [[self objectOrNilForKey:kADGetCommentListRespCommentCount fromDictionary:dict] doubleValue];
            self.perpage = [[self objectOrNilForKey:kADGetCommentListRespPerpage fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.baseResp dictionaryRepresentation] forKey:kADGetCommentListRespBaseResp];
    NSMutableArray *tempArrayForCommentList = [NSMutableArray array];
    for (NSObject *subArrayObject in self.commentList) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForCommentList addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForCommentList addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForCommentList] forKey:kADGetCommentListRespCommentList];
    [mutableDict setValue:[NSNumber numberWithDouble:self.commentCount] forKey:kADGetCommentListRespCommentCount];
    [mutableDict setValue:[NSNumber numberWithDouble:self.perpage] forKey:kADGetCommentListRespPerpage];

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

    self.baseResp = [aDecoder decodeObjectForKey:kADGetCommentListRespBaseResp];
    self.commentList = [aDecoder decodeObjectForKey:kADGetCommentListRespCommentList];
    self.commentCount = [aDecoder decodeDoubleForKey:kADGetCommentListRespCommentCount];
    self.perpage = [aDecoder decodeDoubleForKey:kADGetCommentListRespPerpage];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_baseResp forKey:kADGetCommentListRespBaseResp];
    [aCoder encodeObject:_commentList forKey:kADGetCommentListRespCommentList];
    [aCoder encodeDouble:_commentCount forKey:kADGetCommentListRespCommentCount];
    [aCoder encodeDouble:_perpage forKey:kADGetCommentListRespPerpage];
}

- (id)copyWithZone:(NSZone *)zone
{
    ADGetCommentListResp *copy = [[ADGetCommentListResp alloc] init];
    
    if (copy) {

        copy.baseResp = [self.baseResp copyWithZone:zone];
        copy.commentList = [self.commentList copyWithZone:zone];
        copy.commentCount = self.commentCount;
        copy.perpage = self.perpage;
    }
    
    return copy;
}


@end
