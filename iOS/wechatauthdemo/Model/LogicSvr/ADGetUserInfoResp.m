//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ADGetUserInfoResp.h"
#import "ADBaseResp.h"
#import "ADAccessLog.h"


NSString *const kADGetUserInfoRespMail = @"mail";
NSString *const kADGetUserInfoRespOpenid = @"openid";
NSString *const kADGetUserInfoRespNickname = @"nickname";
NSString *const kADGetUserInfoRespBaseResp = @"base_resp";
NSString *const kADGetUserInfoRespHeadimgurl = @"headimgurl";
NSString *const kADGetUserInfoRespUnionid = @"unionid";
NSString *const kADGetUserInfoRespRefreshTokenExpireTime = @"refresh_token_expire_time";
NSString *const kADGetUserInfoRespSex = @"sex";
NSString *const kADGetUserInfoRespAccessTokenExpireTime = @"access_token_expire_time";
NSString *const kADGetUserInfoRespAccessLog = @"access_log";
NSString *const kADGetUserInfoRespCity = @"city";
NSString *const kADGetUserInfoRespProvince = @"province";
NSString *const kADGetUserInfoRespCountry = @"country";

@interface ADGetUserInfoResp ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ADGetUserInfoResp

@synthesize mail = _mail;
@synthesize openid = _openid;
@synthesize nickname = _nickname;
@synthesize baseResp = _baseResp;
@synthesize headimgurl = _headimgurl;
@synthesize unionid = _unionid;
@synthesize refreshTokenExpireTime = _refreshTokenExpireTime;
@synthesize sex = _sex;
@synthesize accessTokenExpireTime = _accessTokenExpireTime;
@synthesize accessLog = _accessLog;
@synthesize city = _city;
@synthesize province = _province;
@synthesize country = _country;

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
            self.mail = [self objectOrNilForKey:kADGetUserInfoRespMail fromDictionary:dict];
            self.openid = [self objectOrNilForKey:kADGetUserInfoRespOpenid fromDictionary:dict];
            self.nickname = [self objectOrNilForKey:kADGetUserInfoRespNickname fromDictionary:dict];
            self.baseResp = [ADBaseResp modelObjectWithDictionary:[dict objectForKey:kADGetUserInfoRespBaseResp]];
            self.headimgurl = [self objectOrNilForKey:kADGetUserInfoRespHeadimgurl fromDictionary:dict];
            self.unionid = [self objectOrNilForKey:kADGetUserInfoRespUnionid fromDictionary:dict];
            self.refreshTokenExpireTime = [[self objectOrNilForKey:kADGetUserInfoRespRefreshTokenExpireTime fromDictionary:dict] doubleValue];
            self.sex = [[self objectOrNilForKey:kADGetUserInfoRespSex fromDictionary:dict] intValue];
            self.accessTokenExpireTime = [[self objectOrNilForKey:kADGetUserInfoRespAccessTokenExpireTime fromDictionary:dict] doubleValue];
            self.city = [self objectOrNilForKey:kADGetUserInfoRespCity
                                 fromDictionary:dict];
            self.province = [self objectOrNilForKey:kADGetUserInfoRespProvince
                                     fromDictionary:dict];
            self.country = [self objectOrNilForKey:kADGetUserInfoRespCountry
                                    fromDictionary:dict];
    NSObject *receivedADAccessLog = [dict objectForKey:kADGetUserInfoRespAccessLog];
    NSMutableArray *parsedADAccessLog = [NSMutableArray array];
    if ([receivedADAccessLog isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedADAccessLog) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedADAccessLog addObject:[ADAccessLog modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedADAccessLog isKindOfClass:[NSDictionary class]]) {
       [parsedADAccessLog addObject:[ADAccessLog modelObjectWithDictionary:(NSDictionary *)receivedADAccessLog]];
    }

    self.accessLog = [NSArray arrayWithArray:parsedADAccessLog];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.mail forKey:kADGetUserInfoRespMail];
    [mutableDict setValue:self.openid forKey:kADGetUserInfoRespOpenid];
    [mutableDict setValue:self.nickname forKey:kADGetUserInfoRespNickname];
    [mutableDict setValue:[self.baseResp dictionaryRepresentation] forKey:kADGetUserInfoRespBaseResp];
    [mutableDict setValue:self.headimgurl forKey:kADGetUserInfoRespHeadimgurl];
    [mutableDict setValue:self.unionid forKey:kADGetUserInfoRespUnionid];
    [mutableDict setValue:[NSNumber numberWithDouble:self.refreshTokenExpireTime] forKey:kADGetUserInfoRespRefreshTokenExpireTime];
    [mutableDict setValue:[NSNumber numberWithDouble:self.sex] forKey:kADGetUserInfoRespSex];
    [mutableDict setValue:[NSNumber numberWithDouble:self.accessTokenExpireTime] forKey:kADGetUserInfoRespAccessTokenExpireTime];
    NSMutableArray *tempArrayForAccessLog = [NSMutableArray array];
    for (NSObject *subArrayObject in self.accessLog) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForAccessLog addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForAccessLog addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForAccessLog] forKey:kADGetUserInfoRespAccessLog];

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

    self.mail = [aDecoder decodeObjectForKey:kADGetUserInfoRespMail];
    self.openid = [aDecoder decodeObjectForKey:kADGetUserInfoRespOpenid];
    self.nickname = [aDecoder decodeObjectForKey:kADGetUserInfoRespNickname];
    self.baseResp = [aDecoder decodeObjectForKey:kADGetUserInfoRespBaseResp];
    self.headimgurl = [aDecoder decodeObjectForKey:kADGetUserInfoRespHeadimgurl];
    self.unionid = [aDecoder decodeObjectForKey:kADGetUserInfoRespUnionid];
    self.refreshTokenExpireTime = [aDecoder decodeDoubleForKey:kADGetUserInfoRespRefreshTokenExpireTime];
    self.sex = [aDecoder decodeDoubleForKey:kADGetUserInfoRespSex];
    self.accessTokenExpireTime = [aDecoder decodeDoubleForKey:kADGetUserInfoRespAccessTokenExpireTime];
    self.accessLog = [aDecoder decodeObjectForKey:kADGetUserInfoRespAccessLog];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_mail forKey:kADGetUserInfoRespMail];
    [aCoder encodeObject:_openid forKey:kADGetUserInfoRespOpenid];
    [aCoder encodeObject:_nickname forKey:kADGetUserInfoRespNickname];
    [aCoder encodeObject:_baseResp forKey:kADGetUserInfoRespBaseResp];
    [aCoder encodeObject:_headimgurl forKey:kADGetUserInfoRespHeadimgurl];
    [aCoder encodeObject:_unionid forKey:kADGetUserInfoRespUnionid];
    [aCoder encodeDouble:_refreshTokenExpireTime forKey:kADGetUserInfoRespRefreshTokenExpireTime];
    [aCoder encodeDouble:_sex forKey:kADGetUserInfoRespSex];
    [aCoder encodeDouble:_accessTokenExpireTime forKey:kADGetUserInfoRespAccessTokenExpireTime];
    [aCoder encodeObject:_accessLog forKey:kADGetUserInfoRespAccessLog];
}

- (id)copyWithZone:(NSZone *)zone
{
    ADGetUserInfoResp *copy = [[ADGetUserInfoResp alloc] init];
    
    if (copy) {

        copy.mail = [self.mail copyWithZone:zone];
        copy.openid = [self.openid copyWithZone:zone];
        copy.nickname = [self.nickname copyWithZone:zone];
        copy.baseResp = [self.baseResp copyWithZone:zone];
        copy.headimgurl = [self.headimgurl copyWithZone:zone];
        copy.unionid = [self.unionid copyWithZone:zone];
        copy.refreshTokenExpireTime = self.refreshTokenExpireTime;
        copy.sex = self.sex;
        copy.accessTokenExpireTime = self.accessTokenExpireTime;
        copy.accessLog = [self.accessLog copyWithZone:zone];
    }
    
    return copy;
}


@end
