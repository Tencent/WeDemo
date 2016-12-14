//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "BaseNetworkEngine.h"
#import "ADNetworkConfigManager.h"
#import "JSONRequest.h"
#import "DataModels.h"
#import "ImageCache.h"
#import "RandomKey.h"

#warning replace your own server address here
static NSString* const defaultHost = @"https://wechatauthdemo.com";
static NSString* const publickeyFileName = @"rsa_public";

@interface BaseNetworkEngine ()

@property (nonatomic, strong, readwrite) AFURLSessionManager *manager;

@end

@implementation BaseNetworkEngine

#pragma mark - Life Cycle
+ (instancetype)sharedEngine {
    static NSMutableDictionary *instanceMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceMap = [NSMutableDictionary dictionary];
    });
    NSString *className = NSStringFromClass([self class]);
    @synchronized(instanceMap) {
        if (instanceMap[className]) {
            return instanceMap[className];
        } else {
            return instanceMap[className] = [[[self class] alloc] initWithHost:defaultHost];
        }
    }
}

- (instancetype)initWithHost:(NSString *)host {
    if (self = [super init]) {
        self.host = host;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (instancetype)copy {
    return nil;
}

#pragma mark - Public Methods
- (void)connectToServerWithCompletion:(ConnectCallBack)completion {
    [[self.manager JSONTaskForHost:self.host
                              Para:@{
                                     @"psk": self.manager.sessionKey
                                     }
                     ConfigKeyPath:(NSString *)kConnectCGIName
                    WithCompletion:^(NSDictionary *dict, NSError *error) {
                        if (completion)
                            completion (error == nil ? [ADConnectResp modelObjectWithDictionary:dict] : nil);
                    }] resume];
}

- (void)wxLoginForAuthCode:(NSString *)code
            WithCompletion:(WXLoginCallBack)completion {
    NSParameterAssert(code);
    [[self.manager JSONTaskForHost:self.host
                              Para:@{
                                     @"uin": @([ADUserInfo currentUser].uin),
                                     @"req_buffer": @{
                                             @"code": code
                                             }
                                     }
                     ConfigKeyPath:(NSString *)kWXLoginCGIName
                    WithCompletion:^(NSDictionary *dict, NSError *error) {
                        if (completion)
                            completion (error == nil ? [ADWXLoginResp modelObjectWithDictionary:dict] : nil);
                    }] resume];
}

- (void)checkLoginForUin:(UInt32)uin
             LoginTicket:(NSString *)loginTicket
          WithCompletion:(CheckLoginCallBack)completion {
    NSParameterAssert(loginTicket);
    [[self.manager JSONTaskForHost:self.host
                              Para:@{
                                     @"uin": @(uin),
                                     @"login_ticket": loginTicket,
                                     @"tmp_key": self.manager.sessionKey
                                     }
                     ConfigKeyPath:(NSString *)kCheckLoginCGIName
                    WithCompletion:^(NSDictionary *dict, NSError *error) {
                        ADCheckLoginResp *resp = nil;
                        if (error == nil) {
                            resp = [ADCheckLoginResp modelObjectWithDictionary:dict];
                            if (resp.baseResp.errcode == ADErrorCodeNoError) {
                                self.manager.sessionKey = resp.sessionKey;
                            }
                        }
                        if (completion)
                            completion(resp);
                    }] resume];
}

- (void)getUserInfoForUin:(UInt32)uin
              LoginTicket:(NSString *)loginTicket
           WithCompletion:(GetUserInfoCallBack)completion {
    NSParameterAssert(loginTicket);
    [[self.manager JSONTaskForHost:self.host
                              Para:@{
                                     @"uin": @(uin),
                                     @"req_buffer": @{
                                             @"login_ticket": loginTicket,
                                             @"uin": @(uin)
                                             }
                                     }
                     ConfigKeyPath:(NSString *)kGetUserInfoCGIName
                    WithCompletion:^(NSDictionary *dict, NSError *error) {
                        ADGetUserInfoResp *resp = [ADGetUserInfoResp modelObjectWithDictionary:dict];
                        [ErrorHandler handleNetworkExpiredError:resp.baseResp
                                            WhileCatchErrorCode:^(ADErrorCode code) {
                                                if (code == ADErrorCodeSessionKeyExpired) {
                                                    [self getUserInfoForUin:uin
                                                                LoginTicket:loginTicket
                                                             WithCompletion:completion];
                                                } else {
                                                    completion != nil ? completion (resp) : nil;
                                                }
                                            }];
                    }] resume];
}

- (void)disConnect {
    self.manager = nil;
}

- (void)downloadImageForUrl:(NSString *)urlString
             WithCompletion:(DownloadImageCallBack)completion {
    if (!urlString || !completion)
        return;
    UIImage *cachedImage = [UIImage getCachedImageForUrl:urlString];
    if (cachedImage) {
        NSLog(@"Cache Hit");
        completion (cachedImage);
    } else {
        NSLog(@"Cache Miss");
        NSURL *url = [NSURL URLWithString:urlString];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:data];
                [image cacheForUrl:urlString];
                completion (image);
            });
        });
    }
}

- (void)makeRefreshTokenExpired:(UInt32)uin
                    LoginTicket:(NSString *)loginTicket {
    [[self.manager JSONTaskForHost:self.host
                              Para:@{
                                     @"uin": @(uin),
                                     @"req_buffer": @{
                                             @"uin": @(uin),
                                             @"login_ticket": loginTicket
                                             }
                                     }
                     ConfigKeyPath:(NSString *)kMakeExpiredCGIName
                    WithCompletion:^(NSDictionary *dict, NSError *error) {
                        NSLog(@"%@",dict);
                    }] resume];
}

#pragma mark - Lazy Initializer
- (AFURLSessionManager *)manager {
    if (_manager == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
        AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        _manager.responseSerializer = serializer;
        _manager.sessionKey = [NSString randomKey];
        _manager.publicKey = self.RSAKey;
    }
    return _manager;
}

- (NSString *)RSAKey {
    return @"-----BEGIN PUBLIC KEY-----\n\
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvNqqzcNyCDAQdCq+SZNv\n\
    8PX5C1MnxoVMAUBqT4Sbl8vEpNkTg4Ng+bWrBjUU6P++g4dK4e+Dp8RaauS2+kAm\n\
    ScJLp6tKms0gt9POfC79s3JZqlG8TiRvbJZ9ez5rKjSI2JueqwXPVQsnJigTWxX6\n\
    hQ8W6jLFgQ7UoSTHvcIRnebg8Bz0EAUrO7F3GOzsDv6tQ2Rg5MTWCsfSLyF1fQ0J\n\
    NeEBaZVyb8WoUdBroOa0vsYQPv8TLLkjr78vld2GVcJK7QjnmLbqQEQDNo1UWA97\n\
    AOIDcRDkF0UT36a+A9HL8sq05k2QZehtDG7aa5UnqAbLtDhRTlPwuvuBIbNrKU0V\n\
    qwIDAQAB\n\
    -----END PUBLIC KEY-----";
}

@end
