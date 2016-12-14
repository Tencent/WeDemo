//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import <Foundation/Foundation.h>

@class ADBaseResp;

@interface ADGetUserInfoResp : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *mail;
@property (nonatomic, strong) NSString *openid;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) ADBaseResp *baseResp;
@property (nonatomic, strong) NSString *headimgurl;
@property (nonatomic, strong) NSString *unionid;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, assign) int64_t refreshTokenExpireTime;
@property (nonatomic, assign) ADSexType sex;
@property (nonatomic, assign) int64_t accessTokenExpireTime;
@property (nonatomic, strong) NSArray *accessLog;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
