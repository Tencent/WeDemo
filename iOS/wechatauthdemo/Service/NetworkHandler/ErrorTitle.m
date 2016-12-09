//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ErrorTitle.h"
#import "ADNetworkEngine.h"

@implementation NSString (ErrorTitle)

+ (NSString *)errorTitleFromResponse:(ADBaseResp *)resp
                        defaultError:(NSString *)defaultError {
    if (resp.errmsg)
        return resp.errmsg;
    
    NSString *errorTitle = defaultError;
    switch (resp.errcode) {
        case ADErrorCodeAlreadyBind:
            errorTitle = @"用户已经绑定";
            break;
        case ADErrorCodeUserExisted:
            errorTitle = @"账号已注册";
            break;
        case ADErrorCodeTokenExpired:
        case ADErrorCodeTicketExpired:
            errorTitle = @"太久没有登录了，为了安全起见，请重新登录";
            break;
        case ADErrorCodeTicketNotMatch:
            errorTitle = @"登录票据错误";
            break;
        case ADErrorCodeUserNotExisted:
            errorTitle = @"该账号未注册";
            break;
        case ADErrorCodePasswordNotMatch:
            errorTitle = @"密码不正确";
            break;
        case ADErrorCodeClientDescryptError:
            errorTitle = @"网络错误";
            break;
        default:
            break;
    }
    return errorTitle;
}

@end