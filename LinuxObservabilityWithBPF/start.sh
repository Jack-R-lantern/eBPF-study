#!/bin/bash
docker run -it \
      --privileged \
      -v /lib/modules:/lib/modules:ro \
      -v /etc/localtime:/etc/localtime:ro \
      -v `pwd`:/root/LinuxObservabilityWithBPF \
      -p 9090:9090 \
      --name cbpf \
      --pid=host \
      ebpf