sudo yum install git clang -y
sudo yum install elfutils-libelf-devel -y
sudo yum install libbpf-devel -y
sudo curl -L -o /usr/src/linux.tar.xz https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.102.tar.xz
sudo tar -C /usr/src -xf /usr/src/linux.tar.xz
sudo rm /usr/src/linux.tar.xz
sudo mv /usr/src/linux-5.10.102 /usr/src/linux

# Amazon linux의 경우 bpf가 마운트 되어있지 않음 마운트 따로 해야함
# mount -t bpf /sys/fs/bpf /sys/fs/bpf