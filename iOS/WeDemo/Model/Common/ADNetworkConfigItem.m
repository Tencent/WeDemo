//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ADNetworkConfigItem.h"

NSString *const kADNetworkConfigItemCgiName = @"cgi_name";
NSString *const kADNetworkConfigItemEncryptKeyPath = @"encrypt_key_path";
NSString *const kADNetworkConfigItemEncryptAlgorithm = @"encrypt_algorithm";
NSString *const kADNetworkConfigItemDecryptAlgorithm = @"decrypt_algorithm";
NSString *const kADNetworkConfigItemRequestPath = @"request_path";
NSString *const kADNetworkConfigItemDecryptKeyPath = @"decrypt_key_path";
NSString *const kADNetworkConfigItemHttpMethod = @"http_method";
NSString *const kADNetworkConfigItemSysErrKeyPath = @"sys_err_key_path";

NSString *const kEncryptWholePacketParaKey = @"kEncryptWholePacketParaKey";


@interface ADNetworkConfigItem ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ADNetworkConfigItem

@synthesize cgiName = _cgiName;
@synthesize encryptKeyPath = _encryptKeyPath;
@synthesize encryptAlgorithm = _encryptAlgorithm;
@synthesize decryptAlgorithm = _decryptAlgorithm;
@synthesize requestPath = _requestPath;
@synthesize decryptKeyPath = _decryptKeyPath;
@synthesize httpMethod = _httpMethod;
@synthesize sysErrKeyPath = _sysErrKeyPath;

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
            self.cgiName = [self objectOrNilForKey:kADNetworkConfigItemCgiName fromDictionary:dict];
            self.encryptKeyPath = [self objectOrNilForKey:kADNetworkConfigItemEncryptKeyPath fromDictionary:dict];
            self.encryptAlgorithm = [[self objectOrNilForKey:kADNetworkConfigItemEncryptAlgorithm fromDictionary:dict] intValue];
            self.decryptAlgorithm = [[self objectOrNilForKey:kADNetworkConfigItemDecryptAlgorithm fromDictionary:dict] intValue];
            self.requestPath = [self objectOrNilForKey:kADNetworkConfigItemRequestPath fromDictionary:dict];
            self.decryptKeyPath = [self objectOrNilForKey:kADNetworkConfigItemDecryptKeyPath fromDictionary:dict];
            self.httpMethod = [self objectOrNilForKey:kADNetworkConfigItemHttpMethod fromDictionary:dict];
            self.sysErrKeyPath = [self objectOrNilForKey:kADNetworkConfigItemSysErrKeyPath fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.cgiName forKey:kADNetworkConfigItemCgiName];
    [mutableDict setValue:self.encryptKeyPath forKey:kADNetworkConfigItemEncryptKeyPath];
    [mutableDict setValue:[NSNumber numberWithDouble:self.encryptAlgorithm] forKey:kADNetworkConfigItemEncryptAlgorithm];
    [mutableDict setValue:[NSNumber numberWithDouble:self.decryptAlgorithm] forKey:kADNetworkConfigItemDecryptAlgorithm];
    [mutableDict setValue:self.requestPath forKey:kADNetworkConfigItemRequestPath];
    [mutableDict setValue:self.decryptKeyPath forKey:kADNetworkConfigItemDecryptKeyPath];
    [mutableDict setValue:self.httpMethod forKey:kADNetworkConfigItemHttpMethod];
    [mutableDict setValue:self.sysErrKeyPath forKey:kADNetworkConfigItemSysErrKeyPath];
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

    self.cgiName = [aDecoder decodeObjectForKey:kADNetworkConfigItemCgiName];
    self.encryptKeyPath = [aDecoder decodeObjectForKey:kADNetworkConfigItemEncryptKeyPath];
    self.encryptAlgorithm = [aDecoder decodeDoubleForKey:kADNetworkConfigItemEncryptAlgorithm];
    self.decryptAlgorithm = [aDecoder decodeDoubleForKey:kADNetworkConfigItemDecryptAlgorithm];
    self.requestPath = [aDecoder decodeObjectForKey:kADNetworkConfigItemRequestPath];
    self.decryptKeyPath = [aDecoder decodeObjectForKey:kADNetworkConfigItemDecryptKeyPath];
    self.httpMethod = [aDecoder decodeObjectForKey:kADNetworkConfigItemHttpMethod];
    self.sysErrKeyPath = [aDecoder decodeObjectForKey:kADNetworkConfigItemSysErrKeyPath];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_cgiName forKey:kADNetworkConfigItemCgiName];
    [aCoder encodeObject:_encryptKeyPath forKey:kADNetworkConfigItemEncryptKeyPath];
    [aCoder encodeDouble:_encryptAlgorithm forKey:kADNetworkConfigItemEncryptAlgorithm];
    [aCoder encodeDouble:_decryptAlgorithm forKey:kADNetworkConfigItemDecryptAlgorithm];
    [aCoder encodeObject:_requestPath forKey:kADNetworkConfigItemRequestPath];
    [aCoder encodeObject:_decryptKeyPath forKey:kADNetworkConfigItemDecryptKeyPath];
    [aCoder encodeObject:_httpMethod forKey:kADNetworkConfigItemHttpMethod];
    [aCoder encodeObject:_sysErrKeyPath forKey:kADNetworkConfigItemSysErrKeyPath];
}

- (id)copyWithZone:(NSZone *)zone
{
    ADNetworkConfigItem *copy = [[ADNetworkConfigItem alloc] init];
    
    if (copy) {

        copy.cgiName = [self.cgiName copyWithZone:zone];
        copy.encryptKeyPath = [self.encryptKeyPath copyWithZone:zone];
        copy.encryptAlgorithm = self.encryptAlgorithm;
        copy.decryptAlgorithm = self.decryptAlgorithm;
        copy.requestPath = [self.requestPath copyWithZone:zone];
        copy.decryptKeyPath = [self.decryptKeyPath copyWithZone:zone];
        copy.httpMethod = [self.httpMethod copyWithZone:zone];
        copy.sysErrKeyPath = [self.sysErrKeyPath copyWithZone:zone];
    }
    
    return copy;
}


@end
