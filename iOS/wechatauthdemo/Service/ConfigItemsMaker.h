//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#ifndef ADNetworkConfigItems_h
#define ADNetworkConfigItems_h

#import <Foundation/Foundation.h>


NSArray *defaultConfigItems() {
    return @[
             @{
                 @"cgi_name": @"appcgi_connect",
                 @"request_path": @"/wxoauth/demo/index.php?action=connect",
                 @"http_method": @"POST",
                 @"encrypt_algorithm": @(5),
                 @"decrypt_algorithm": @(6),
                 @"encrypt_key_path": @"kEncryptWholePacketParaKey",
                 @"decrypt_key_path": @"resp_buffer",
                 @"sys_err_key_path": @"errcode"
                 },
             @{
                 @"cgi_name": @"appcgi_wxlogin",
                 @"request_path": @"/wxoauth/demo/index.php?action=wxlogin",
                 @"http_method": @"POST",
                 @"encrypt_algorithm": @(6),
                 @"decrypt_algorithm": @(6),
                 @"encrypt_key_path": @"req_buffer",
                 @"decrypt_key_path": @"resp_buffer",
                 @"sys_err_key_path": @"errcode"
                 },
             @{
                 @"cgi_name": @"appcgi_checklogin",
                 @"request_path": @"/wxoauth/demo/index.php?action=checklogin",
                 @"http_method": @"POST",
                 @"encrypt_algorithm": @"5",
                 @"decrypt_algorithm": @"6",
                 @"encrypt_key_path": @"kEncryptWholePacketParaKey",
                 @"decrypt_key_path": @"resp_buffer",
                 @"sys_err_key_path": @"errcode"
                 },
             @{
                 @"cgi_name": @"appcgi_getuserinfo",
                 @"request_path": @"/wxoauth/demo/index.php?action=getuserinfo",
                 @"http_method": @"POST",
                 @"encrypt_algorithm": @"6",
                 @"decrypt_algorithm": @"6",
                 @"encrypt_key_path": @"req_buffer",
                 @"decrypt_key_path": @"resp_buffer",
                 @"sys_err_key_path": @"errcode"
                 },
             @{
                 @"cgi_name": @"appcgi_testfunc",
                 @"request_path": @"/wxoauth/demo/index.php?action=testfunc",
                 @"http_method": @"POST",
                 @"encrypt_algorithm": @"6",
                 @"decrypt_algorithm": @"6",
                 @"encrypt_key_path": @"req_buffer",
                 @"decrypt_key_path": @"resp_buffer",
                 @"sys_err_key_path": @"errcode"
                 },
             @{
                 @"cgi_name": @"appcgi_addcomment",
                 @"request_path": @"/wxoauth/demo/index.php?action=addcomment",
                 @"http_method": @"POST",
                 @"encrypt_algorithm": @"6",
                 @"decrypt_algorithm": @"6",
                 @"encrypt_key_path": @"req_buffer",
                 @"decrypt_key_path": @"resp_buffer",
                 @"sys_err_key_path": @"errcode"
                 },
             @{
                 @"cgi_name": @"appcgi_commentlist",
                 @"request_path": @"/wxoauth/demo/index.php?action=commentlist",
                 @"http_method": @"POST",
                 @"encrypt_algorithm": @"6",
                 @"decrypt_algorithm": @"6",
                 @"encrypt_key_path": @"req_buffer",
                 @"decrypt_key_path": @"resp_buffer",
                 @"sys_err_key_path": @"errcode"
                 },
             @{
                 @"cgi_name": @"appcgi_addreply",
                 @"request_path": @"/wxoauth/demo/index.php?action=addreply",
                 @"http_method": @"POST",
                 @"encrypt_algorithm": @"6",
                 @"decrypt_algorithm": @"6",
                 @"encrypt_key_path": @"req_buffer",
                 @"decrypt_key_path": @"resp_buffer",
                 @"sys_err_key_path": @"errcode"
                 },
             @{
                 @"cgi_name": @"appcgi_replylist",
                 @"request_path": @"/wxoauth/demo/index.php?action=replylist",
                 @"http_method": @"POST",
                 @"encrypt_algorithm": @"6",
                 @"decrypt_algorithm": @"6",
                 @"encrypt_key_path": @"req_buffer",
                 @"decrypt_key_path": @"resp_buffer",
                 @"sys_err_key_path": @"errcode"
                 }];
}

#endif /* ADNetworkConfigItems_h */
