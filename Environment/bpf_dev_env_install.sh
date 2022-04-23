#!/bin/bash

echo -e "\e[1;32mPackage Manager Update\e[0m"
sudo apt update

echo -e "\e[1;32mRequire Package Install\e[0m"
sudo apt install -y bison build-essential cmake flex git libedit-dev pkg-config libssl-dev dwarves \
 		    clang-11 libclang-11-dev python zlib1g-dev libelf-dev libfl-dev python3-distutils
if [ $? -eq 0 ];then
	echo -e "\e[1;32mRequire Package Install Success\e[0m"
else
	echo -e "\e[1;31mRequire Package Install Failed\e[0m"
	exit
fi

cd ~
# libbpf install
echo -e "\e[1;32mlibbpf install...\e[0m"
echo -e "\t\e[1;32mlibbpf download...\e[0m"
curl -LO https://github.com/libbpf/libbpf/archive/refs/tags/v0.7.0.tar.gz && \
	 tar -xzf v0.7.0.tar.gz && \
	 rm -rf v0.7.0.tar.gz
if [ $? -eq 0 ];then
	echo -e "\t\e[1;32mlibbpf download complete...\e[0m"
else
	echo -e "\t\e[1:31mlibbpf download failed...\e[0m"
	exit
fi
echo -e "\t\e[1;32mlibbpf build...\e[0m"
cd ./libbpf-0.7.0/src && make && sudo make install && sudo make install_uapi_headers
if [ $? -eq 0 ];then
	echo -e "\t\e[1;32mlibbpf build complte...\e[0m"
else
	echo -e "\t\e[1;31mlibbpf build failed...\e[0m"
	exit
fi
echo -e "\e[1;32mlibbpf install complete...\e[0m\n"

# golang install
echo -e "\e[1;32mgolang install...\e[0m"
cd ~
curl -LO https://go.dev/dl/go1.18.1.linux-armv6l.tar.gz
sudo tar -C /usr/local -xzf go1.18.1.linux-armv6l.tar.gz
rm go1.18.1.linux-armv6l.tar.gz
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc