//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import <sys/time.h>
#import <Security/SecRandom.h>
#import "RandomKey.h"
#import "MD5.h"

@implementation NSString (RandomKey)

+ (NSString *)randomKey {
    /* Get Random UUID */
    NSString *UUIDString;
    CFUUIDRef UUIDRef = CFUUIDCreate(NULL);
    CFStringRef UUIDStringRef = CFUUIDCreateString(NULL, UUIDRef);
    UUIDString = (NSString *)CFBridgingRelease(UUIDStringRef);
    CFRelease(UUIDRef);
    /* Get Time */
    double time = CFAbsoluteTimeGetCurrent();
    /* MD5 With Sale */
    return [[NSString stringWithFormat:@"%@%f", UUIDString, time] MD5];
}

@end

@implementation NSData (RandomData)

+ (NSData *)randomDataWithLength:(NSUInteger)length {
	NSMutableData* data = [NSMutableData dataWithLength:length];
	int err = SecRandomCopyBytes(kSecRandomDefault, length, [data mutableBytes]);
	if (err)
		return nil;
	else
		return data;
}

@end
