//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "JSONRequest.h"
#import <objc/runtime.h>
#import "ADNetworkConfigManager.h"
#import "ADNetworkConfigItem.h"
#import "AES.h"
#import "RSA.h"

@implementation AFURLSessionManager (SessionKey)

static char publicKeyId;
static char sessionKeyId;

- (NSString *)sessionKey {
    return objc_getAssociatedObject(self, &sessionKeyId);
}

- (void)setSessionKey:(NSString *)sessionKey {
    objc_setAssociatedObject(self, &sessionKeyId, sessionKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)publicKey {
    return objc_getAssociatedObject(self, &publicKeyId);
}

- (void)setPublicKey:(NSString *)publicKey {
    objc_setAssociatedObject(self, &publicKeyId, publicKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation AFURLSessionManager (JSONRequest)

- (NSURLSessionTask *)JSONTaskForHost:(NSString *)host
                                 Para:(NSDictionary *)para
                        ConfigKeyPath:(NSString *)configKeyPath
                       WithCompletion:(JSONCallBack)handler {
    ADNetworkConfigItem *config = [[ADNetworkConfigManager sharedManager] getConfigForKeyPath:configKeyPath];
    if (config == nil) {
        NSLog(@"Configure Item Not Exist For This Request: %@", configKeyPath);
        return nil;
    }
    
    NSLog(@"Request:%@\n CGIConfig: \n%@\nPara: %@\n",host, [config dictionaryRepresentation], para);
    /* Encrypt Data */
    NSData *encryptedData = [self encryptJSONObject:para
                                         ForKeyPath:config.encryptKeyPath
                                     UsingAlgorithm:config.encryptAlgorithm];
    NSLog(@"RequestEncryptData: %@", [[NSString alloc] initWithData:encryptedData encoding:NSUTF8StringEncoding]);
    /* 异步请求，在这里备份一份SessionKey，防止返回前SessionKey被修改。*/
    NSString *preSessionKey = self.sessionKey;
    /* Setup Request */
    NSURL *url = [NSURL URLWithString:[host stringByAppendingFormat:@"%@",config.requestPath]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:config.httpMethod];
    [request setHTTPBody:encryptedData];
    if ([[url scheme] isEqualToString:@"https"]) {
        NSSet *cert = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
        AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate
                                                             withPinnedCertificates:cert];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = YES;
        self.securityPolicy = securityPolicy;
    } else {
        self.securityPolicy = [AFSecurityPolicy defaultPolicy];
    }
    return [self dataTaskWithRequest:request
                   completionHandler:^(NSURLResponse * response, id responseObject, NSError* error) {
                       NSDictionary *dict = (NSDictionary *)responseObject;
                       /* Process Network Error */
                       if (error) {
                           NSLog(@"NetWork Error: %@", error);
                           dispatch_async(dispatch_get_main_queue(), ^{
                               handler (nil, error);
                           });
                           return;
                       }
                       /* Process Response Error */
                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                       if (httpResponse.statusCode != 200) {
                           NSLog(@"HTTP Bad Response: %ld", (long)httpResponse.statusCode);
                           dispatch_async(dispatch_get_main_queue(), ^{
                               NSError *httpError = [NSError errorWithDomain:@"Http Response Error"
                                                                        code:httpResponse.statusCode
                                                                    userInfo:nil];
                               handler (nil, httpError);
                           });
                           return;
                       }
                       NSLog(@"ResponseCGI=%@\nResponse: %@\n", config.cgiName, dict);
                       /* Decrypt Dict */
                       dict = [self decryptJSONObject:dict
                                           ForKeyPath:config.decryptKeyPath
                                       UsingAlgorithm:config.decryptAlgorithm
                                       WithSessionKey:preSessionKey];
                       if (dict == nil) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               NSError *error = [NSError errorWithDomain:@"AppDescryptError"
                                                                    code:ADErrorCodeClientDescryptError
                                                                userInfo:nil];
                               
                               handler (nil, error);
                           });
                       }
                       NSLog(@"DecryptData: %@", dict);
                       
                       /* Get Response Buffer */
                       NSString *respString = dict[config.decryptKeyPath];
                       
                       /* Process System Error */
                       if ((respString == nil || [respString length] == 0)
                           && dict[config.sysErrKeyPath] != nil) {
                           int errorCode = [dict[config.sysErrKeyPath] intValue];
                           NSLog(@"System Error Code = %d", errorCode);
                           NSError *sysError = [NSError errorWithDomain:@"SystemError"
                                                                   code:errorCode
                                                               userInfo:dict];
                           dispatch_async(dispatch_get_main_queue(), ^{
                               handler (nil, sysError);
                           });
                           return;
                       }
                       
                       /* Get Response JSON */
                       NSData *data = [respString dataUsingEncoding:NSUTF8StringEncoding];
                       NSError *jsonError = nil;
                       dict = [NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingAllowFragments
                                                                error:&jsonError];
                       if (jsonError) {
                           NSLog(@"JSON Error: %@ While Serialize %@", jsonError, respString);
                           dispatch_async(dispatch_get_main_queue(), ^{
                               handler (nil, jsonError);
                           });
                           return;
                       }
                       
                       /* Ok, Return */
                       dispatch_async(dispatch_get_main_queue(), ^{
                           handler (dict, nil);
                       });
                   }];
}

