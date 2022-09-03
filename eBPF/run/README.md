# eBPF - Running BPF programs from userspace

`BPF_PROG_RUN` 명령어는 `bpf()` 시스템 콜을 통해 커널 내부에서 BPF 프로그램을 실행하고 유저 영역으로 결과를 리턴.\
`BPF_PROG_RUN`은 사용자 제공 컨텍스트 개체에 대해 BPF 프로그램을 단위 테스트하고, 커널의 프로그램을 명시적으로 실행하여 부작용을 일으킬 수 있음.\
`BPF_PROG_RUN`은 이전에 `BPF_PROG_TEST_RUN`으로 불렸음. \
두 상수는 동일한 값을 가지며 UAPI header에 정의 되어 있음.

## BPF_PROG_RUN available list
`BPF_PROG_RUN`명령어를 통해 해당 되는 `program type`에 한해 실행 가능.
* BPF_PROG_TYPE_SOCKET_FILTER
* BPF_PROG_TYPE_SCHED_CLS
* BPF_PROG_TYPE_SCHED_ACT
* BPF_PROG_TYPE_XDP
* BPF_PROG_TYPE_SK_LOOKUP
* BPF_PROG_TYPE_CGROUP_SKB
* BPF_PROG_TYPE_LWT_IN
* BPF_PROG_TYPE_LWT_OUT
* BPF_PROG_TYPE_LWT_XMIT
* BPF_PROG_TYPE_LWT_SEG6LOCAL
* BPF_PROG_TYPE_FLOW_DISSECTOR
* BPF_PROG_TYPE_STRUCT_OPS
* BPF_PROG_TYPE_RAW_TRACEPOINT
* BPF_PROG_TYPE_SYSCALL

`BPF_PROG_RUN`을 실행할 때 유저 영역은 입력 컨텍스트 객체와 BPF 프로그램이 동작하기위한 packet을 저장하고 있는 버퍼를 제공해야함. \
커널은 프로그램을 실행하고 결과를 유저 영역으로 리턴함. \
`BPF_PROG_RUN`으로 실행되는 동안 해당 프로그램은 아무런 `side effect`가 없다는 점에 유의. \
특히 패킷을 `redirected` 또는 `dropped`하지 않음. \
프로그램 반환 코드는 단지 유저 영역으로 반환 할 뿐임. \
`XDP`의 경우 실행을 위한 별도의 모드를 제공함.