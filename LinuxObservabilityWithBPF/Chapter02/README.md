# Chapter02

## 발생한 문제
### bpf_program.c 컴파일 시
```
root@raspberrypi:/home/pi/eBPF-study/LinuxObservabilityWithBPF/Chapter02# clang -O2 -target bpf -c bpf_program.c -o bpf_program.o
In file included from bpf_program.c:1:
In file included from /usr/include/linux/bpf.h:11:
/usr/include/linux/types.h:5:10: fatal error: 'asm/types.h' file not found
#include <asm/types.h>
         ^~~~~~~~~~~~~
1 error generated.
```
헤더파일 `asm/types.h`를 못찾는 문제가 발생함. \
컴파일 옵션에 `-v` 추가 후 에러메시지 재 확인.
```
#include <...> search starts here:
 /usr/local/include
 /usr/lib/llvm-11/lib/clang/11.0.1/include
 /usr/include
```