- (NSData *)encryptJSONObject:(NSDictionary *)dict
                   ForKeyPath:(NSString *)keyPath
               UsingAlgorithm:(EncryptAlgorithm)algorithm {
    NSObject *toEncryptObject = [keyPath isEqualToString:kEncryptWholePacketParaKey] ? dict : dict[keyPath];
    /* Convert Object to Data */
    NSData *toEncryptData = nil;
    if ([toEncryptObject isKindOfClass:[NSDictionary class]]) {  /* Process Dictionary */
        NSError *jsonError = nil;
        toEncryptData = [NSJSONSerialization dataWithJSONObject:toEncryptObject
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&jsonError];
        if (jsonError) {
            NSLog(@"JSON Error: %@", jsonError);
            return nil;
        }
    } else if ([toEncryptObject isKindOfClass:[NSString class]]) {   /* Process String */
        NSString *stringObject = (NSString *)toEncryptObject;
        toEncryptData = [stringObject dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([toEncryptObject isKindOfClass:[NSNumber class]]) {   /* Process Number */
        NSNumber *numberObject = (NSNumber *)toEncryptObject;
        NSString *numberString = [numberObject stringValue];
        toEncryptData = [numberString dataUsingEncoding:NSUTF8StringEncoding];
    }
    /* Encrypt NSData */
    if (algorithm & EncryptAlgorithmRSA) {  /* RSA */
        toEncryptData = [toEncryptData RSAEncryptWithPublicKey:self.publicKey];
    }
    if (algorithm & EncryptAlgorithmAES) {  /* AES */
        toEncryptData = [toEncryptData AES256EncryptWithKey:self.sessionKey];
    }
    if (algorithm & EncryptAlgorithmBase64) {   /* Base64 */
        toEncryptData = [toEncryptData base64EncodedDataWithOptions:0];
    }
    
    if ([keyPath isEqualToString:kEncryptWholePacketParaKey])
        return toEncryptData;
    /* Replace Object for KeyPath */
    if (toEncryptData == nil)
        return nil;
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    [mutableDict setObject:[[NSString alloc] initWithData:toEncryptData
                                                 encoding:NSUTF8StringEncoding]
                    forKey:keyPath];
    /* And Setup JSON */
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError];
    if (jsonError) {
        NSLog(@"JSON Error: %@", jsonError);
        return nil;
    }
    return jsonData;
}

- (NSDictionary *)decryptJSONObject:(NSDictionary *)dict
                         ForKeyPath:(NSString *)keyPath
                     UsingAlgorithm:(EncryptAlgorithm)algorithm
                     WithSessionKey:(NSString *)sessionKey {
    NSObject *object = [dict objectForKey:keyPath];
    if (algorithm == EncryptAlgorithmNone || object == nil)
        return dict;
    
    NSData *toDecryptData = nil;
    /* Convert Object to Data */
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSError *jsonError = nil;
        toDecryptData = [NSJSONSerialization dataWithJSONObject:object
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&jsonError];
        if (jsonError) {
            NSLog(@"JSON Error: %@", jsonError);
            return dict;
        }
    } else if ([object isKindOfClass:[NSString class]]) {
        NSString *stringObject = (NSString *)object;
        toDecryptData = [stringObject dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *numberObject = (NSNumber *)object;
        NSString *numberString = [numberObject stringValue];
        toDecryptData = [numberString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    /* Decrypt NSData */
    if (algorithm & EncryptAlgorithmBase64) {
        toDecryptData = [[NSData alloc] initWithBase64EncodedData:toDecryptData
                                                          options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    if (algorithm & EncryptAlgorithmAES) {
        toDecryptData = [toDecryptData AES256DecryptWithKey:sessionKey];
    }
    /* Decrypt Fail */
    if (toDecryptData == nil)
        return nil;
    
    /* Rplace Object for KeyPath */
    NSString *decryptedString = [[NSString alloc] initWithData:toDecryptData
                                                      encoding:NSUTF8StringEncoding];
    /* Crash保护 */
    if (decryptedString == nil)
        return nil;
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    [mutableDict setObject:decryptedString
                    forKey:keyPath];
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}


@end
