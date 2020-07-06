#!/bin/bash

CURRENT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
source ${CURRENT_DIR}/common.sh

[ $(id -u) != "0" ] && { ansi --bold --bg-red "请用 root 账户执行本脚本"; exit 1; }

MYSQL_ROOT_PASSWORD=`random_string`

function init_system {
    export LC_ALL="en_US.UTF-8"
    echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
    locale-gen en_US.UTF-8
    locale-gen zh_CN.UTF-8
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    mv /bin/sleep /bin/sleep~
    touch /bin/sleep
    chmod +x /bin/sleep
    init_alias
    echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse' > /etc/apt/sources.list
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse' >> /etc/apt/sources.list    
    apt update 
    apt install -y libsensors4=1:3.4.0-4 --allow-downgrades
    apt install -y libuv1=1.18.0-3 --allow-downgrades
    apt install -y libuv1-dev    
}

function install_basic_softwares {
    apt upgrade -y && apt autoremove -y
    apt install -y unzip supervisor software-properties-common
}

function install_php {
    apt install -y php7.2-bcmath php7.2-cli php7.2-curl php7.2-fpm php7.2-gd php7.2-mbstring php7.2-mysql php7.2-opcache php7.2-pgsql php7.2-readline php7.2-xml php7.2-zip
}

function install_mysql {
    debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"
    apt install -y mysql-server mysql-client
    usermod -d /var/lib/mysql/ mysql
}

function install_nginx {   
    apt install -y nginx
    sed -i 's/http {/http {\n\n    #WSL Unix Socket BUG Repair \n    fastcgi_buffering off; /' /etc/nginx/nginx.conf
    systemctl enable nginx.service
}

function install_memcached {    
    apt install -y memcached
}

function install_beanstalkd {
    apt install -y beanstalkd
}

function install_redis {
    apt install -y redis-server
}

function install_composer {
    apt install -y composer
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
}

function install_node_npm {      
    apt install -y nodejs    
    apt install -y nodejs-dev
    apt install -y npm
    npm config set registry https://registry.npm.taobao.org
}

function update_npm {      
    npm install -g n && n stable
    npm -g install npm@next
}

function init_ssh {    
    apt remove -y openssh-server --purge
    apt install -y openssh-client=1:7.6p1-4ubuntu0.4 --allow-downgrades
    rm -fr /etc/ssh/sshd_config
    apt install -y -q openssh-server
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
    service ssh --full-restart
}

function init_alias {
    alias wsl > /dev/null 2>&1 || {
        echo "alias wsl='service nginx start & service ssh start & service mysql start & service redis-server start & service php7.2-fpm start'" >> ~/.bash_aliases
    }    
}

call_function init_system "1.配置系统" ${LOG_PATH}
call_function install_basic_softwares "2.安装软件" ${LOG_PATH}
call_function install_php "3.安装PHP" ${LOG_PATH}
call_function install_mysql "4.安装Mysql" ${LOG_PATH}
call_function install_nginx "5.安装Nginx" ${LOG_PATH}
call_function install_memcached "6.安装Memcached" ${LOG_PATH}
call_function install_beanstalkd "7.安装Beanstalkd" ${LOG_PATH}
call_function install_redis "8.安装Redis" ${LOG_PATH}
call_function install_composer "9.安装Composer" ${LOG_PATH}
call_function install_node_npm "10.安装Npm" ${LOG_PATH}
call_function update_npm "11.更新Npm" ${LOG_PATH}
call_function init_ssh "12.配置SSH" ${LOG_PATH}


ansi
ansi --green --bold "--操作完成--"
ansi
ansi -n "Mysql root 密码："
ansi --bold --bg-white --red ${MYSQL_ROOT_PASSWORD}
ansi
ansi --green --bold "1.请手动执行 $(ansi::yellow)source ~/.bash_aliases$(ansi::green) 使 alias 指令生效。"
ansi --green --bold "2.快捷启动PHP MYSQL SSH服务，只需 root用户下 运行 $(ansi::yellow)wsl$(ansi::green) "
ansi
