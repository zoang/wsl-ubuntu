# WSL Ubuntu 20.04快速搭建PHP非生产环境

## 自动安装软件列表

* PHP 7.4
* Nginx
* MySQL
* Composer
* Nodejs 
* Redis
* Beanstalkd
* Memcached

## 可选手动安装软件列表*

以下软件需手动执行安装脚本：

* Elasticsearch：`./install_elasticsearch.sh`


## 重要说明

近期由于RAW受DNS污染，无法访问RAW进行安装，克隆文件后进SRC使用./install.sh安装


## 安装步骤

##### 请用root用户执行安装脚本命令

```
wget -qO- https://raw.githubusercontent.com/zoang/wsl-ubuntu/master/download.sh - | bash
```

此命令会将安装脚本下载到当前用户目录下的 `wsl-ubuntu` 目录，并自动执行安装，在安装结束后会在屏幕上输出 Mysql root 账号的密码，请妥善保存。

如果当前不是 root 用户则不会自动安装，请切换到 root 账户后执行 `./install.sh`。


## 其他说明


##### 1. WSL 快捷启动环境```
安装脚本使用 Alias 集成部分环境服务快速启动。请进入 root 用户后执行 wsl 即可。
wsl快捷启动PHP、MYSQL、SSH、REDIS等。

```
#wsl
```

##### ~~2. 在 /etc/nginx/nginx.conf http {} 内加入下面代码（已在安装SH中，自动加入）~~

```
http{
#加入以下代码修复WSL Unix Socket BUG
fastcgi_buffering off; 

}
```

##### 3. 默认主机说明

```
默认主机：127.0.0.1
适用 Xshell \ Mysql 连接
```

##### 3. HOST 说明
直接修改 Windows host 

```
# C:\Windows\System32\drivers\etc\hosts
127.0.0.1 google.com
```

##### 3. NGINX 说明

/etc/nginx/sites-enabled下添加站点配置,下列参考

```
server {
    listen 80;
    server_name zoang.test www.zoang.test;      
    
    root "/mnt/d/web/zoang/public";

    index index.html index.htm index.php;
     
    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log /var/log/nginx/zoang.log;
    error_log /var/log/nginx/zoang-error.log error;

    sendfile off;

    client_max_body_size 100m;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
```
