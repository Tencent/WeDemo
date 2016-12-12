<?php if (!defined('WE_DEMO')) { die('Unauthorized Access!'); }

// Tencent is pleased to support the open source community by making WeDemo available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
// Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


/**
 * 微信授权登录demo的数据存储模块
 * 该demo使用文件存储方式，存储路径请到config.php中配置
 *
 * 此模块仅作存储demo示例，
 * 包含一些预设的假数据以便于模拟用户帐号系统，
 * 正式环境中请编写自己的数据存储库（如mysql数据库），
 * 并接入自己的用户帐号系统
 */

/**
 * @version 2015-09-15
 */
class WeDemoDatabaseDemo implements WXDatabase
{

	function __construct()
	{

	}


	/****************************************************************
	 * 实现 WXDatabase 接口
	 * 下面这些方法是微信授权登录要用到的存储接口
	 ****************************************************************/

	public function uin_exists($uin)
	{
		if ($this->get_psk_by_uin($uin)) {
			return true;
		}
		return false;
	}

	public function set_psk_by_uin($psk, $uin)
	{
		$this->set_item('uin_psk_map', 'uin_'.$uin, $psk);
	}
	public function get_psk_by_uin($uin)
	{
		return $this->get_item('uin_psk_map', 'uin_'.$uin);
	}
	public function delete_psk_by_uin($uin)
	{
		return $this->delete_item('uin_psk_map', 'uin_'.$uin);
	}

	public function set_uin_by_openid($uin, $openid)
	{
		$this->set_item('openid_uin_map', $openid, $uin);
	}
	public function get_uin_by_openid($openid)
	{
		return (int)$this->get_item('openid_uin_map', $openid);
	}
	public function delete_uin_by_openid($openid)
	{
		return $this->delete_item('openid_uin_map', $openid);
	}

	public function set_login_by_uin($login_data, $uin)
	{
		$this->set_item('uin_login_map', 'uin_'.$uin, $login_data);
	}
	public function get_login_by_uin($uin)
	{
		return $this->get_item('uin_login_map', 'uin_'.$uin);
	}
	public function delete_login_by_uin($uin)
	{
		return $this->delete_item('uin_login_map', 'uin_'.$uin);
	}

	public function set_oauth_by_uin($data, $uin)
	{
		$this->set_item('uin_oauth_map', 'uin_'.$uin, $data);
	}
	public function get_oauth_by_uin($uin)
	{
		return $this->get_item('uin_oauth_map', 'uin_'.$uin);
	}
	public function delete_oauth_by_uin($uin)
	{
		return $this->delete_item('uin_oauth_map', 'uin_'.$uin);
	}

	public function set_session_by_uin($session, $uin)
	{
		$this->set_item('uin_sessionkey_map', 'uin_'.$uin, $session);
	}
	public function get_session_by_uin($uin)
	{
		return $this->get_item('uin_sessionkey_map', 'uin_'.$uin);
	}
	public function delete_session_by_uin($uin)
	{
		return $this->delete_item('uin_sessionkey_map', 'uin_'.$uin);
	}


	public function set_wxuser_by_uin($user, $uin)
	{
		$this->set_item('uin_wxuser_map', 'uin_'.$uin, $user);
	}
	public function get_wxuser_by_uin($uin)
	{
		return $this->get_item('uin_wxuser_map', 'uin_'.$uin);
	}




	/****************************************************************
	 * 第三方业务方法
	 * 下面这些方法是demo app用到的存储接口
	 ****************************************************************/

	public function get_comment_list($start_id = '', $limit = 10)
	{
		$comment_list = $this->get('comment_list');
		if (!$comment_list) {
			return array();
		}
		$list = array();
		$start = false;

		// 删除三天前的评论
		foreach ($comment_list as $comment_id => $comment) {
			if (time() - $comment['date'] > 259200) { // 259200 = 60 * 60 * 24 * 3，即三天的秒数
				unset($comment_list[$comment_id]);
			}
		}
		$this->set('comment_list', $comment_list);

		if ($start_id == '') {
			$start = true;
		}
		foreach ($comment_list as $comment_id => $comment) {
			if ($comment['id'] == $start_id) { // 找到开始id
				$start = true;
				continue;
			}
			if ($start == true) {
				$list[] = $comment;
				if (count($list) >= $limit) {
					break;
				}
			}
		}
		return $list;
	}
	public function get_comment_count()
	{
		$list = $this->get('comment_list');
		if (!$list) {
			return 0;
		}
		return count($list);
	}
	public function add_comment($comment)
	{
		$list = $this->get('comment_list');
		if (!$list) {
			$list = array();
		}
		$list = array_merge(array($comment['id']=>$comment), $list);
		$this->set('comment_list', $list);
		return true;
	}
	public function get_comment($comment_id)
	{
		return $this->get_item('comment_list', $comment_id);
	}
	public function delete_comment($comment_id)
	{
		return $this->delete_item('comment_list', $comment_id);
	}
	public function add_reply($reply, $comment_id)
	{
		$comment = $this->get_comment($comment_id);
		$comment['reply_list'][ $reply['id'] ] = $reply;
		$comment['reply_count'] = count($comment['reply_list']);
		$this->set_item('comment_list', $comment['id'], $comment);
		return true;
	}

	public function set_record_by_openid($record_data, $openid)
	{
		$this->set_item('openid_record_map', 'openid_'.$openid, $record_data);
	}
	public function get_record_by_openid($openid)
	{
		return $this->get_item('openid_record_map', 'openid_'.$openid);
	}
	public function delete_record_by_openid($openid)
	{
		return $this->delete_item('openid_record_map', 'openid_'.$openid);
	}

	public function set_mail_by_uin($mail, $uin)
	{
		$this->set_item('uin_mail_map', 'uin_'.$uin, $mail);
	}
	public function get_mail_by_uin($uin)
	{
		return $this->get_item('uin_mail_map', 'uin_'.$uin);
	}

	public function set_user_by_mail($user, $mail)
	{
		$this->set_item('mail_user_map', $mail, $user);
	}
	public function get_user_by_mail($mail)
	{
		return $this->get_item('mail_user_map', $mail);
	}





	/****************************************************************
	 * 本存储模块用到的数据操作方法
	 ****************************************************************/

	public function is_available()
	{
		return is_writable(WE_DEMO_STORE_PATH);
	}

	public function set_item($file, $key, $value)
	{
		$data = $this->get($file);
		if (!$data) {
			$data = array();
		}
		$data[$key] = $value;
		$this->set($file, $data);
	}

	public function get_item($file, $key)
	{
		$data = $this->get($file);
		if ($data === null) {
			return null;
		}
		if (!isset($data[$key])) {
			return null;
		}
		return $data[$key];
	}

	public function delete_item($file, $key)
	{
		$data = $this->get($file);
		if ($data and isset($data[$key])) {
			unset($data[$key]);
			$this->set($file, $data);
			return true;
		}
		return false;
	}

	public function set($file, $data)
	{
		$data = json_encode($data);
		file_put_contents(WE_DEMO_STORE_PATH . $file . '.json', $data);
		return true;
	}

	public function get($file)
	{
		$data = file_get_contents(WE_DEMO_STORE_PATH . $file . '.json');
		if ($data) {
			$data = json_decode($data, true);
			return $data;
		}
		return null;
	}

} // END

/* END file */