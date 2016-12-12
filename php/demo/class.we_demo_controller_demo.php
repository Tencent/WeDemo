
<?php if (!defined('WE_DEMO')) { die('Unauthorized Access!'); }

// Tencent is pleased to support the open source community by making WeDemo available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
// Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


/**
 * 授权登录控制器Demo
 * @version 2015-09-15
 */
class WeDemoControllerDemo
{
    protected $db;
    protected $sdk;
    protected $data;

    function __construct()
    {
        // 加载SDK
        if (file_exists(WX_SDK_PATH . 'class.wx_sdk_handler.php')) {
            require_once WX_SDK_PATH . 'class.wx_sdk_handler.php';
            require_once WX_SDK_PATH . 'class.wx_network.php';
            require_once WX_SDK_PATH . 'class.wx_open_api.php';
            require_once WX_SDK_PATH . 'interface.wx_database.php';
        } else {
            $this->show_server_error('WX SDK does not exist.');
        }

        // 数据存取
        require_once __DIR__ . '/class.we_demo_database_demo.php';
        $this->db = new WeDemoDatabaseDemo();
        if (!$this->db->is_available()) {
            $this->show_server_error('Database is not available.');
        }

        // 初始化SDK
        $opt = array(
            'app_id' => WE_DEMO_APP_ID,
            'app_secret' => WE_DEMO_APP_SECRET,
            'rsa_private_key' => WE_DEMO_RSA_PRIVATE_KEY,
            'salt' => WE_DEMO_SALT,
            'database' => $this->db,
            'delegate' => $this
        );
        $this->sdk = new WXSDKHandler($opt);
    }

    /**
     * 控制器入口，根据action路由到各个页面
     */
    public function main()
    {
        $action = 'action_' . urldecode($_GET['action']);
        if (!method_exists($this, $action)) {
            $this->show_server_error('Request action does not exist.');
        }
        call_user_func(array($this, $action));
    }


    /***************************************************************
     * Actions
     ***************************************************************/

    public function action_test()
    {
        echo "Hello World!";
        $this->wxlog('here');
    }

    /**
     * 建立登录前安全信道
     * 获取密钥psk，并生成temp_uin
     */
    public function action_connect()
    {
        $this->sdk->connect();
    }

    public function action_wxlogin()
    {
        $this->sdk->session_start();

        $resp = $this->sdk->wxlogin();

        // 登录成功后记录登录信息
        $uin = $resp['uin'];
        $api_data = $this->db->get_oauth_by_uin($uin);
        $openid = $api_data['openid'];
        $login_data = $this->db->get_record_by_openid($openid);
        if(!$login_data){
            $login_data['login_time'] = array($api_data['create_time']);
        }else{
            array_push($login_data['login_time'],$api_data['create_time']);
        }
        $this->db->set_record_by_openid($login_data, $openid);

        $this->sdk->session_end($resp);
    }

    public function action_checklogin()
    {
        $this->sdk->checklogin();
    }

    public function action_getuserinfo()
    {
        $this->wxlog("\n\t\t\tgetuserinfo");
        $sdk = $this->sdk;
        $sdk->session_start();
        $sdk->need_login();

        $req = $sdk->get_request_data();
        $resp = array();
        $uin = $req['uin'];

        $mail = $this->db->get_mail_by_uin($uin);
        if ($mail) {
            $this->wxlog('has app_user');
            $app_user = $this->db->get_user_by_mail($mail);
            $resp = array_merge($resp, $app_user);
        }

        $oauth = $this->db->get_oauth_by_uin($uin);
        if ($oauth) {
            $this->wxlog('has oauth');
            $wx_user = $sdk->request_api('/sns/userinfo', $oauth, array());
            $this->wxlog($wx_user);
            if (!$wx_user or isset($wx_user['errcode'])) {
                $this->wxlog('ERR: Got API with errcode: '.$wx_user['errcode']);
                $sdk->session_end(null, $wx_user['errcode'], 'Fail to get API');
            }

            $wx_user['access_token_expire_time'] = $oauth['create_time'] + $oauth['expires_in'];
            $wx_user['refresh_token_expire_time'] = $oauth['create_time'] + 60*60*24*30;

            $resp = array_merge($resp, $wx_user);
        }

        $record = $this->db->get_record_by_openid($resp['openid']);
        $login_time = $record['login_time'];
        $resp['access_log'] = array();
        for ($i = count($login_time) - 1; $i > -1; $i--) {
            $resp['access_log'][] = array(
                'login_time' => $login_time[$i]
            );
        }
        $this->wxlog($login_time);

        $this->wxlog($resp);
        $this->wxlog('getuserinfo OK');
        $sdk->session_end($resp);
    }

    public function action_commentlist()
    {
        $this->wxlog("\n\t\t\tcommentlist");
        $sdk = $this->sdk;
        $sdk->session_start();

        $req = $sdk->get_request_data();
        $start_id = $req['buffer']['start_id'] . '';
        $this->wxlog('start_id: ' . $start_id);

        $perpage = 20;
        $count = $this->db->get_comment_count();
        $list = $this->db->get_comment_list($start_id, $perpage);

        // 处理回复，并截取前3条
        foreach ($list as $key => $comment) {
            $comment['reply_list'] = array_values($comment['reply_list']);
            if ($comment['reply_count'] > 3) {
                $comment['reply_list'] = array_slice($comment['reply_list'], 0, 3);
            }
            $list[$key]['reply_list'] = $comment['reply_list'];
        }

        $resp = array(
            'perpage' => $perpage,
            'comment_count' => $count,
            'comment_list' => $list
        );

        $this->wxlog($resp);
        $this->wxlog('commentlist OK');
        $sdk->session_end($resp);
    }

