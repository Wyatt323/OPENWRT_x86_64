## 基于LEAN源码编译！
## 此固件默认不带Docker，需要Docker请自行fork，修改配置文件
  
此项目每周一北京时间 00:00 触发编译；完成时间取决于 Actions 排队、依赖下载和编译耗时。也可以在 Actions → Build OpenWrt_x86_64 → Run workflow 中手动运行。
  
免配置，支持IPV6
  
LAN 管理地址为 **192.168.3.201**，网关和 DNS 为 `192.168.3.1`，以 `files/etc/config/network` 为准。
账号:root默认密码为：admin
请用Google Chrome浏览器来进入WEB管理界面，其他浏览器可能不兼容！！！

## 当前主题与插件

- 默认使用 [MMWX 主题](https://github.com/Wyatt323/luci-theme-mmwx)，同时内置 Argon。
- OpenClash 仅从 [vernesong/OpenClash](https://github.com/vernesong/OpenClash) 官方仓库拉取。
- VSSR 已停用，移除了失效的 VSSR 与 OpenClash 副本下载命令。
- 网速测试改用原作者 [sirpdboy/NetSpeedTest](https://github.com/sirpdboy/NetSpeedTest)，包括其配套依赖。

## 验证与排查

- 手动运行时勾选 `config_only`，只检查 feeds、额外软件包和 `make defconfig` 后的最终配置，不执行固件下载、编译或发布。
- 正常编译时保持 `config_only` 不勾选。下载阶段首次最多 35 分钟，失败后降低并发重试，最多再运行 25 分钟；校验由构建系统负责，不按文件大小删除下载内容。
- 下载文件使用 Actions 缓存。下载或编译失败时，可以在该任务的 Artifacts 中下载 `build-logs`，查看 `download.log`、`build.log`、最终配置和源码提交版本。
- 如果 `make defconfig` 移除了请求的软件包，会输出警告；MMWX、OpenClash 和网速测试缺失时直接停止构建。
- 只有编译成功且实际生成 x86 镜像后才会上传固件和创建 Release。
- `Update Checker` 保持手动触发，用于检查 LEDE 上游版本并按需触发主工作流；不再需要单独的 `ACTIONS_TRIGGER_PAT`。每周定时编译由主工作流负责。

# 更新日志
## 2023年6月5日
由于之前上游代码的改动，变成了5.15内核，今天起重新编译6.1内核
## 2023年4月14日
### 加入design主题
![](https://img.imgdd.com/f210f3.dac3be67-fb91-42a3-943a-ee088685249f.png)
![](https://img.imgdd.com/f210f3.51b93cd8-5b4c-4377-9f8d-d928a30cf1b9.png)
  
## 2022年11月11日
### 由于高大全版本编译时间过长，导致编译失败，所以请在X86_full中自行选择需要的插件进行编译
