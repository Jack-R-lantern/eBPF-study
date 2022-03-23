#!/bin/bash
docker run -it --rm \
      --privileged \
      -v /lib/modules:/lib/modules:ro \
      -v /etc/localtime:/etc/localtime:ro \
      -v `pwd`:/root/ebpf \
      -p 9090:9090 \
      --name goebpf \
      --pid=host \
      ebpf
