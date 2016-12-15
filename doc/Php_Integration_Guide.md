<h1 align='center'> WeDemo后台（PHP）接入指南</h1>

##目录

* [1. 概要](#user-content-1-概要)
* [2. 获取源代码](#user-content-2-获取源代码)
* [3. 修改config.php文件](#user-content-3-修改configphp文件)
	* [3.1 打开config.php文件](#user-content-31-打开configphp文件)
	* [3.2 修改AppId和AppSecret](#user-content-32-修改appid和appsecret)
	* [3.3 修改SDK路径](#user-content-33-修改sdk路径)
	* [3.4 修改Database路径](#user-content-34-修改database路径)
	* [3.5 修改RSA密钥路径及文件名](#user-content-35-修改rsa密钥路径及文件名)
	* [3.6 修改加密登陆票据（token、密码等）的盐（salt）](#user-content-36-修改加密登陆票据token密码等的盐salt)
	* [3.7 修改票据相关时间和第三方业务相关错误码（可选）](#user-content-37-修改票据相关时间和第三方业务相关错误码可选)
* [4. 编写新的功能](#user-content-4-编写新的功能)
	* [4.1 编写新的action](#user-content-41-编写新的action)
	* [4.2 使用WeDemoControllerDemo类初始化时加载的SDK和Database](#user-content-42-使用wedemocontrollerdemo类初始化时加载的sdk和database)
	* [4.3 编写新的存储接口](#user-content-43-编写新的存储接口)

##1. 概要

WeDemo除了具有演示客户端，服务器如何安全的接入微信服务的作用，还提供了一套[安全的通信方式](https://github.com/Tencent/WeDemo/wiki/WeDemo-App交互时序说明文档)供开发者使用以快速搭建自己的App。本文为PHP端接入指南，客户端接入指南详见[WeDemo客户端接入指南](https://github.com/Tencent/WeDemo/wiki/WeDemo客户端接入指南)。

##2. 获取源代码

安装git后在终端上输入以下命令：

```bash
cd your/favourite/folder
git clone https://github.com/Tencent/WeDemo.git
```

##3. 修改config.php文件

[config.php](https://github.com/Tencent/WeDemo/blob/master/php/demo/config.php)是该服务端的配置文件，在这里，你可以配置如下信息：

* 应用的AppID和AppSecret，应与app客户端保持一致
* SDK路径
* Database路径
* RSA密钥路径及文件名
* 加密登陆票据（token、密码等）的盐（salt）
* 票据相关时间
* 第三方业务相关错误码

具体的配置步骤如下：

###3.1 打开config.php文件

在终端上输入以下命令来打开[config.php](https://github.com/Tencent/WeDemo/blob/master/php/demo/config.php)文件：

```bash
cd WeDemo/php/demo
vim config.php
```

###3.2 修改AppID和AppSecret

![步骤图：修改AppId和AppSecret](https://raw.githubusercontent.com/Tencent/WeDemo/master/doc/image/config_step1.png)

请先参照上图，再按以下步骤操作：

* 将第15行`define('WE_DEMO_APP_ID', 'XXXXXXXXXXXXXXXXXX');`的红色框内容（即`'XXXXXXXXXXXXXXXXXX'`）改为应用的AppID；
* 将第16行`define('WE_DEMO_APP_SECRET', 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');`的蓝色框内容（即`'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'`）改为应用的AppSecret。

**注意：**应用的`AppID`和`AppSecret`都可以在[https://open.weixin.qq.com](https://open.weixin.qq.com)中找到，应与app客户端保持一致。

###3.3 修改SDK路径

![步骤图：修改SDK路径](https://raw.githubusercontent.com/Tencent/WeDemo/master/doc/image/config_step2.png)

把demo clone下来后可直接使用默认的SDK路径，如需要改变SDK路径，可将第19行`define('WX_SDK_PATH', __DIR__ . '/../sdk/');`的`'/../sdk/'`修改为新的SDK路径。

###3.4 修改Database路径

![步骤图：修改Database路径](https://raw.githubusercontent.com/Tencent/WeDemo/master/doc/image/config_step3.png)

该demo使用文件存储的方式来作为Database，如果开发者想沿用这种方式，可按照以下步骤操作：

* 先确定数据文件存储目录名，下面步骤暂时用`YourDatabaseDir`来代替；
* 在终端上输入以下命令来创建数据文件存储目录：

```bash
mkdir YourDatabaseDir
```

* 在终端上输入以下命令来修改目录读写权限（修改为目录可写）：

```bash
chmod 744 YourDatabaseDir
```

* 如果开发者使用的文件夹名和该demo的默认文件夹名（即`_store`）**不同**，则将第23行`define('WE_DEMO_STORE_PATH', __DIR__ . '/_store/');`的`'/_store/'`修改为`'/YourDatabaseDir/'`。

**注意，为避免数据泄漏，请务必修改默认路径！**

###3.5 修改RSA密钥路径及文件名

**注意，我们这里强烈建议使用2048位以上的钥匙对，具体生成密钥指南详见**[WeDemo生成密钥与自签名证书指南](https://github.com/Tencent/WeDemo/wiki/WeDemo生成密钥与自签名证书指南)

![步骤图：修改RSA密钥路径及文件名](https://raw.githubusercontent.com/Tencent/WeDemo/master/doc/image/config_step4.png)

* 生成了私钥文件`rsa_private.key`和公钥文件`rsa_public.key`后将文件移动到开发者自定义的密钥目录（这里暂时使用`YourRSADir`来代替），目录的生成过程可参照[3.4 修改Database路径](#user-content-34-修改database路径)的终端代码；
* 开发者可以重命名私钥文件`rsa_private.key`，这里暂时使用`YourRSAPrivate.key`来代替；
* 修改第26行`define('WE_DEMO_RSA_PRIVATE_KEY', __DIR__ . '/_key/rsa_private.key');`的`'/_key/rsa_private.key'`修改为`'/YourRSADir/YourRSAPrivate.key'`。

###3.6 修改加密登陆票据（token、密码等）的盐（salt）

![步骤图：修改加密登陆票据（token、密码等）的盐（salt）](https://raw.githubusercontent.com/Tencent/WeDemo/master/doc/image/config_step5.png)

**为避免暴力破解，建议开发者不要使用默认值！**

可通过修改第30行`define('WE_DEMO_SALT', 'WeDemo');`的`'WeDemo'`修改为开发者自定义的盐。

###3.7 修改票据相关时间和第三方业务相关错误码（可选）

![步骤图：修改票据相关时间和第三方业务相关错误码（可选）](https://raw.githubusercontent.com/Tencent/WeDemo/master/doc/image/config_step6.png)

**该步骤为可选步骤，请开发者根据自己的实际情况进行修改。**

##4. 编写新的功能

开发者可以在WeDemo的基础上添加新的功能，完善服务端功能。

###4.1 编写新的action

参照[class.we_demo_controller_demo.php](https://github.com/Tencent/WeDemo/blob/master/php/demo/class.we_demo_controller_demo.php)actions模块的格式，来编写新的action，格式如下：

```php
public function action_yourAction()
{
	// Your code
}
```

**注意：**方法名必须有`action_`前缀，后面拼接的是新的action名（即上面代码中的`yourAction`）。

###4.2 使用WeDemoControllerDemo类初始化时加载的SDK和Database

可以在[class.we_demo_controller_demo.php](https://github.com/Tencent/WeDemo/blob/master/php/demo/class.we_demo_controller_demo.php)文件中看到以下代码：

```php
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
```

* `$this->sdk`：可通过`$this->sdk`来调用SDK中定义好的方法，具体方法可在[class.wx_sdk_handler.php](https://github.com/Tencent/WeDemo/blob/master/php/sdk/class.wx_sdk_handler.php)中查看；
* `$this->db`：可通过`$this->db`来调用开发者在[class.we_demo_database_demo.php](https://github.com/Tencent/WeDemo/blob/master/php/demo/class.we_demo_database_demo.php)中定义的方法。

###4.3 编写新的存储接口

参照[class.we_demo_database_demo.php](https://github.com/Tencent/WeDemo/blob/master/php/demo/class.we_demo_database_demo.php)第三方业务方法的格式，来编写新的存储接口，格式如下：

```php
public function yourDBFunc(args)
{
	// Your code
}
```

以下是几个在本存储模块中用到的数据操作方法：

* `is_available()`: 判断数据存储目录是否可写；
* `set_item($file, $key, $value)`：写入一个新值；
* `get_item($file, $key)`：读取一个指定的值；
* `delete_item($file, $key)`：删除一个指定的值；
* `set($file, $data)`：将值写入指定的文件，**一般不单独使用，在`set_item($file, $key, $value)`和`delete_item($file, $key)`中已调用该方法**；
* `get($file)`：读取指定文件的所有值，**一般不单独使用，在`set_item($file, $key, $value)`、`get_item($file, $key)`和`delete_item($file, $key)`中已调用该方法**。