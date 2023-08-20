> 下面的 `DOMAIN` 都是自己的根域名地址，比如 `baidu.com`

## 准备 github oauth 认证
github 申请新的应用，获取 client id 和 client secret
```bash
Homepage: log.DOMAIN
callback URL: log.DOMAIN/api/v2/login
```

## 准备域名
把根域名添加到 cloudflare，添加一个 ns 记录,然后获取 zone id
```bash
name: log
content: ns.DOMAIN
Proxy status: DNS Only
TTL: Auto
```

## 修改 config.yaml 配置文件

## 部署
```bash
$ python3 -m venv .env
$ source .env/bin/activate
$ pip install -r requirements.txt
$ python build.py
```

> 基于 [Hyuga](https://github.com/ac0d3r/Hyuga/)