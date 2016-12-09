<?php

// Tencent is pleased to support the open source community by making WeDemo available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
// Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

/**
 * 微信开放平台API接口
 *
 * @author Weixin
 * @version 2015-11-01
 */
class WXOpenAPI
{
	protected $app_id;
	protected $app_secret;

	function __construct($app_id, $app_secret)
	{
		$this->app_id = $app_id;
		$this->app_secret = $app_secret;
	}

	public function get_wx_api($path, $query)
	{
		$url = 'https://api.weixin.qq.com/' . ltrim($path, '/') . '?' . http_build_query($query);
		$data = file_get_contents($url);
		if (!$data) {
			return null;
		}
		$data = json_decode($data, true);
		return $data;
	}

	public function request_access_token($code)
	{
		$json = $this->get_wx_api('sns/oauth2/access_token', array(
			'appid' => $this->app_id,
			'secret' => $this->app_secret,
			'code' => $code,
			'grant_type' => 'authorization_code'
		));
		return $json;
	}

	public function request_refresh_token($refresh_token)
	{
		$json = $this->get_wx_api('sns/oauth2/refresh_token', array(
			'appid' => $this->app_id,
			'grant_type' => 'refresh_token',
			'refresh_token' => $refresh_token
		));
		return $json;
	}

	public function request_userinfo($access_token, $openid)
	{
		$json = $this->get_wx_api('sns/userinfo', array(
			'access_token' => $access_token,
			'openid' => $openid
		));
		return $json;
	}

} // END

/* END file */