<?php
// Tencent is pleased to support the open source community by making WeDemo available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
// Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

/**
 * Weixin Auth SDK Handler for App Server-side
 *
 * @author Weixin
 * @version 2015-09-21
 */
class WXSDKHandler
{
	public $network;
	public $api;
	public $db;

	public $session_data = array();
	public $request_data = array();
	public $session_key = '';

	protected $opt = array();
	protected $delegate = null;

	function __construct($opt)
	{
		$this->opt = $opt;
		$this->db = $opt['database'];
		$this->delegate = $opt['delegate'];

		$this->network = new WXNetwork();
		$this->api = new WXOpenAPI($opt['app_id'], $opt['app_secret']);

		if (!defined('WX_ERR_SYS')) {
			define('WX_ERR_SYS',						-1);		//未知错误
			define('WX_ERR_CANNOT_ACCESS_OPENSERVER',	-10001);	//无法访问微信API
			define('WX_ERR_FAIL_TO_READ_REQUEST',		-10002);	//无法读取App的请求
			define('WX_ERR_LOGINTICKET_UIN_MISMATCHED',	-20001);	//uin->loginTicket不匹配
			define('WX_ERR_LOGINTICKET_EXPIRED',		-20002);	//loginTicket过期
			define('WX_ERR_SESSIONKEY_EXPIRED',			-20003);	//sessionKey过期
			define('WX_ERR_NO_OAUTH_INFO',				-30001);	//找不到授权信息
		}
	}



	/****************************************************************
	 ***
	 *** 微信授权登录逻辑，直接调用接口即可完成整个授权流程
	 ***
	 ***************************************************************/


	/**
	 * 建立登录前安全信道
	 * 获取密钥psk，并生成temp_uin
	 */
	public function connect()
	{
		$psk_encode = $this->network->get_request(false);

		if (!$psk_encode) {
			$this->network->response_error(-1);
		}

		$psk = $this->network->RSA_decode($psk_encode, $this->opt['rsa_private_key'], 'json');
		if (!$psk or !$psk['psk']) {
			$this->network->response_error(-1);
		}
		$psk = $psk['psk'];

		do {
			$tmp_uin = $this->generate_uin();
		} while ($this->db->uin_exists($tmp_uin) == true);
		$this->db->set_psk_by_uin($psk, $tmp_uin);

		$resp = array(
			'tmp_uin' => $tmp_uin
		);
		$this->network->response($psk, $resp);
	}

	/**
	 * 微信授权登录
	 */
	public function wxlogin()
	{
		$code = $this->request_data['buffer']['code'];

		$api_data = $this->api->request_access_token($code);
		if (!$api_data) {
			$this->session_end(null, WX_ERR_CANNOT_ACCESS_OPENSERVER, 'Cannot access to WxOpenServer');
		} else if (isset($api_data['errcode'])) {
			$this->session_end(null, $api_data['errcode'], 'Fail to get access_token with errcode: '.$api_data['errcode']);
		}
		$api_data['create_time'] = time();

		$uin = $this->request_data['uin'];
		$this->db->set_oauth_by_uin($api_data, $uin);

		$login_ticket = $this->do_login($uin);

		$resp = array(
			'uin' => $uin,
			'login_ticket' => $login_ticket
		);
		return $resp;
	}

	public function checklogin()
	{
		$req = $this->network->get_request(false);
		if (!$req) {
			$this->network->response_error(WX_ERR_FAIL_TO_READ_REQUEST);
		}

		$req_data = $this->network->RSA_decode($req, $this->opt['rsa_private_key'], 'json');
		if (!$req_data) {
			$this->network->response_error(WX_ERR_FAIL_TO_READ_REQUEST);
		}
		$uin = $req_data['uin'];
		$tmp_key = $req_data['tmp_key'];
		$login_ticket = $this->encode_token($req_data['login_ticket'], $this->opt['salt']);

		$login_data = $this->db->get_login_by_uin($uin);
		if (!$login_data) {
			$this->network->response($tmp_key, null, WX_ERR_LOGINTICKET_UIN_MISMATCHED, 'Fail to get login_ticket by uin');
		}
		if ($login_data['login_ticket'] != $login_ticket) {
			$this->network->response($tmp_key, null, WX_ERR_LOGINTICKET_UIN_MISMATCHED, 'Mismatch of login_ticket and uin');
		}

		if ($login_data['create_time'] < time() - WX_LOGIN_TOKEN_EXPIRE_CREATE_TIME) {
			$this->db->delete_login_by_uin($uin);
			$this->network->response($tmp_key, null, WX_ERR_LOGINTICKET_EXPIRED, 'Expired login_ticket');
		}
		if ($login_data['last_login_time'] > 0 and $login_data['last_login_time'] < time() - WX_LOGIN_TOKEN_EXPIRE_LAST_LOGIN_TIME) {
			$this->db->delete_login_by_uin($uin);
			$this->network->response($tmp_key, null, WX_ERR_LOGINTICKET_EXPIRED, 'Expired login_ticket');
		}
		$login_data['last_login_time'] = time();
		$this->db->set_login_by_uin($login_data, $uin);

		$session_key = $this->generate_session_key();
		$expire_time = time() + WX_AUTH_SESSION_KEY_EXPIRE_TIME;
		$this->db->set_session_by_uin(array(
			'session_key' => $session_key,
			'expire_time' => $expire_time
		), $uin);

		$resp = array(
			'session_key' => $session_key,
			'expire_time' => $expire_time
		);
		$this->network->response($tmp_key, $resp);
	}



