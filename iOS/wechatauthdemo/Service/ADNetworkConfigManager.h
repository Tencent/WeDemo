//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import <Foundation/Foundation.h>
@class ADNetworkConfigItem;

AUTH_DEMO_EXTERN const NSString *kConnectCGIName;
AUTH_DEMO_EXTERN const NSString *kWXLoginCGIName;
AUTH_DEMO_EXTERN const NSString *kCheckLoginCGIName;
AUTH_DEMO_EXTERN const NSString *kGetUserInfoCGIName;
AUTH_DEMO_EXTERN const NSString *kMakeExpiredCGIName;
AUTH_DEMO_EXTERN const NSString *kGetCommentListCGIName;
AUTH_DEMO_EXTERN const NSString *kGetReplyListCGIName;
AUTH_DEMO_EXTERN const NSString *kAddCommentCGIName;
AUTH_DEMO_EXTERN const NSString *kAddReplyCGIName;

@interface ADNetworkConfigManager : NSObject

/**
 *  严格单例，唯一获得实例的方法.
 *
 *  @abstract 所有的配置都只会存在内存里，这么做的主要目的是减小安全风险.
 *
 *  @return 实例对象.
 */
+ (instancetype)sharedManager;

/**
 *  注册默认的CGI配置属性.
 *
 *  @restrict 该方法需要在任何CGI发起之前调用.
 */
- (void)setup;

/**
 *  增加一个配置.
 *
 *  @param item    要增加的配置
 *  @param keyPath 该配置的ID
 */
- (void)registerConfig:(ADNetworkConfigItem *)item forKeyPath:(NSString *)keyPath;

/**
 *  删除一个配置.
 *
 *  @param keyPath 要删除的配置的ID
 */
- (void)removeConfigForKeyPath:(NSString *)keyPath;

/**
 *  根据ID获得配置.
 *
 *  @param keyPath 配置的ID
 *
 *  @return 跟配置ID对应的配置属性
 */
- (ADNetworkConfigItem *)getConfigForKeyPath:(NSString *)keyPath;

/**
 *  获得所有配置Key
 *
 *  @return 所有配置Key的数组
 */
- (NSArray *)allConfigKeys;


/**
 *  保存所有配置
 */
- (void)save;

@end
