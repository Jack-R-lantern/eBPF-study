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