	/****************************************************************
	 ***
	 *** 会话相关方法，用于辅助处理第三方业务逻辑
	 ***
	 ***************************************************************/


	public function session_start()
	{
		$req = $this->network->get_request(true);
		if (!$req) {
			$this->network->response_error(WX_ERR_FAIL_TO_READ_REQUEST);
		}

		// 获取uin，这个uin可能是正式uin也可能是tmp_uin
		$uin = $req['uin'];
		$this->session_data['uin'] = $uin;

		// 尝试获取session_key
		$session = $this->db->get_session_by_uin($uin);
		if ($session) {
			// 使用正式session_key
			if ($session['expire_time'] < time()) {
				$this->db->delete_session_by_uin($uin);
				$this->network->response($session['session_key'], null, WX_ERR_SESSIONKEY_EXPIRED, 'Expired session_key');
			}
			$aes_key = $session['session_key'];
			$this->session_data['session'] = $session;
		} else {
			// 使用临时pre_session_key
			$psk = $this->db->get_psk_by_uin($uin);
			$aes_key = $psk;
			$this->session_data['psk'] = $psk;
		}
		if (!$aes_key) {
			$this->network->response_error(WX_ERR_FAIL_TO_READ_REQUEST);
		}
		$this->session_key = $aes_key;

		// 解包
		$buffer = $this->network->AES_decode($req['req_buffer'], $aes_key, 'json');
		if (!$buffer) {
			$this->network->response($aes_key, null, WX_ERR_FAIL_TO_READ_REQUEST, 'Fail to decode req_buffer');
		}
		$this->request_data = array(
			'uin' => $uin,
			'buffer' => $buffer
		);
	}

	public function session_end($resp, $errcode = 0, $errmsg = '')
	{
		$this->network->response($this->session_key, $resp, $errcode, $errmsg);
	}

	public function need_login()
	{
		$uin = $this->request_data['uin'];
		$login_ticket = $this->encode_token($this->request_data['buffer']['login_ticket'], $this->opt['salt']);
		$login_data = $this->db->get_login_by_uin($uin);
		if (!$login_data) {
			$this->session_end(null, WX_ERR_LOGINTICKET_UIN_MISMATCHED, 'Mismatch of login_ticket and uin');
		}
		if ($login_data['login_ticket'] != $login_ticket) {
			$this->session_end(null, WX_ERR_LOGINTICKET_UIN_MISMATCHED, 'Mismatch of login_ticket and uin');
		}
		$this->session_data['login'] = $login_data;
	}

	public function need_oauth()
	{
		$uin = $this->request_data['uin'];
		$oauth = $this->db->get_oauth_by_uin($uin);
		if (!$oauth) {
			$this->session_end(null, WX_ERR_NO_OAUTH_INFO, 'Missing OAuth info');
		}
		$this->session_data['oauth'] = $oauth;
	}

	public function request_api($api_path, &$oauth = array(), $query = array())
	{
		$query['access_token'] = $oauth['access_token'];
		$query['openid'] = $oauth['openid'];
		$data = $this->api->get_wx_api($api_path, $query);
		if (!$data) {
			return null;
		}
		if (isset($data['errcode']) and $data['errcode'] == 42001) {
			$result = $this->api->request_refresh_token($oauth['refresh_token']);
			if (!$result) {
				return $data;
			}
			if (isset($result['errcode'])) {
				return $result;
			}

			$uin = $this->request_data['uin'];
			$oauth = array_merge($oauth, $result);
			$oauth['create_time'] = time();
			$this->db->set_oauth_by_uin($oauth, $uin);

			$query['access_token'] = $oauth['access_token'];
			$data = $this->api->get_wx_api($api_path, $query);
		}
		return $data;
	}

	public function get_request_data()
	{
		return $this->request_data;
	}

	public function do_login($uin)
	{
		$login_ticket = $this->generate_login_ticket();
		$login_data = array(
			'uin' => $uin,
			'login_ticket' => $this->encode_token($login_ticket, $this->opt['salt']),
			'create_time' => time(),
			'last_login_time' => 0
		);
		$this->db->set_login_by_uin($login_data, $uin);
		return $login_ticket;
	}




	/****************************************************************
	 ***
	 *** 辅助函数
	 ***
	 ***************************************************************/

	// 生成10位长度uin
	public function generate_uin()
	{
		$uin = mt_rand(1, 3) . '';
		for ($i=0; $i<9; $i++) {
			$uin .= mt_rand(0, 9);
		}
		return intval($uin);
	}

	public function generate_login_ticket()
	{
		return substr( md5(uniqid()), 0, 10 );
	}

	public function encode_token($token, $salt)
	{
		return md5( md5($token) . $salt );
	}

	protected function generate_session_key()
	{
		return substr( md5(uniqid()), 0, 32 );
	}

} // END

/* END file */