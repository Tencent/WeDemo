//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ADAddReplyResp.h"
#import "ADBaseResp.h"
#import "ADReplyList.h"


NSString *const kADAddReplyRespBaseResp = @"base_resp";
NSString *const kADAddReplyRespReply = @"reply";


@interface ADAddReplyResp ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ADAddReplyResp

@synthesize baseResp = _baseResp;
@synthesize reply = _reply;


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
            self.baseResp = [ADBaseResp modelObjectWithDictionary:[dict objectForKey:kADAddReplyRespBaseResp]];
            self.reply = [ADReplyList modelObjectWithDictionary:[dict objectForKey:kADAddReplyRespReply]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.baseResp dictionaryRepresentation] forKey:kADAddReplyRespBaseResp];
    [mutableDict setValue:[self.reply dictionaryRepresentation] forKey:kADAddReplyRespReply];

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

    self.baseResp = [aDecoder decodeObjectForKey:kADAddReplyRespBaseResp];
    self.reply = [aDecoder decodeObjectForKey:kADAddReplyRespReply];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_baseResp forKey:kADAddReplyRespBaseResp];
    [aCoder encodeObject:_reply forKey:kADAddReplyRespReply];
}

- (id)copyWithZone:(NSZone *)zone
{
    ADAddReplyResp *copy = [[ADAddReplyResp alloc] init];
    
    if (copy) {

        copy.baseResp = [self.baseResp copyWithZone:zone];
        copy.reply = [self.reply copyWithZone:zone];
    }
    
    return copy;
}


@end