    public function action_replylist()
    {
        $this->wxlog("\n\t\t\tcommentlist");
        $sdk = $this->sdk;
        $sdk->session_start();

        $req = $sdk->get_request_data();
        $comment_id = $req['buffer']['comment_id'];

        $comment = $this->db->get_comment($comment_id);
        if (!$comment) {
            $this->wxlog('no comment');
            $sdk->session_end(null, WX_ERR_NO_COMMENT, 'Cannot get comment by comment_id');
        }

        $resp = array(
            'reply_list' => array_values($comment['reply_list'])
        );

        $this->wxlog($resp);
        $this->wxlog('replylist OK');
        $sdk->session_end($resp);
    }

    public function action_addcomment()
    {
        $this->wxlog("\n\t\t\taddcomment");
        $sdk = $this->sdk;
        $sdk->session_start();
        $sdk->need_login();
        $sdk->need_oauth();

        $req = $sdk->get_request_data();
        $form = $req['buffer'];
        $resp = array();

        // 校验内容
        if (!$form['content']) {
            $this->wxlog('no content');
            $sdk->session_end(null, WX_ERR_INVALID_COMMENT_CONTENT, 'Empty comment content');
        }

        // 获取用户
        $wx_user = $this->db->get_wxuser_by_uin($req['uin']);
        if (!$wx_user) {
            $this->wxlog('no wx_user');
            $oauth = $this->db->get_oauth_by_uin($req['uin']);
            $wx_user = $sdk->request_api('/sns/userinfo', $oauth, array());
            if (!$wx_user or isset($wx_user['errcode'])) {
                $this->wxlog('ERR: Got API with errcode: '.$wx_user['errcode']);
                $sdk->session_end(null, $wx_user['errcode'], 'Fail to get API');
            }
            $this->db->set_wxuser_by_uin($wx_user, $req['uin']);
        }

        // 生成新留言
        $comment = array(
            'id' => uniqid(), // 随机生成字符串，因为业务量小，所以不考虑id冲突
            'content' => $form['content'],
            'date' => time(),
            'user' => $wx_user,
            'reply_count' => 0,
            'reply_list' => array()
        );
        $this->db->add_comment($comment);

        $resp['comment'] = $comment;

        $this->wxlog($resp);
        $this->wxlog('addcomment OK');
        $sdk->session_end($resp);
    }

    public function action_addreply()
    {
        $this->wxlog("\n\t\t\taddreply");
        $sdk = $this->sdk;
        $sdk->session_start();
        $sdk->need_login();
        $sdk->need_oauth();

        $req = $sdk->get_request_data();
        $form = $req['buffer'];
        $resp = array();
        $this->wxlog($form);

        // 校验内容
        if (!$form['content']) {
            $this->wxlog('no content');
            $sdk->session_end(null, WX_ERR_INVALID_REPLY_CONTENT, 'Empty reply content');
        }
        $form['reply_to_id'] = $form['reply_to_id'] . '';

        // 获取留言
        $comment = $this->db->get_comment($form['comment_id']);
        if (!$comment) {
            $this->wxlog('no comment');
            $sdk->session_end(null, WX_ERR_NO_COMMENT, 'Cannot get comment by comment_id');
        }

        // 获取用户
        $wx_user = $this->db->get_wxuser_by_uin($req['uin']);
        if (!$wx_user) {
            $this->wxlog('no wx_user');
            $oauth = $this->db->get_oauth_by_uin($req['uin']);
            $wx_user = $sdk->request_api('/sns/userinfo', $oauth, array());
            if (!$wx_user or isset($wx_user['errcode'])) {
                $this->wxlog('ERR: Got API with errcode: '.$wx_user['errcode']);
                $sdk->session_end(null, $wx_user['errcode'], 'Fail to get API');
            }
            $this->db->set_wxuser_by_uin($wx_user, $req['uin']);
        }

        // 找到被回复的人
        if ($form['reply_to_id']) {
            if (isset($comment['reply_list'][ $form['reply_to_id'] ])) {
                $form['content'] = '回复 ' . $comment['reply_list'][ $form['reply_to_id'] ]['user']['nickname'] . '：' . $form['content'];
            }
        }

        // 生成新回复
        $reply = array(
            'id' => uniqid(), // 随机生成字符串，因为业务量小，所以不考虑id冲突
            'content' => $form['content'],
            'date' => time(),
            'reply_to_id' => $form['reply_to_id'],
            'user' => $wx_user
        );
        $this->db->add_reply($reply, $comment['id']);

        $resp['reply'] = $reply;
        $resp['reply_count'] = $comment['reply_count'] + 1;
        $resp['reply_list'] = array_values($comment['reply_list']);
        $resp['reply_list'][] = $reply;

        $this->wxlog($resp);
        $this->wxlog('addreply OK');
        $sdk->session_end($resp);
    }

    /***************************************************************
     * Helpers
     ***************************************************************/

    // 加解密前遇到错误，直接500返回
    protected function show_server_error($msg)
    {
        header($_SERVER['SERVER_PROTOCOL'] . ' 500 Internal Server Error', true, 500);
        $msg = '<h1>500 Internal Server Error</h1>' . $msg;
        die($msg);
    }

    // 打log
    protected function wxlog($str) {
        if (!is_string($str)) {
            $str = json_encode($str);
        }
        $file = WE_DEMO_STORE_PATH.'/log.txt';
        if (file_exists($file)) {
            file_put_contents($file, '');
        }
        $fp = fopen($file, 'a');
        fwrite($fp, date('[m-d H:i:s]')." ".$str."\n");
        fclose($fp);
    }

} // END

/* END file */