#!/bin/bash

CURRENT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
source ${CURRENT_DIR}/common.sh

[ $(id -u) != "0" ] && { ansi --bold --bg-red "请用 root 账户执行本脚本"; exit 1; }

MYSQL_ROOT_PASSWORD=`random_string`

function init_system {    
    apt update
    echo '[automount]' > /etc/wsl.conf
    echo 'enabled = true' >> /etc/wsl.conf
    echo 'root = /mnt/' >> /etc/wsl.conf
    echo 'options = "metadata,umask=22,fmask=11"' >> /etc/wsl.conf
    echo 'mountFsTab = false' >> /etc/wsl.conf   
    echo ' ' >> ~/.bashrc
    echo '#Fix mkdir command has wrong permissions' >> ~/.bashrc
    echo 'if grep -q Microsoft /proc/version; then' >> ~/.bashrc
    echo '    if [ "$(umask)" == '0000' ]; then' >> ~/.bashrc
    echo '    if [ "$(umask)" == '0000' ]; then' >> ~/.bashrc
    echo '        umask 0022' >> ~/.bashrc
    echo '    fi' >> ~/.bashrc
    echo 'fi' >> ~/.bashrc
    init_alias
}

function install_basic_softwares {    
    apt install -y unzip supervisor software-properties-common
}

function install_php {
    apt install -y php7.4-bcmath php7.4-cli php7.4-curl php7.4-fpm php7.4-gd php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-pgsql php7.4-readline php7.4-xml php7.4-zip
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
    wget https://mirrors.aliyun.com/composer/composer.phar
    mv composer.phar composer
    chmod +x composer
    sudo mv composer /usr/bin 
    yes|composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
}

function install_node_npm {      
    apt install -y nodejs    
    apt install -y nodejs-dev
    apt install -y npm
    npm config set registry https://registry.npm.taobao.org
}

function update_npm {      
    npm install -g n && n stable
    PATH="$PATH"
    npm install npm@latest -g
}

function init_alias {
    alias wsl > /dev/null 2>&1 || {
        echo "alias wsl='service nginx start & service mysql start & service redis-server start & service php7.4-fpm start'" >> ~/.bash_aliases
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


ansi
ansi --green --bold "--操作完成--"
ansi
ansi -n "Mysql root 密码："
ansi --bold --bg-white --red ${MYSQL_ROOT_PASSWORD}
ansi
ansi
ansi --green --bold "1.请手动执行 $(ansi::yellow)source ~/.bash_aliases$(ansi::green) 使 alias 指令生效。"
ansi --green --bold "2.启动PHP MYSQL服务，只需 root用户下 运行 $(ansi::yellow)wsl$(ansi::green) "
ansi
