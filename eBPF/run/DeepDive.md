# eBPF run - Deep Dive

## uapi/linux/bpf.h
**[enum bpf_cmd](https://elixir.bootlin.com/linux/v5.19/source/include/uapi/linux/bpf.h#L840)**
```c
enum bpf_cmd {
	BPF_MAP_CREATE,
	BPF_MAP_LOOKUP_ELEM,
	BPF_MAP_UPDATE_ELEM,
	BPF_MAP_DELETE_ELEM,
	BPF_MAP_GET_NEXT_KEY,
	BPF_PROG_LOAD,
	BPF_OBJ_PIN,
	BPF_OBJ_GET,
	BPF_PROG_ATTACH,
	BPF_PROG_DETACH,
	BPF_PROG_TEST_RUN,
	BPF_PROG_RUN = BPF_PROG_TEST_RUN,
	BPF_PROG_GET_NEXT_ID,
	BPF_MAP_GET_NEXT_ID,
	BPF_PROG_GET_FD_BY_ID,
	BPF_MAP_GET_FD_BY_ID,
	BPF_OBJ_GET_INFO_BY_FD,
	BPF_PROG_QUERY,
	BPF_RAW_TRACEPOINT_OPEN,
	BPF_BTF_LOAD,
	BPF_BTF_GET_FD_BY_ID,
	BPF_TASK_FD_QUERY,
	BPF_MAP_LOOKUP_AND_DELETE_ELEM,
	BPF_MAP_FREEZE,
	BPF_BTF_GET_NEXT_ID,
	BPF_MAP_LOOKUP_BATCH,
	BPF_MAP_LOOKUP_AND_DELETE_BATCH,
	BPF_MAP_UPDATE_BATCH,
	BPF_MAP_DELETE_BATCH,
	BPF_LINK_CREATE,
	BPF_LINK_UPDATE,
	BPF_LINK_GET_FD_BY_ID,
	BPF_LINK_GET_NEXT_ID,
	BPF_ENABLE_STATS,
	BPF_ITER_CREATE,
	BPF_LINK_DETACH,
	BPF_PROG_BIND_MAP,
}
```
851 ~ 852 라인에 enum이 같은 값으로 설정된것을 확인 할 수 있음.

## test_run
`BPF_PROG_RUN`을 이용했을때 무엇을 수행하는지 파악하기 위해 각 타입별 `bpf_prog_ops`를 확인해야함. \
예시를 들어 설명을 진행하겠음.

### sk_filter_prog_ops
**[net/core/filter.c](https://elixir.bootlin.com/linux/v5.19/source/net/core/filter.c#10486)**
```c
const struct bpf_prog_ops sk_filter_prog_ops = {
	.test_run	=	bpf_prog_test_run_skb,
}
```
`bpf_prog_test_run_skb`의 구현체가 존재하는 위치
* include/linux/bpf.h
* net/bpf/test_run.c

**[include/linux/bpf.h](https://elixir.bootlin.com/linux/v5.19/source/include/linux/bpf.h#L1972)**
```c
static inline int bpf_prog_test_run_skb(struct bpf_prog *prog,
										const union bpf_attr *kattr,
										union bpf_attr __user *uattr)
{
	return -ENOTSUPP;
}
```
`kernel config`의 `BPF_SYSCALL`이 설정되지 않은 경우 `include/linux/bpf.h`의 `ENOTSUPP`을 리턴하는 `bpf_prog_test_run_skb`로 매핑됨.

**[net/bpf/test_run.c](https://elixir.bootlin.com/linux/v5.19/source/net/bpf/test_run.c#L1053)**
```c
int bpf_prog_test_run_skb(struct bpf_prog *prog, const union bpf_attr *kattr, union bpf_attr __user *uattr)
{
	bool is_l2 = false, is_direct_pkt_access = false;
	struct net *net = current->nsproxy->net_ns;
	struct net_device *dev = net->loopback_dev;
	u32 size = kattr->test.data_size_in;
	
	...
	
	switch (prog->type) {
	case BPF_PROG_TYPE_SCHED_CLS:
	case BPF_PROG_TYPE_SCHED_ACT:
		is_l2 = true;
		fallthrough;
	case BPF_PROG_TYPE_LWT_IN:
	case BPF_PROG_TYPE_LWT_OUT:
	case BPF_PROG_TYPE_LWT_XMIT:
		is_direct_pkt_access = true;
		break;
	default:
		break;
	}

	...

	switch (skb->protocol) {
	case htons(ETH_P_IP):
		sk->sk_family = AF_INET;
		if (sizeof(struct iphdr) <= skb_headlen(skb)) {
			sk->sk_rcv_saddr = ip_hdr(skb)->saddr;
			sk->sk_daddr = ip_hdr(skb)->daddr;
		}
		break;
#if IS_ENABLED(CONFIG_IPV6)
	case htons(ETH_P_IPV6):
		sk->sk_family = AF_INET6;
		if (sizeof(struct ipv6hdr) <= skb_headlen(skb)) {
			sk->sk_rcv_addr = ip_hdr(skb)->saddr;
			sk->sk_daddr = ip_hdr(skb)->daddr;
		}
		break;
#endif
	default:
		break;
	}

	...

out:
	if (dev && dev != net->loopback_dev)
		dev_put(dev);
	kfree_skb(skb);
	sk_free(sk);
	kfree(crtx);
	return ret;
}
```
`kernel config`의 `BPF_SYSCALL`이 설정된 경우 `net/bpf/test_run.c`의 로직이 구현된 `bpf_prog_test_run_skb`로 매핑됨.