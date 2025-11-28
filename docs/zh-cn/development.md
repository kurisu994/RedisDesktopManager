### 从源码构建 RESP.app

请参考 [安装指南](install.md#build-from-source) 获取完整的从源码构建说明。

### 生成测试数据

打开 RESP.app 控制台或 redis-cli 并执行：

```lua
eval "for index = 0,100000 do redis.call('SET', 'test_key' .. index, index) end" 0
eval "for index = 0,100000 do redis.call('SET', 'test_key:' .. math.random(1,100) .. ':' .. math.random(1,100), index) end" 0
eval "for index = 0,100000 do redis.call('HSET', 'test_large_hash', index, index) end" 0
eval "for index = 0,100000 do redis.call('ZADD', 'test_large_zset', index, index) end" 0
eval "for index = 0,100000 do redis.call('SADD', 'test_large_set', index) end" 0
eval "for index = 0,100000 do redis.call('LPUSH', 'test_large_list', index) end" 0
```

### 应用程序性能分析

```bash
sudo apt-get install valgrind
sudo add-apt-repository ppa:kubuntu-ppa/backports
sudo apt-get update
sudo apt-get install massif-visualizer

export LD_LIBRARY_PATH="/usr/share/redis-desktop-manager/lib":$LD_LIBRARY_PATH
valgrind --tool=massif --massif-out-file=rdm.massif /usr/share/redis-desktop-manager/bin/rdm

```

### 调试 SSL

```bash
openssl s_client -connect HOST:PORT -cert test_user.crt -key test.key -CAfile test_ca.pem
```

### 在 macOS 上移除应用设置

```bash
rm $HOME/Library/Preferences/com.redisdesktop.RedisDesktopManager.plist
killall -u `whoami` cfprefsd
```

### 修复错误或实现任何您想要的功能 :)