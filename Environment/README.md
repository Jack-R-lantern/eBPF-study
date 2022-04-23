# Environment

## Hardware/OS
* Hardware: https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/
* OS: Linux raspberrypi 5.15.32-v7+ #1538 SMP Thu Mar 31 19:38:48 BST 2022 armv7l GNU/Linux

## Compiler
### Clang
### GCC

## Kernel Config
`make bcm2709_defconfig`를 이용하여 `.config`를 생성합니다. \
이후 `cat .config | grep BPF`를 이용해 확인하면 몇몇 설정이 빠진것을 볼 수 있습니다. \
eBPF를 위해 필요한 기능들을 따로 `.config`에 추가해 커널을 빌드하도록 합시다.
![kernel_config](../Images/kernel_config.jpg)