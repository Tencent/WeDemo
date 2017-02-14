//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ADKeyChainWrap.h"
#import <Security/Security.h>

@implementation ADKeyChainWrap

#pragma mark - Public Methods
+ (BOOL)setData:(NSData *)data ForKey:(NSString *)key {
    NSMutableDictionary *keychainQuery = [self getKeychainQueryForKey:key];
    if (keychainQuery == nil) {
        return NO;
    }
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    keychainQuery[(__bridge_transfer id)kSecValueData] = data;
    return SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL) == noErr;
}

+ (NSData *)getDataForKey:(NSString *)key {
    NSMutableDictionary *keychainQuery = [self getKeychainQueryForKey:key];
    [keychainQuery setObject:(__bridge_transfer id)kCFBooleanTrue
                      forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne
                      forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    NSData *ret = nil;

    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        ret = (__bridge_transfer NSData*)keyData;
    }
    return ret;
}

+ (BOOL)deleteDataForKey:(NSString *)key {
    NSMutableDictionary *keychainQuery = [self getKeychainQueryForKey:key];
    return SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery) == noErr;
}

#pragma mark - Private Methods
+ (NSMutableDictionary *)getKeychainQueryForKey:(NSString *)key {
    if (key == nil) {
        return nil;
    }
    return [@{
              (__bridge_transfer id)kSecClass: (__bridge_transfer id)kSecClassGenericPassword,
              (__bridge_transfer id)kSecAttrService: key
              } mutableCopy];
}

@end
