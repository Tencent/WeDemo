<?php if (!defined('WE_DEMO')) { die('Unauthorized Access!'); }

// Tencent is pleased to support the open source community by making WeDemo available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
// Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

/* !!! 请配置以下信息 !!! */

error_reporting(0);
date_default_timezone_set('Asia/Shanghai');

// 应用的AppID及AppSecret，可在open.weixin.qq.com中找到，应与app客户端一致
define('WE_DEMO_APP_ID', 'XXXXXXXXXXXXXXXXXX');
define('WE_DEMO_APP_SECRET', 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');

// SDK路径
define('WX_SDK_PATH', __DIR__ . '/../sdk/');

// 若使用demo自带的文件存储，请创建数据文件存储的目录，并保证目录可写
// 为避免数据泄露，请不要使用默认路径
define('WE_DEMO_STORE_PATH', __DIR__ . '/_store/');

// RSA密钥地址
define('WE_DEMO_RSA_PRIVATE_KEY', __DIR__ . '/_key/rsa_private.key');

// 加密登录票据(token、密码等)的盐
// 为避免暴力破解，请不要使用默认值
define('WE_DEMO_SALT', 'WeDemo');

// 票据相关时间，单位为秒
define('WX_LOGIN_TOKEN_EXPIRE_CREATE_TIME', 60*60*24*30);
define('WX_LOGIN_TOKEN_EXPIRE_LAST_LOGIN_TIME', 60*60*24*7);
define('WS_SESSION_KEY_EXPIRE_TIME', 60*60);

// 第三方业务相关的错误码，可根据实际业务情况来定义
define('WX_ERR_INVALID_COMMENT_CONTENT',			-40001);	//留言内容不合法
define('WX_ERR_INVALID_REPLY_CONTENT',				-40002);	//回复内容不合法
define('WX_ERR_NO_COMMENT',							-40003);	//留言不存在

/* !!! 请配置以上信息 !!! */

/* END file */