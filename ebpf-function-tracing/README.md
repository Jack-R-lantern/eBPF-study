# ebpf-function-tracing

## 참조 기사
- https://petermalmgren.com/docker-mac-bpf-perf/
- https://github.com/singe/ebpf-docker-for-mac
- https://blog.px.dev/ebpf-function-tracing/
- https://dev.to/aserputoff/aarch64-x86-64-registers-and-instruction-quick-start-19bd

## 테스트 진행 환경
### Mac
- Apple Silicon M1
### Linuxkit
- 5.10.104-linuxkit
- `docker run -it --rm ubuntu uname -r` 확인 가능.
### Docker version
```
Client:
 Cloud integration: v1.0.22
 Version:           20.10.13
 API version:       1.41
 Go version:        go1.16.15
 Git commit:        a224086
 Built:             Thu Mar 10 14:08:43 2022
 OS/Arch:           darwin/arm64
 Context:           default
 Experimental:      true

Server: Docker Desktop 4.6.0 (75818)
 Engine:
  Version:          20.10.13
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.16.15
  Git commit:       906f57f
  Built:            Thu Mar 10 14:05:37 2022
  OS/Arch:          linux/arm64
  Experimental:     false
 containerd:
  Version:          1.5.10
  GitCommit:        2a1d4dbdb2a1030dc5b01e96fb110a9d9f150ecc
 runc:
  Version:          1.0.3
  GitCommit:        v1.0.3-0-gf46b6ba
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

## Dockerfile
```dockerfile
FROM docker/for-desktop-kernel:5.10.104-ad41e9402fa6e51d2635fb92e4cb6b90107caa25 AS ksrc

FROM golang:1.18

WORKDIR /
COPY --from=ksrc /kernel-dev.tar /
RUN tar xf kernel-dev.tar && rm kernel-dev.tar

RUN apt-get update && \ 
     apt install -y kmod \
                    clang \
                    libbpfcc-dev \
                    bpfcc-tools

WORKDIR /root
CMD mount -t debugfs debugfs /sys/kernel/debug && /bin/bash
```

## Test SourceCode
### [http server](server/main.go)
### [tracer](trace/main.go)
```go
const bpfProgram = `
#include <uapi/linux/ptrace.h>
BPF_PERF_OUTPUT(trace);
// This function will be registered to be called everytime
// main.computeE is called.
inline int computeECalled(struct pt_regs *ctx) {
  // The input argument is stored in ax.
  long val = ctx->orig_regs[0];
  trace.perf_submit(ctx, &val, sizeof(val));
  return 0;
}
`
```
`struct pt_regs`의 경우 해당하는 아키텍쳐마다 다름.
`https://github.com/torvalds/linux/tree/master/arch` 하위 디렉토리에서 자신의 아키텍쳐에 맞는 register 정보 확인.