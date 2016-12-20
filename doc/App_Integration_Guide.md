<h1 align='center'>WeDemo客户端接入指南</h1>

##目录

*	[概要](#user-content-概要)
* 	[获取源代码](#user-content-获取源代码)
*  [修改客户端AppInfo](#user-content-修改客户端appinfo)
	*  [修改AppId和AppDescription](#user-content-修改appid和appdescription)
	*  [修改Bundle Id](#user-content-修改bundle-id)
*  [修改服务器信息](#user-content-修改服务器信息)
	*  [替换服务器地址](#user-content-替换服务器地址)
	*  [替换服务器RSA公钥和自签名SSL证书](#user-content-替换服务器rsa公钥和自签名ssl证书)
*	[编写新的功能](#user-content-编写新的功能)
	* [增加CGI配置](#user-content-增加cgi配置)
	* [编写你自己的Engine](#user-content-编写你自己的engine)

##概要
WeDemo除了具有演示客户端，服务器如何安全的接入微信服务的作用，还提供了一套[安全的通信方式](https://github.com/Tencent/WeDemo/wiki/WeDemo-App交互时序说明文档)供开发者使用以快速搭建自己的App。本文为客户端接入指南，PHP端接入指南详见[WeDemo后台（PHP）接入指南](https://github.com/Tencent/WeDemo/wiki/WeDemo后台（PHP）接入指南)。

##获取源代码
在Mac OS X上打开终端模拟器，输入以下命令：

```bash
cd your/favourite/folder
git clone https://github.com/Tencent/WeDemo
```

##修改客户端AppInfo

为了让客户端能成功拉起微信，发送你自己的App信息请求，并从微信中跳转回来，需要修改客户端提供AppId等信息。具体修改步骤如下：

###修改AppId和AppDescription

在终端模拟器中输入以下命令来打开工程所在目录:

```bash
cd WeDemo/iOS/WeDemo
open .
```

在弹出的Finder窗口中打开工程文件```WeDemo.xcworkspace```。在工程树中找到并修改**Info.plist**中的App信息,如下图所示：

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/WXAppInfo.jpg)

将图中的WXAppInfo中的AppId和AppDescription的值修改为你在[https://open.weixin.qq.com](https://open.weixin.qq.com)上注册的App信息，否则将无法在应用程序启动时向微信注册。

同时将图中的URL types中的URL identifier改为你的应用名，URL Schemes改为你的AppId，否则微信将无法跳转回你的应用。

###修改Bundle Id

在工程树设置文件中找到Bundle Indentifier的值修改为你在[https://open.weixin.qq.com](https://open.weixin.qq.com)上登记的Bundle Id，如下图所示：

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/BundleId.jpg)

##修改服务器信息

为了让你自己的服务器能成功接收到请求并做出响应，需要替换客户端中的服务器信息，具体步骤如下：

###替换服务器地址
找到[BaseNetworkEngine.m](https://github.com/Tencent/WeDemo/blob/master/iOS/WeDemo/Service/BaseNetworkEngine.m)文件，修改defaultHost的值为你自己的服务器地址，如下图所示：

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/defaultHost.jpg)

###替换服务器RSA公钥和自签名SSL证书

将服务器中用于与App通信的RSA公钥和SSL证书下载下来, 然后打开[BaseNetworkEngine.m](https://github.com/Tencent/WeDemo/blob/master/iOS/WeDemo/Service/BaseNetworkEngine.m)文件，将公钥内容复制替换掉，如下图所示：

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/RSAPublicKey.jpg)

**注意，我们这里强烈建议使用2048位以上的钥匙对，具体生成密钥指南详见[WeDemo生成RSA钥匙对与自签名证书指南](https://github.com/Tencent/WeDemo/wiki/WeDemo生成密钥与自签名证书指南)**。

接下来将原来的工程的Bundle Resource中的SSL证书替换成你自己的自签名证书，如下图所示：

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/serverCer.jpg)

##编写新的功能
你可以在WeDemo的基础上添加你自己的功能，完成你的App。

###增加CGI配置
按照[ConfigItemsMaker.h](https://github.com/Tencent/WeDemo/blob/master/iOS/WeDemo/Service/ConfigItemsMaker.h)的格式，增加你需要增加的CGI的配置信息，包括请求的路径，加解密算法等，参考示例如下(在[ConfigItemsMaker.h](https://github.com/Tencent/WeDemo/blob/master/iOS/WeDemo/Service/ConfigItemsMaker.h))：

```objective-c
@{
	@"cgi_name": @"appcgi_replylist", //这个配置的ID
	@"request_path": @"/wxoauth/demo/index.php?action=replylist", //请求路径
	@"http_method": @"POST",	//HTTP方法
	@"encrypt_algorithm": @"6", //加密算法
	@"decrypt_algorithm": @"6", //解密算法
	@"encrypt_key_path": @"req_buffer", //加密的结构
	@"decrypt_key_path": @"resp_buffer", //解密的结构
	@"sys_err_key_path": @"errcode" //错误码的Key
}
```

###编写你自己的Engine
之后只需要继承[BaseNetworkEngine](https://github.com/Tencent/WeDemo/blob/master/iOS/WeDemo/Service/BaseNetworkEngine.m)，然后用```JSONTaskForHost:Para:ConfigKeyPath:WithCompletion:```建立一个网络请求并发起即可，参考示例如下(在[ADNetworkEngine.m](https://github.com/Tencent/WeDemo/blob/master/iOS/WeDemo/Service/ADNetworkEngine.m)中):

```objective-c
- (void)getReplyListForUin:(UInt32)uin
                 OfComment:(NSString *)commentId
            WithCompletion:(GetReplyListCallBack)completion {
    [[self.manager JSONTaskForHost:self.host
                              Para:@{
                                     @"uin": @(uin),
                                     @"req_buffer": @{
                                             @"uin": @(uin),
                                             @"comment_id": commentId
                                             }
                                     }
                     ConfigKeyPath: @"appcgi_replylist"
                    WithCompletion:^(NSDictionary *dict, NSError *error) {
	                    //处理网络回调
                    }] resume];
}
```

###调试

WeDemo在Debug模式下还在首页提供了一个可以修改CGI配置的调试页面，同时还在App全局提供摇一摇手势呼出日志窗口，你还可以在他们上面集成其它调试工具如[FLEX](https://github.com/Flipboard/FLEX)等, enjoy! **:-)**。

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/Index.jpg)|![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/Debug.jpg)
-------|-------
![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/Log.jpg)|