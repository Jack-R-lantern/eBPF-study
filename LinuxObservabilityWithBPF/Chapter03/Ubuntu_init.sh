#!/bin/bash
sudo apt update && \ 
sudo apt install -y bison build-essential cmake flex git libedit-dev \
 					clang-12 libclang-12-dev python zlib1g-dev libelf-dev libfl-dev python3-distutils

# bcc source download & install
echo "bcc install..."
sudo curl -LO https://github.com/iovisor/bcc/releases/download/v0.24.0/bcc-src-with-submodule.tar.gz && \
	 tar -xzf bcc-src-with-submodule.tar.gz && \
	 rm -rf bcc-src-with-submodule.tar.gz

sudo mkdir bcc/build && \
	 cd bcc/build &&
	 sudo cmake .. && \
	 sudo make && \
	 sudo make install

# linux kernel soruce download
echo "linux kernel source download..."
sudo curl -L -o /usr/src/linux.tar.xz https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/linux/5.11.0-41.45/linux_5.11.0.orig.tar.gz
sudo tar -C /usr/src -xzf /usr/src/linux.tar.xz
sudo mv /usr/src/linux-5.11 /usr/src/linux
sudo rm -rf /usr/src/linux.tar.xz

# golang install
echo "golang install..."
cd ~
curl -LO https://go.dev/dl/go1.18.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz
rm go1.18.linux-amd64.tar.gz
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc
