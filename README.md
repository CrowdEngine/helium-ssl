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
sudo apt-get -y install build-essential libreadline-dev
sudo apt-get -y install unzip

curl -R -O http://www.lua.org/ftp/lua-5.3.4.tar.gz
tar -zxf lua-5.3.4.tar.gz
cd lua-5.3.4
make linux test
sudo make install

wget https://luarocks.org/releases/luarocks-3.3.1.tar.gz
tar zxpf luarocks-3.3.1.tar.gz
cd luarocks-3.3.1

./configure
make
sudo make install

cd ~

# ---resty-auto-ssl---
luarocks install lua-resty-auto-ssl
sudo mkdir /etc/resty-auto-ssl
sudo chmod 777 /etc/resty-auto-ssl
sudo ln -s $(pwd)/lua_modules/share/lua/5.3 /usr/local/share/lua/5.1
sudo ln -s $(pwd)/lua_modules/bin/resty-auto-ssl /usr/local/bin/resty-auto-ssl

sudo apt-get -y install ruby
sudo gem install dotenv
sudo apt-get install -y jq
sudo apt-get install -y awscli

mkdir app
cd app

wget https://raw.githubusercontent.com/heedsoftware/auto-assign-elastic-ip/master/auto-assign-elastic-ip.sh
chmod 744 auto-assign-elastic-ip.sh

vim rename-instance.sh
chmod 744 rename-instance.sh

vim start-nginx
chmod 744 start-nginx

mkdir logs
mkdir config
vim config/nginx.conf.erb
vim config/mime.types
mkdir ssl
vim ssl/localhost.crt
vim ssl/localhost.key
touch .env

sudo bash -c 'echo "[Unit]
Description=SSL proxy (openresty/nginx)
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
ExecStart=/home/ubuntu/app/start-nginx /home/ubuntu
Restart=always
PIDFile=/var/run/ssl-proxy.pid" > /etc/systemd/system/ssl-proxy.service'
sudo systemctl enable ssl-proxy.service
