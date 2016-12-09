//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import <Foundation/Foundation.h>

AUTH_DEMO_EXTERN NSString *const kEncryptWholePacketParaKey;

@interface ADNetworkConfigItem : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *cgiName;
@property (nonatomic, strong) NSString *encryptKeyPath;
@property (nonatomic, assign) EncryptAlgorithm encryptAlgorithm;
@property (nonatomic, assign) EncryptAlgorithm decryptAlgorithm;
@property (nonatomic, strong) NSString *requestPath;
@property (nonatomic, strong) NSString *decryptKeyPath;
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) NSString *sysErrKeyPath;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
