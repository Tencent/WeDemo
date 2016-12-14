//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ADNetworkConfigManager.h"
#import "ADNetworkConfigItem.h"
#import "ConfigItemsMaker.h"
#import "ADKeyChainWrap.h"

const NSString *kConnectCGIName = @"appcgi_connect";
const NSString *kWXLoginCGIName = @"appcgi_wxlogin";
const NSString *kCheckLoginCGIName = @"appcgi_checklogin";
const NSString *kGetUserInfoCGIName = @"appcgi_getuserinfo";
const NSString *kMakeExpiredCGIName = @"testfunc";
const NSString *kGetCommentListCGIName = @"appcgi_commentlist";
const NSString *kGetReplyListCGIName = @"appcgi_replylist";
const NSString *kAddCommentCGIName = @"appcgi_addcomment";
const NSString *kAddReplyCGIName = @"appcgi_addreply";

static NSString* const kConfigureItemsKeyName = @"kConfigureItemsKeyName";

@interface ADNetworkConfigManager()

@property (nonatomic, strong) NSMutableDictionary *allConfig;

@end

@implementation ADNetworkConfigManager

#pragma mark - Life Cycle
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static ADNetworkConfigManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ADNetworkConfigManager alloc] initInPrivate];
    });
    return instance;
}

- (instancetype)initInPrivate {
    if (self = [super init]) {
        self.allConfig = [[NSMutableDictionary alloc] init];
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
- (void)setup {
    [self loadLocalConfig];
    NSArray *json = defaultConfigItems();
    if ([[self.allConfig allKeys] count] != [json count]) {
        // 在这里应该跟服务器检查一下版本号，若服务器版本号较大则重新加载配置,
        // 这里只有在Debug模式下才会将配置持久化，所以简单起见就直接比较数目
        [self.allConfig removeAllObjects];
        for (NSDictionary *dict in json) {
            ADNetworkConfigItem *item = [ADNetworkConfigItem modelObjectWithDictionary:dict];
            [self registerConfig:item
                      forKeyPath:item.cgiName];
        }
    }
}

- (void)registerConfig:(ADNetworkConfigItem *)item forKeyPath:(NSString *)keyPath {
    [self.allConfig setObject:item forKey:keyPath];
}

- (void)removeConfigForKeyPath:(NSString *)keyPath {
    [self.allConfig removeObjectForKey:keyPath];
}

- (ADNetworkConfigItem *)getConfigForKeyPath:(NSString *)keyPath {
    return [self.allConfig objectForKey:keyPath];
}

- (NSArray *)allConfigKeys {
    return [self.allConfig allKeys];
}

- (void)loadLocalConfig {
    NSData *data = [ADKeyChainWrap getDataForKey:kConfigureItemsKeyName];
    if (data != nil) {
        self.allConfig = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

- (void)save {
    [ADKeyChainWrap setData:[NSKeyedArchiver archivedDataWithRootObject:self.allConfig]
                     ForKey:kConfigureItemsKeyName];
}

#pragma mark - Lazy Initializers
- (NSMutableDictionary *)allConfig {
    if (_allConfig == nil) {
        _allConfig = [NSMutableDictionary dictionary];
    }
    return _allConfig;
}

@end