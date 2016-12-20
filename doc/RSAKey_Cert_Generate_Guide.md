<h1 align='center'> WeDemo生成密钥与自签名证书指南</h1>

##目录

* [生成RSA密钥对](#user-content-生成rsa密钥对)
* [生成自签名证书](#user-content-生成自签名证书)
* [服务器配置](#user-content-服务器配置)
	* [Nginx](#user-content-nginx)

##生成RSA密钥对

在本例中，我们将生成一个 2048 位 RSA 密钥对。较短的密钥不足以抵御暴力猜测攻击，如 1024 位。 更长的密钥则有点过度，例如 4096 位。长远来看，随着计算机处理 成本变得更便宜，密钥长度会增加。目前 2048 是最佳长度。

用于生成 RSA 密钥对的命令为：

```bash
openssl genrsa -out rsa_private.key 2048
openssl rsa -in rsa_private.key -out rsa_public.key -pubout
```

这将在当前目录下生成私钥文件`rsa_private.key`和公钥文件`rsa_public.key`。

##生成自签名证书

这里我们提供了一个脚本供开发者生成自签名的证书，开发者可以根据自己的信息修改脚本，然后在服务器上运行即可。

```bash
#!/bin/sh

printf "[req]
default_bits            = 4096
default_md              = sha256
prompt                  = no
encrypt_key             = no
string_mask = utf8only

distinguished_name      = cert_distinguished_name
req_extensions          = req_x509v3_extensions

#将下面的信息替换成你的信息
[ cert_distinguished_name ]
C  = CN
ST = GD
L  = GZ 
O  = Tencent
OU = WXG
CN = wedemo.com

[req_x509v3_extensions]
basicConstraints = critical,CA:true
subjectKeyIdentifier    = hash
keyUsage = critical,digitalSignature,keyCertSign,cRLSign #,keyEncipherment
extendedKeyUsage  = critical,serverAuth #, clientAuth
subjectAltName=@alt_names

#将下面的信息替换成你的信息
[alt_names]
DNS.1 = *.wedemo.com
DNS.2 = *.api.wedemo.com
DNS.3 = wedemo.com

">ca_cert.conf

#将下面的信息替换成你的信息
key_file=wedemo.com.key
tmp_cert_file=tmp_wedemo.com.crt
csr_file=wedemo.com.csr
cert_file=wedemo.com.crt

#openssl genrsa  -out $key_file 2048
openssl ecparam  -out $key_file -name prime256v1 -genkey

openssl req -new -sha256 -x509 -days 7300  -config ca_cert.conf -extensions req_x509v3_extensions -key $key_file -out $cert_file

openssl x509 -in $cert_file  -serial -noout
openssl verify -verbose  -CAfile $cert_file $cert_file

exit
#keytool -printcert -v  -file $cert_file

openssl s_server    -cert  $cert_file -key $key_file -CAfile $cert_file -Verify 3 -accept 4430 -www  &
pid=$$
#将下面的信息替换成你的信息
echo 'GET /HTTP/1.1'|openssl s_client -connect www.wedemo.com:4430 -cert $cert_file -key $key_file -CAfile $cert_file
kill $$
```

##服务器配置
为了能让你的自签名证书能与服务器配合使用，我们也提供了脚本供开发者修改使用：

###Nginx

```bash
#
# HTTPS server configuration
#

server {
    listen       443;
    server_name  wedemo.com;

    ssl                  on;
    # certs sent to the client in SERVER HELLO are concatenated in ssl_certificate
    ssl_certificate /etc/nginx/conf.d/wedemo.com.crt;
    ssl_certificate_key /etc/nginx/conf.d/wedemo.com.key;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets on;

    # Diffie-Hellman parameter for DHE ciphersuites, recommended 2048 bits
    # generate you own using cmd:
    # "openssl dhparam -out /etc/nginx/conf.d/dhparam_2048.pem 2048"
    ssl_dhparam /etc/nginx/conf.d/dhparam_2048.pem;

    # modern configuration. tweak to your needs.
    # generate using tool https://mozilla.github.io/server-side-tls/ssl-config-generator/
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
    ssl_prefer_server_ciphers on;

    # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
    add_header Strict-Transport-Security max-age=15768000;


    location / {
        root   /usr/share/nginx/www/;
        index  index.html index.htm;
    }

    location ~ .*\.(php|php5)$
    {
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        include fcgi.conf;
        root /usr/share/nginx/www;
    }
}
```

