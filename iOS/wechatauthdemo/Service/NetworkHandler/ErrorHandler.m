//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ErrorHandler.h"
#import "ErrorTitle.h"
#import "AppDelegate.h"
#import "WXLoginViewController.h"
#import "ADNetworkEngine.h"
#import "ADUserInfo.h"
#import "ADCheckLoginResp.h"

static int const kHandleErrorMaxDepth = 3;

@implementation ErrorHandler

+ (void)handleNetworkExpiredError:(ADBaseResp *)resp
              WhileCatchErrorCode:(ErrorSignal)errorSignal {
    [self handleNetworkExpiredError:resp
                WhileCatchErrorCode:errorSignal
                            InDepth:0];
}

+ (void)handleNetworkExpiredError:(ADBaseResp *)resp
              WhileCatchErrorCode:(ErrorSignal)errorSignal
                          InDepth:(int)depth {
    if (depth <= kHandleErrorMaxDepth) {
        switch (resp.errcode) {
            case ADErrorCodeSessionKeyExpired: {    //会话过期，再次登录
                NSLog(@"Session Key Is Expired");
                [[ADNetworkEngine sharedEngine] checkLoginForUin:[ADUserInfo currentUser].uin
                                                     LoginTicket:[ADUserInfo currentUser].loginTicket
                                                  WithCompletion:^(ADCheckLoginResp *checkLoginResp) {
                                                      if (checkLoginResp && checkLoginResp.sessionKey) {
                                                          NSLog(@"Check Login Success");
                                                          [ADUserInfo currentUser].sessionExpireTime = checkLoginResp.expireTime;
                                                          [[ADUserInfo currentUser] save];
                                                          errorSignal != nil ? errorSignal(resp.errcode) : nil;
                                                      } else {
                                                          NSLog(@"Check Login Fail");
                                                          [self handleNetworkExpiredError:resp
                                                                      WhileCatchErrorCode:nil
                                                                                  InDepth:depth+1];
                                                      }
                                                  }];
                break;
            };
            default:
                errorSignal != nil ? errorSignal(resp.errcode) : nil;
                break;
        }
    }
}

@end