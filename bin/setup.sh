#!/usr/bin/env bash

HOME_DIR=$1
if [ -z $HOME_DIR ]
then
  $HOME_DIR=~
fi

cd $HOME_DIR

# ---OpenResty---
sudo apt-get -y install --no-install-recommends wget gnupg ca-certificates

# import our GPG key:
wget -O - https://openresty.org/package/pubkey.gpg | sudo apt-key add -

# for installing the add-apt-repository command
# (you can remove this package and its dependencies later):
sudo apt-get -y install --no-install-recommends software-properties-common

# add the our official APT repository:
sudo add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"

# to update the APT index:
sudo apt-get update

sudo apt-get -y install --no-install-recommends openresty

# ---LuaRocks---
sudo apt-get -y install build-essential libreadline-dev unzip

curl -R -O http://www.lua.org/ftp/lua-5.3.4.tar.gz
tar -zxf lua-5.3.4.tar.gz
cd lua-5.3.4
make linux test
sudo make install

cd $HOME_DIR
wget https://luarocks.org/releases/luarocks-3.3.1.tar.gz
tar zxpf luarocks-3.3.1.tar.gz
cd luarocks-3.3.1
./configure
make
sudo make install

# ---resty-auto-ssl---
sudo luarocks install lua-resty-auto-ssl
sudo mkdir /etc/resty-auto-ssl
sudo chmod 777 /etc/resty-auto-ssl
sudo ln -s $(pwd)/lua_modules/share/lua/5.3 /usr/local/share/lua/5.1
sudo ln -s $(pwd)/lua_modules/bin/resty-auto-ssl /usr/local/bin/resty-auto-ssl

sudo apt-get -y install ruby
sudo gem install dotenv
sudo apt-get install -y jq
sudo apt-get install -y awscli

cd $HOME_DIR
mkdir app
cd app

wget https://raw.githubusercontent.com/heedsoftware/auto-assign-elastic-ip/master/auto-assign-elastic-ip.sh
chmod 744 auto-assign-elastic-ip.sh
./auto-assign-elastic-ip.sh

wget https://raw.githubusercontent.com/CrowdEngine/helium-ssl/master/bin/rename-instance.sh
chmod 744 rename-instance.sh
./rename-instance.sh

wget https://raw.githubusercontent.com/CrowdEngine/helium-ssl/master/bin/start-nginx
chmod 744 start-nginx

mkdir logs
touch logs/error.log
mkdir config
cd config
wget https://raw.githubusercontent.com/CrowdEngine/helium-ssl/master/config/nginx.conf.erb
wget https://raw.githubusercontent.com/CrowdEngine/helium-ssl/master/config/mime.types
cd ..
mkdir ssl
cd ssl
wget https://raw.githubusercontent.com/CrowdEngine/helium-ssl/master/ssl/localhost.crt
wget https://raw.githubusercontent.com/CrowdEngine/helium-ssl/master/ssl/localhost.key
cd ..
touch .env

sudo systemctl stop openresty.service
sudo systemctl disable openresty.service
cd /etc/systemd/system/
sudo wget https://raw.githubusercontent.com/CrowdEngine/helium-ssl/master/systemctl/ssl-proxy.service
sudo systemctl enable ssl-proxy.service
