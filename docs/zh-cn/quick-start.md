# 如何开始使用 RESP.app

***

安装 RESP.app 后，您需要做的第一件事就是创建一个到 Redis 服务器的连接。在主窗口上，点击标记为 **"连接到 Redis 服务器"** 的按钮。

![](http://resp.app/static/docs/rdm_main.png?v=2)

## 连接到本地或公网 redis-server

在第一个选项卡（"连接设置"）中，输入您要创建的连接的一般信息。

* **名称** - 新连接的名称（例如：my_local_redis）
* **主机** - redis-server 主机（例如：localhost）
* **端口** - redis-server 端口（例如：6379）
* **密码** - redis-server 认证密码（如果有）([AUTH](http://redis.io/commands/AUTH))
* **用户名** - 仅适用于配置了 [ACL](https://redis.io/topics/acl) 的 redis-server 6.0 及以上版本，对于旧版本请留空

## 连接到带 SSL 的公网 redis-server

如果您想通过 SSL 连接到 redis-server 实例，需要在第二个选项卡中启用 SSL 并提供 PEM 格式的公钥。
以下是某些云服务的说明：

![](http://resp.app/static/docs/rdm_ssl.png?v=2)

### AWS ElastiCache

AWS ElastiCache 在您的 VPC 外部无法访问。为了远程连接到您的 ElastiCache，您需要使用以下选项之一：

* **设置 VPN 连接 [推荐]**
[https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/accessing-elasticache.html#access-from-outside-aws](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/accessing-elasticache.html#access-from-outside-aws)

* **设置 SSH 代理主机并通过 SSH 隧道连接。**[网络性能慢。不推荐]**
* **设置 NAT 实例以将您的 AWS ElastiCache 暴露到互联网。**[防火墙规则应非常谨慎配置。不推荐。]**

#### 如何通过 In-Transit 加密连接到 AWS ElastiCache

##### VPN / NAT
启用 SSL/TLS 复选框并使用 In-Transit 加密连接到您的 AWS ElastiCache。

##### SSH 隧道
在 SSH 连接设置中点击"通过 SSH 启用 TLS-over"复选框并使用 In-Transit 加密连接到您的 AWS ElastiCache。

### Microsoft Azure Redis Cache

![](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/media/index/redis-cache.svg)

1. 使用所有请求的信息创建连接。
![](http://resp.app/static/docs/rdm_ssl_azure.png?v=2)
2. 确保"使用 SSL 协议"复选框已启用。
3. 您的 Azure Redis 连接即可使用。

### Redis Labs

![](https://upload.wikimedia.org/wikipedia/commons/7/75/Redis_Labs_Logo.png)

要通过 SSL/TLS 加密连接到 Redis Labs 实例，请遵循以下步骤：

1. 确保您的 Redis 实例在 Redis Labs 仪表板中启用了 SSL。
2. 从 Redis Labs 仪表板下载并解压 `garantia_credentials.zip`。
3. 在"公钥"字段中选择 `garantia_user.crt`。
4. 在"私钥"字段中选择 `garantia_user_private.key`。
5. 在"颁发机构"字段中选择 `garantia_ca.pem`。

### DigitalOcean Managed Redis

![](https://upload.wikimedia.org/wikipedia/commons/f/ff/DigitalOcean_logo.svg)

DigitalOcean 连接设置有点令人困惑。要连接到 DigitalOcean Managed Redis，您需要遵循以下步骤：

1. 将连接信息复制到 RESP.app
2. **在 RESP.app 中将"用户名"字段留空！重要！**
3. 启用 SSL/TLS 复选框

或使用快速连接选项卡进行新连接：

1. 复制以"redis:"开头的连接字符串（来自连接详情）
2. 在 RESP.app 中点击"导入"并"测试连接"

### Heroku Redis

![](https://brand.heroku.com/static/media/heroku-logo-stroke.aa0b53be.svg)

1. 使用命令从终端获取 Redis 连接字符串：

```
heroku config -a YOUR-APP-NAME | grep REDIS
```

或从 Heroku 网站获取。

2. 在 RESP.app 连接对话框中输入连接设置：
- 如果 URL 以 `redis` 开头，启用 SSL/TLS 复选框并**取消勾选**"启用严格模式"复选框
- 复制 `user` 到"用户名"字段
- 复制 `password` 到"密码"字段
- 复制 `host` 和 `port` 到 RESP.app 中的"地址"字段

## 通过 SSH 隧道连接到私有 redis-server

### 基本 SSH 隧道

SSH 选项卡应该允许您使用 SSH 隧道。如果您的 redis-server 不能公开访问，这很有用。
要使用 SSH 隧道，选择"SSH 隧道"复选框。有不同的安全选项；您可以使用普通密码或 OpenSSH 私钥。

>!!! 注意为 Windows 用户：
您的私钥必须是 .pem 格式。

![](http://resp.app/static/docs/resp_ssh.png?v=1)

### SSH Agent

从版本 2022.3 开始，RESP.app 支持 SSH Agents。这允许使用像 [1Password](https://developer.1password.com/docs/ssh/agent) 这样的密码管理器来安全存储您的 SSH 密钥。

>!!! 注意为 Windows 用户：
在 Windows 上，RESP.app 仅支持 [Microsoft OpenSSH](https://docs.microsoft.com/en-us/windows-server/administration/openssh/overview)，这就是为什么"自定义 SSH Agent 路径"选项不可用。

##### 如何从 DMG 版本的 RESP.app 连接到 1Password SSH-Agent

由于 AppStore 沙盒化，RESP.app 无法访问默认或自定义 SSH Agents 定义的 `SSH_AUTH_SOCK` 变量。
为了克服这个限制，您需要在 RESP.app 沙盒容器内创建代理 unix socket：

```
mkdir -p ~/.1password && ln -s ~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
```

##### 如何从 AppStore 版本的 RESP.app 连接到 1Password SSH-Agent

由于 AppStore 沙盒化，RESP.app 无法访问由 `SSH_AUTH_SOCK` 变量定义的默认或自定义 SSH Agents。
为了克服这个限制，您需要在 RESP.app 沙盒容器内创建代理 unix socket：

```
mkdir -p ~/.1password && ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
```

2. 在 RESP.app 中勾选"使用 SSH Agent"复选框，并点击"选择文件"按钮打开"自定义 SSH Agent 路径"字段
3. 按 `⌘ + Shift + .` 在对话框中显示隐藏文件和文件夹
4. 选择文件 `~/.1password/agent.sock`
5. 保存连接设置

##### 高级 SSH 隧道

如果您需要高级 SSH 隧道设置，您应该手动设置 SSH 隧道并连接到本地主机：

```
ssh -L 7000:localhost:6379 SSH_USER@SSH_HOST -P SSH_PORT -i SSH_KEY -T -N
```

## 连接到 UNIX Socket

RESP.app [不支持直接连接到 UNIX socket](https://github.com/uglide/RedisDesktopManager/issues/1751)，但您可以使用 socat 等工具将 UNIX 域套接字重定向到 TCP：

```
socat UNIX-LISTEN:$HOME/tmp/redis.sock,reuseaddr,fork TCP:localhost:6379
```

## 高级连接设置

"高级设置"选项卡允许您自定义命名空间分隔器和其他高级设置。

![](http://resp.app/static/docs/rdm_advanced_settings.png?v=3)

## 下一步

现在您可以测试连接或立即创建连接。

恭喜，您已成功连接到您的 Redis 服务器。您应该看到类似于我们下面显示的内容。

![](http://resp.app/static/docs/rdm_main2.png?v=2)

通过右键单击连接，您可以展开键并从那里管理您的连接。通过右键单击，您还可以看到控制台菜单并从那里管理您的连接。