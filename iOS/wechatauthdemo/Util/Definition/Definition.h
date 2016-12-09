//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#ifndef AuthSDKDemo_Definition_h
#define AuthSDKDemo_Definition_h
#import "Constant.h"
#import "LogTextViewController.h"

typedef enum {
    ADSexTypeUnknown,
    ADSexTypeMale,
    ADSexTypeFemale
} ADSexType;

typedef enum {
    ADErrorCodeNoError = 0,
    ADErrorCodeUnknown = -1,
    ADErrorCodeClientDescryptError = -1001,
    ADErrorCodeCanNotAccessOpenServer = -10001,
    ADErrorCodeRequestError = -10002,
    ADErrorCodeTicketNotMatch = -20001,
    ADErrorCodeSessionKeyExpired = -20003,
    ADErrorCodeUserExisted = 20001,
    ADErrorCodeAlreadyBind = 20002,
    ADErrorCodeUserNotExisted = 20003,
    ADErrorCodePasswordNotMatch = 20004,
    ADErrorCodeTicketExpired = 30002,
    ADErrorCodeTokenExpired = 30003,
} ADErrorCode;

typedef enum {
    EncryptAlgorithmNone = 0,
    EncryptAlgorithmRSA = 1 << 0,     /* Rsa Encrypt With Public Key */
    EncryptAlgorithmAES = 1 << 1,    /* AES Encrypt With Session Key */
    EncryptAlgorithmBase64 = 1 << 2,  /* Base64 Encode/Decode */
} EncryptAlgorithm;

typedef enum {
    ADLoginTypeFromUnknown,
    ADLoginTypeFromApp,
    ADLoginTypeFromWX
}ADLoginType;

typedef void(^ButtonCallBack)(id sender);

//A better version of NSLog
#ifdef DEBUG
#define NSLog(format, ...) do {                                                 \
    fprintf(stderr, "<%s : %d> %s\n",                                           \
    [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
    __LINE__, __func__);                                                        \
    (NSLog)((format), ##__VA_ARGS__);                                           \
    fprintf(stderr, "-------\n");                                               \
    char logCharArray[1000] = {0};                                              \
    sprintf(logCharArray, "<%s : %d> %s\n",                                     \
    [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
    __LINE__, __func__);                                                        \
    NSMutableString *logString = [[NSMutableString alloc] initWithCString:logCharArray encoding:NSUTF8StringEncoding];                                                  \
    [logString appendFormat:format, ##__VA_ARGS__];                             \
    [logString appendFormat: @"\n-------\n"];                                   \
    dispatch_async(dispatch_get_main_queue(), ^{                                \
        [[LogTextViewController sharedLogTextView] insertLog:logString];        \
    });                                                                         \
} while (0)
#else
#define NSLog(format, ...)
#endif

//A better version of extern
#ifdef __cplusplus
#define AUTH_DEMO_EXTERN	extern "C" __attribute__((visibility ("default")))
#else
#define AUTH_DEMO_EXTERN	    extern __attribute__((visibility ("default")))
#endif

//Show Error
#define ADShowErrorAlert(wording)                               \
        [[[UIAlertView alloc] initWithTitle:nil                 \
                                    message:wording             \
                                   delegate:nil                 \
                          cancelButtonTitle:kCancleWordingText  \
                          otherButtonTitles:nil] show]

@class UIActivityIndicatorView;

static UIActivityIndicatorView *_indicatorView;
//Show ActivityIndicator
#define ADShowActivity(superView) do { \
    if (_indicatorView == nil) { \
            _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; \
        }\
    if (![_indicatorView isAnimating]){ \
            [superView addSubview:_indicatorView]; \
            _indicatorView.center = superView.center;\
            [_indicatorView startAnimating]; \
        }   \
    } while(0)
//Hide ActivityIndicator
#define ADHideActivity do { \
    if ([_indicatorView isAnimating]) { \
        [_indicatorView stopAnimating];\
    } \
} while (0)

#import "ADBaseResp.h"
#import "ADAccessLog.h"
#import "ButtonColor.h"
#import "ErrorTitle.h"
#import "ErrorHandler.h"

#endif
