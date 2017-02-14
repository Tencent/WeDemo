//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import <Foundation/Foundation.h>
@class AFURLSessionManager;
@class ADConnectResp;
@class ADCheckLoginResp;
@class ADGetUserInfoResp;
@class ADWXLoginResp;

typedef void(^ConnectCallBack)(ADConnectResp *resp);
typedef void(^CheckLoginCallBack)(ADCheckLoginResp *resp);
typedef void(^GetUserInfoCallBack)(ADGetUserInfoResp *resp);
typedef void(^WXLoginCallBack)(ADWXLoginResp *resp);
typedef void(^DownloadImageCallBack)(UIImage *image);

@interface BaseNetworkEngine : NSObject

@property (nonatomic, strong, readonly) AFURLSessionManager *manager;

@property (nonatomic, strong, readonly) NSString *RSAKey;

@property (nonatomic, strong) NSString *host;

/**
 *  严格单例，唯一获得实例的方法.
 *
 *  @return 实例对象.
 */
+ (instancetype)sharedEngine;

/**
 *  与服务器握手，交换psk建立登录前的安全通道.
 *
 *  @abstract 客户端通过RSA加密一个随机密钥psk给服务器，服务器解密后保存.
 *  之后双方的通信（登录前）都采用psk作为key进行AES加密报文.
 *
 *  @param completion 握手完成的回调，参数包括一个临时的Uin，以后的请求都需要带上这个Uin以让服务器可以索引到对应的psk.
 */
- (void)connectToServerWithCompletion:(ConnectCallBack)completion;

/**
 *  微信登录.
 *
 *  @restrict 必须在登录前安全通道进行.
 *
 *  @param code       微信授权后获得的code
 *  @param completion 微信登录完成的回调，参数包括一个正式Uin和登录票据
 */
- (void)wxLoginForAuthCode:(NSString *)code
            WithCompletion:(WXLoginCallBack)completion;


/**
 *  用正式Uin和登录票据进行登录服务器，建立服务器和客户端之间正式安全通道.
 *
 *  @abstract 可以理解为这一步才是真正的登录，前面的注册/登录/微信登录只是为了换取登录票据.
 *  客户端通过RSA加密{uin，loginTicket, 一个临时密钥tempKey}给服务器，然后检查Uin和LoginTicket,
 *  用tempKey加密这个请求的回包，回包里包括了这个会话之后的密钥SessionKey，以后就用这个SessionKey加密通信.
 *
 *  @param uin         正式Uin
 *  @param loginTicket 登录票据
 *  @param completion  正式安全通道建立完成的回调，参数包括SessionKey和SessionKey过期时间
 */
- (void)checkLoginForUin:(UInt32)uin
             LoginTicket:(NSString *)loginTicket
          WithCompletion:(CheckLoginCallBack)completion;

/**
 *  获得用户信息.
 *
 *  @restrict 必须在正式安全通道里进行.
 *
 *  @param uin         正式Uin
 *  @param loginTicket 登录票据
 *  @param completion  获得用户信息完成的回调，参数包括用户的一些基本信息.
 */
- (void)getUserInfoForUin:(UInt32)uin
              LoginTicket:(NSString *)loginTicket
           WithCompletion:(GetUserInfoCallBack)completion;

/**
 *  退出登录.
 */
- (void)disConnect;

/**
 *  下载或从缓存里获得一张图像数据.
 *
 *  @param urlString  图像Url
 *  @param completion 获得完成的回调，参数包括图像数据.
 */
- (void)downloadImageForUrl:(NSString *)urlString
             WithCompletion:(DownloadImageCallBack)completion;

/**
 *  测试功能，强制让Refresh Token快速过期，以让App展现提示用户重新授权/登录的行为.
 *
 *  @restrict 必须在正式安全通道里进行.
 *
 *  @param uin 正式Uin
 *  @param loginTicket 登录票据
 */
- (void)makeRefreshTokenExpired:(UInt32)uin LoginTicket:(NSString *)loginTicket;

@end
