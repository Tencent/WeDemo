//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#ifndef AuthSDKDemo_Constant_h
#define AuthSDKDemo_Constant_h
#import <Foundation/Foundation.h>

static const int inset = 10;
static const int navigationBarHeight = 44;
static const int statusBarHeight = 20;
static const int normalHeight = 44;
static const float kLoginButtonCornerRadius = 4.0f;
static int64_t kRefreshTokenTimeNone = 2592000;
static int64_t kAccessTokenTimeNone = 0;
static NSString* const kChineseFont = @"STHeitiSC-Light";
static NSString* const kEnglishNumberFont = @"HelveticaNeue";
static NSString* const kCancleWordingText = @"知道了";

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#endif
