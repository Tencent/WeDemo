<h1 align=center>WeDemo App交互时序说明文档</center></h1>

##目录
*   [一、建立登录前安全信道](#user-content-一建立登录前安全信道)
*   [二、换取登录票据](#user-content-二换取登录票据)
	*   [利用微信SSO换取登录票据](#user-content-利用微信sso换取登录票据)
*   [三、使用登录票据登录并建立正式安全信道](#user-content-三使用登录票据登录并建立正式安全信道)
*   [四、获得用户信息](#user-content-四获得用户信息)
*   [五、App登录态/SK过期](#user-content-五app登录态sk过期)
*   [六、微信登录的Token过期](#user-content-六微信登录的token过期)
    *   [Access Token过期](#user-content-access-token过期)
    *   [Refresh Token过期](#user-content-refresh-token过期)
    
<h2 id="wow1">一、建立登录前安全信道</h2>

<b>当App尚未登录服务器前，App与Server之间会经过一次握手建立登录前安全信道，时序图如下所示：</b>

<!--title 建立登录前安全信道的时序

note left of AppClient:  1. AppClient本地随机\n生成32个字节的密钥psk
AppClient->AppServer: 2. ConnectRequest: RSA公钥加密(psk)
note right of AppServer: 3. AppServer用RSA私钥解密(psk),\n保存psk，生成temp_uin

AppServer->AppClient: 4. ConnectResponse: psk作为密钥的\nAES加密(temp_uin)

note left of AppClient: 5. AppClient用psk作为密钥的\nAES解密保存temp_uin
-->

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/connect.png)

<b>以下为详细说明:</b>

1. AppClient本地通过一些随机算法生成一个32bytes的密钥psk(*preSessionKey*)。

2. AppClient通过向服务器特定path发送HTTP请求包，内容为用HardCode在AppClient的RSA公钥加密的psk.

3. AppServer用RSA私钥解密包获得psk，生成一个临时的用户标示符temp_uin并建立```temp_uin<->psk```的映射。

4. AppServer用psk作为密钥，将```temp_uin```AES加密，在末尾加上HMac-SHA256的MAC后用Base64 Encoding后返回给AppClient。

5. AppClient对回包进行Base64 Decode之后，验证MAC一致后用psk作为密钥进行AES解密获得temp_uin保存到内存中.

<b>至此AppClient和AppServer之间的登录前安全信道建立完成，之后一直至[使用登录票据登录AppServer](#user-content-三使用登录票据登录并建立正式安全信道)之前，AppClient和AppServer都使用psk作为密钥加密报文，并把密文＋HMac-SHA256的MAC进行Base64Encode，并带上temp_uin一并发送出去。</b>

<h2 id="wow2">二、换取登录票据</h2>

<h3 id="wow3">利用微信SSO换取登录票据</h3>

<b>当用户点击“微信登录”按钮时，会触发利用微信SSO换取登录票据事件，此部分需在[登录前安全信道](#user-content-一建立登录前安全信道)中进行，时序图如下所示：</b>

<!--title 利用微信SSO换取登录票据

note left of AppClient: 1. 拉起微信客户端，\n经过微信授权获得code参数

AppClient->AppServer: 2. WXLoginRequest: AES加密(code)+temp_uin

note left of AppServer: 3. 根据temp_uin索引到psk\n解密code

AppServer->WXOpenServer: 4. GetToken:{AppID,\n Code, AppSecret}

WXOpenServer->AppServer: 5. ReturnToken: {access_token,\n refresh_token, openId...}

note left of AppServer: 6. 根据OpenId查询Uin和LoginTicket，\n若无则生成新的Uin和LoginTicket

AppServer->AppClient: 7. WXLoginResponse: AES加密(loginTicket, Uin)

note left of AppClient: 8. 用psk解密Uin，\nLoginTicket并保存。
-->

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/wxLogin.png)

<b>以下为详细说明: </b>

1. AppClient通过微信SDK拉起微信客户端，用户通过在微信客户端同意授权后，返回一个code给AppClient。

2. AppClient用psk对codeAES加密，在末尾加上HMac-SHA256的MAC后进行Base64 Encode，连带temp_uin（明文）一并发给AppServer。

3. AppServer通过明文获得temp_uin并索引到psk，验证MAC一致并解密后获得code参数。

4. AppServer用存在本地的AppID，AppSecret以及code参数发向微信OpenServer请求Token信息。<font color=red size=4><b>注意，这里AppSecret只能存在于AppServer中，不能让AppClient直接请求Token信息。</b></font>

5. 微信的OpenServer返回用户的OpenId，AccessToken及其有效期，RefreshToken及其有效期等信息。

6. AppServer根据OpenId查询Uin，若无则生成新的Uin和LoginTicket，并建立```OpenId<->Uin<->LoginTicket```的映射。

7. AppServer用psk对{LoginTicket, Uin}加密，在末尾加上HMac-SHA256的MAC后经过Base64 Encoding发送给AppClient。

8. AppClient收到并验证MAC一致后，解密Uin和LoginTicket并保存到本地。

<h2 id="wow4">三、使用登录票据登录并建立正式安全信道</h2>

<b>当AppClient获得正式Uin和LoginTicket时，会触发通过登录票据登录AppServer事件，此部分跟安全信道无关，时序图如下所示 ：</b>

<!--title 通过登录票据登录AppServer

note left of AppClient: 1. AppClient本地随机\n生成32个字节的密钥temp_key

AppClient->AppServer: 2. CheckLoginRequest: RSA公钥加密\n(temp_key, Uin, LoginTicket)

note right of AppServer: 3. RSA私钥解密temp_key,Uin,\n LoginTicket, 生成SK和expireTime

AppServer->AppClient: 4. CheckLoginResponse: temp_key\n作为密钥的AES加密(SK，expireTime)

note left of AppClient: 5. 用temp_key解密SK，\nexpireTime并保存。
-->

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/checkLogin.png)

<b>以下为详细说明:</b>

1. AppClient本地通过一些随机算法生成一个32bytes的密钥temp_key。

2. AppClient用HardCode在AppClient的RSA公钥加密的temp_key, Uin, LoginTicket发送给服务器.

3. AppServer通过RSA私钥解密获得temp_key, Uin, LoginTicket, 之后尝试匹配Uin和LoginTicket并且检查LoginTicket是否过期。如果票据是很久之前（例如三个月之前的）生成的，或者最近没有使用过（例如一周没使用过），那么票据就是过期的。若检查都成功则生成一个密钥SK(*SessionKey*)和对应的过期时间expireTime，并建立```Uin<->SK```的映射。

4. AppServer用temp_key对{SK, expireTime}进行AES加密，在末尾加上HMac-SHA256的MAC后经过Base64 Encoding发送给AppClient。

5. AppClient收到并验证MAC一致后，用temp_key作为密钥解密获得SK和expireTime并保存到内存。

<b>至此，AppClient和AppServer之间的正式安全信道建立完成，直至expireTime之前，AppClient和AppServer都使用SK作为密钥加密报文，并在密文末尾加上HMac-SHA256的MAC，用Base64Encoding后带上Uin（明文）一并发送出去。 </b>

<h2 id="wow5">四、获得用户信息</h2>

<b>当AppClient获得SK和expireTime时，会触发获得用户信息事件，此部分需在[正式安全信道](#user-content-三使用登录票据登录并建立正式安全信道)中进行，时序图如下所示 ：</b>

<!--title 获得用户信息

AppClient->AppServer: 1. GetUserInfoRequest:SK\n作为密钥的AES加密(Uin, LoginTicket)+Uin

note left of AppServer: 2. 解密获得Uin,LoginTicket,\n若Uin和LoginTicket匹配，\n则根据Uin查询用户信息


AppServer->WXOpenServer: 3. GetWXInfo: {OpenId, AccessToken}

WXOpenServer->AppServer: 4. ReturnWXInfo:{headimgurl,nickname...}

AppServer->AppClient: 5. GetUserInfoResponse: SK\n作为密钥的AES加密(App信息,微信信息)

note left of AppClient: 6. 解密用户信息\n并保存显示。
-->

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/getUserInfo.png)

<b>以下为详细说明:</b>

1. AppClient用SK对｛Uin，LoginTicket｝加密，将密文末尾加上HMac-SHA256的MAC后，进行Base64 Encoding与Uin(明文)一同发给AppServer。

2. AppServer通过明文获得Uin并索引到SK，若SK已过期，则触发[App登录态/SK过期](#user-content-五app登录态sk过期)子事件, 否则验证MAC一致并解密获得LoginTicket。之后查询Uin和LoginTicket是否匹配，若成功，则根据Uin查询获得用户OpenId等用户信息。

3. AppServer利用OpenId和AccessToken向WXOpenServer查询用户的微信信息。<font color=red size=4>注意，这里AccessToken和RefreshToken只能存在于AppServer中，不能让AppClient直接请求微信用户信息。</font>
	
4. 若AccessToken未过期，WXOpenServer返回对应的微信用户信息，包括微信昵称，头像Url等，若已过期，则触发[微信登录的Token过期](#user-content-六微信登录的token过期)子事件。

5. AppServer用SK对用户信息（包括昵称，头像，OpenId，AccessToken有效期，Refresh Token有效期）进行AES加密，在末尾加上HMac-SHA256的MAC后经过Base64Encoding发送给AppClient。

6. AppClient收到验证MAC一致后，用SK作为密钥解密获得用户信息并保存到内存中和展示在屏幕上。


<h2 id="wow6">五、App登录态/SK过期</h2>

<b>当AppServer在[获得用户信息](#user-content-四获得用户信息)子事件中发现SK过期时，会触发App登录态/SK过期事件。此部分只需要执行之前的子事件即可，是否为安全通道由具体子事件决定，时序图如下：</b>

<!--title App登录态/SK过期

AppClient->AppServer: 1. GetUserInfoRequest或\nwxBindAppRequest或\nappBindWXRequest

note right of AppServer: 2. 发现SK过期

AppServer->AppClient: 3. ErroCode = SK Expired

note left of AppClient: 4. 收到错误码，\n重新登录

AppClient->AppServer: 5. CheckLoginRequest

note right of AppServer: 6. 重新生成SK和有效期

AppServer->AppClient: 7. CheckLoginResponse

note left of AppClient: 8. 更新SK和有效期\n重发请求

AppClient->AppServer: 9. GetUserInfoRequest或\nwxBindAppRequest或\nappBindWXRequest
-->

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/SKExpired.png)

<b>以下为详细说明：</b>

1. AppClient发起GetUserInfoRequest或wxBindAppRequest或appBindWXRequest请求.

2. AppServer通过Uin索引到SK，并查找SK的有效期，发现SK已过期。

3. AppServer返回一个错误码标识SK已经过期。

4. AppClient收到错误码后重新执行[使用登录票据登录并建立正式安全信道](#user-content-三使用登录票据登录并建立正式安全信道)子事件.

5. AppClient重新发起GetUserInfoRequest或wxBindAppRequest或appBindWXRequest请求.


<h2 id="wow13">六、微信登录的Token过期</h2>

<b>当AppServer在[获得用户信息](#user-content-四获得用户信息)子事件中通过OpenId和AccessToken向WXOpenServer请求微信信息时，发现AccessToken过期，会触发微信登录的Token过期事件。此部分分为AccessToken过期和RefreshToken过期两种情况。以下为分别描述：</b>

<h3 id="wow14">Access Token过期</h3>

<b>若只是AccessToken，AppServer需要用RefreshToken去刷新AccessToken。这部分与安全信道无关，时序图如下：</b>

<!--title Access Token过期

note left of AppServer: 1. 发现AccessToken过期

AppServer->WXOpenServer: 2. {AppId, RefreshToken}

WXOpenServer->AppServer: 3. {New AccessToken ExpireTime}

note left of AppServer: 4. 再次请求微信信息
-->
![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/accessTokenExpired.png)

<b>以下为详细说明：</b>

1. AppServer在向WXOpenServer请求微信用户信息的过程中发现AccessToken过期.

2. AppServer向WXOpenServer发起刷新AccessToken请求，请求里带上AppId和RefreshToken。<font color=red size=4>注意，这里AccessToken和RefreshToken只能存在于AppServer中，不能让AppClient直接刷新AccessToken。</font>

3. WXOpenServer将新的AccessToken及其过期时间返回给AppServer。

4. AppServer刷新AccessToken，并更新有效期并再次请求用户的微信信息.

<h3 id="wow15">Refresh Token过期</h3>

<b>若AppServer在刷新AccessToken的过程中发现RefreshToken过期，则需要让AppClient重新进行微信授权以获得新的RefreshToken。此部分需在[正式安全信道](#user-content-三使用登录票据登录并建立正式安全信道)中进行，时序图为:</b>

<!--title Refresh Token过期

AppClient->AppServer: 1. 获得用户信息

note right of AppServer: 2. 发现RefreshToken过期

AppServer->AppClient:  3. ErrorCode = RefreshToken Expired

note over AppClient, AppServer: 4. 重新进行利用微信SSO\n换取登录票据子事件

note left of AppClient: 5. 重新登录AppServer\n并获取用户信息
-->

![](https://raw.githubusercontent.com/weixin-open/WeChatAuthDemo/master/doc/image/refreshTokenExpired.png)

<b>以下为详细说明：</b>

1. AppClient向AppServer请求用户信息。

2. AppServer向WXOpenServer请求微信用户信息的过程中发现RefreshToken过期。

3. AppServer给AppServer返回一个错误码标识Refresh Token过期了。

4. AppClient收到错误码后重新触发[利用微信SSO换取登录票据](#user-content-利用微信sso换取登录票据)子事件。

5. AppClient重新触发[使用登录票据登录并建立正式安全信道](#user-content-三使用登录票据登录并建立正式安全信道)子事件并重新[获取用户信息](#user-content-四获得用户信息)。