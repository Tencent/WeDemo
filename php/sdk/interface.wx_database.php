<?php
// Tencent is pleased to support the open source community by making WeDemo available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
// Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

/**
 * 存储接口
 * 微信授权登录过程中，需要在服务器端存储一些数据，
 * 第三方开发者需实现此接口内的方法
 *
 * @author Weixin
 * @version 2015-11-01
 */
interface WXDatabase
{
	/**
	 * 判断uin是否存在
	 * @param int $uin 十位整数
	 * @return boolean
	 */
	public function uin_exists($uin);

	/**
	 * 根据uin处理psk(pre session key)
	 * @param string $psk
	 * @param int $uin
	 */
	public function set_psk_by_uin($psk, $uin);
	public function get_psk_by_uin($uin);
	public function delete_psk_by_uin($uin);

	/**
	 * 根据openid处理uin
	 * @param int $uin
	 * @param string $openid
	 */
	public function set_uin_by_openid($uin, $openid);
	public function get_uin_by_openid($openid);
	public function delete_uin_by_openid($openid);

	/**
	 * 根据uin处理login记录
	 * @param array $login_data {"uin":int,"login_ticket":string,"create_time":int,"last_login_time":int}
	 * @param int $uin
	 */
	public function set_login_by_uin($login_data, $uin);
	public function get_login_by_uin($uin);
	public function delete_login_by_uin($uin);

	/**
	 * 根据uin处理oauth记录
	 * @param array $data {"access_token":string,"expires_in":int,"refresh_token":string,"openid":string,"scope":string,"unionid":string}
	 * @param int $uin
	 */
	public function set_oauth_by_uin($data, $uin);
	public function get_oauth_by_uin($uin);
	public function delete_oauth_by_uin($uin);

	/**
	 * 根据uin处理session记录
	 * @param array $session {"session_key":string,"expire_time":int}
	 * @param int $uin
	 */
	public function set_session_by_uin($session, $uin);
	public function get_session_by_uin($uin);
	public function delete_session_by_uin($uin);

	/**
	 * 根据uin处理微信用户
	 * @param array $user {"openid":string,"nickname":string,"sex":int,"language":string,"city":string,"province":string,"country":string,"headimgurl":string,"privilege":array,"unionid":string}
	 * @param int $uin
	 */
	public function set_wxuser_by_uin($user, $uin);
	public function get_wxuser_by_uin($uin);

} // END

/* END file */