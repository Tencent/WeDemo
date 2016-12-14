//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ImageCache.h"
#import "MD5.h"

static  NSString *kCacheImageDirectory = @"com.wechat.authdemo.image";

@implementation UIImage (ImageCache)

+ (UIImage *)getCachedImageForUrl:(NSString *)urlString {
    if (!urlString)
        return nil;
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *imageCacheDir = [cachePath stringByAppendingPathComponent:kCacheImageDirectory];
    NSString *filePath = [imageCacheDir stringByAppendingPathComponent:[urlString MD5]];

    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return [UIImage imageWithData:data];
}

- (BOOL)cacheForUrl:(NSString *)urlString {
    if (!urlString)
        return NO;
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *imageCacheDir = [cachePath stringByAppendingPathComponent:kCacheImageDirectory];
    NSError *fileError = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:imageCacheDir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&fileError];
    if (fileError) {
        NSLog(@"File Error: %@", fileError);
        return NO;
    }
    NSString *filePath = [imageCacheDir stringByAppendingPathComponent:[urlString MD5]];
    NSData *data = UIImageJPEGRepresentation(self, 1.0f);
    return [data writeToFile:filePath atomically:YES];
}

@end
