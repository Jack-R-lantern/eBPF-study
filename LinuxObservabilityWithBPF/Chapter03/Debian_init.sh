sudo apt-get update
sudo apt-get install git make clang -y
sudo apt-get install libbpf-dev libelf-dev -y
sudo git clone --depth=1 https://github.com/jplozi/linux-4.19.git /usr/src/linux