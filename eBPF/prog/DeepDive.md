# eBPF prog - Deep Dive

## include를 통한 각 type별 bpf_prog_ops 객체 생성
[/include/linux/bpf.h](https://elixir.bootlin.com/linux/v5.19/source/include/linux/bpf.h#L1455) 기준
```c
#define BPF_PROG_TYPE(_id, _name, prog_ctx_type, kern_ctx_type) \
		extern const struct bpf_prog_ops _name ## _prog_ops; \
		extern const struct bpf_verifier_ops _name ## _verifier_ops;
...
#include <linux/bpf_types.h>
...
#undef BPF_PROG_TYPE
```
1455 ~ 1462까지 `BPF_PROG_TYPE` 매크로가 적용되는것을 알 수 있음.

## bpf.h
1456 ~ 1457라인의 `struct bpf_prog_ops`, `struct bpf_verifier_ops` 구조체를 확인해보면

**[struct bpf_prog_ops](https://elixir.bootlin.com/linux/v5.19/source/include/linux/bpf.h#L633)**
```c
struct bpf_prog_ops {
	int (*test_run)(struct bpf_prog *prog, const union bpf_attr *kattr, union bpf_attr __user *uattr);
};
```

**[struct bpf_verifier_ops](https://elixir.bootlin.com/linux/v5.19/source/include/linux/bpf.h#L638)**
```c
struct bpf_verifier_ops {
	/* retrun eBPF function prototype for verification */
	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id, const struct bpf_prog *prog);

	/* return true if 'size' wide access at offset 'off' within bpf_context
	 * with 'type' (read or write) is allowed
	 */
	bool (*is_valid_access)(int off, int size, enum bpf_acccess_type type,
							const struct bpf_prog *prog,
							struct bpf_insn_access_aux *info);
	int (*gen_prologue)(struct bpf_insn *orig, bool direct_write, const struct bpf_prog *prog);
	int (*gen_id_abs)(const struct bpf_insn *orig, struct bpf_insn *insn_buf);
	u32 (*convert_ctx_access)(enum bpf_access_type type, const struct bpf_insn *src, struct bpf_insn *dst, struct bpf_prog *prog, u32 *target_size);
	int (*btf_struct_access)(struct bpf_verifier_log *log,
							const struct btf *btf,
							const struct btft_type *t, int off, int size,
							enum bpf_access_type atype,
							u32 *next_btf_id, enum bpf_type_flag *flag);
};
```
`struct bpf_prog_ops`, `struct bpf_verifier_ops`의 모든 필드가 함수 포인터로 구성된것을 확인 할 수 있음.\
즉 `struct bpf_prog_ops`, `struct bpf_verifier_ops`는 interface의 성형야르 가짐을 확인 할 수 있음.

```c
#define BPF_PROG_TYPE(_id, _name, prog_ctx_type, kern_ctx_type) \
		extern const struct bpf_prog_ops _name ## _prog_ops; \
		extern const struct bpf_verifier_ops _name ## _verifier_ops;
```
`BPF_PROG_TYPE`의 정의에 따라 외부변수로 사용 함. \
외부변수 명은 `_name_prog_ops`, `_name_verifier_ops` 형태를 가지게 됨.

## [bpf_types.h](https://elixir.bootlin.com/linux/v5.19/source/include/linux/bpf_types.h#L5)
```c
#ifdef CONFIG_NET
BPF_PROG_TYPE(BPF_PROG_TYPE_SOCKET_FILTER, sk_filter, struct __sk_buff, struct sk_buff)
BPF_PROG_TYPE(BPF_PROG_TYPE_SCHED_CLS, tc_cls_act, struct __sk_buff, struct sk_buff)
BPF_PROG_TYPE(BPF_PROG_TYPE_SCHED_ACT, tc_cls_act, struct __sk_buff, struct sk_buff)
BPF_PROG_TYPE(BPF_PROG_TYPE_XDP, xdp, struct xdp_md, struct xdp_buff)

#ifdef CONFIG_CGROUP_BPF
BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP, cg_skb, struct __sk_buff, struct sk_buff)
BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_SOCK, cg_sock, struct bpf_sock, struct sock)
BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_SOCK_ADDR, cg_sock_addr, struct bpf_sock_addr, struct bpf_sock_addr_kern)
#endif

BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_IN, lwt_in, struct __sk_buff, struct sk_buff)
BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_OUT, lwt_out, struct __sk_buff, struct sk_buff)
BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_XMIT, lwt_xmit, struct __sk_buff, struct sk_buff)
BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_SEG6LOCAL, lwt_seg6local, struct __sk_buff, struct sk_buff)
BPF_PROG_TYPE(BPF_PROG_TYPE_SOCK_OPS, sock_ops, struct bpf_sock_ops, struct bpf_sock_ops_kern)
BPF_PROG_TYPE(BPF_PROG_TYPE_SK_SKB, sk_skb, struct __sk_buff, struct sk_buff)
BPF_PROG_TYPE(BPF_PROG_TYPE_SK_MSG, sk_msg, struct sk_msg_md, struct sk_msg)
BPF_PROG_TYPE(BPF_PROG_TYPE_FLOW_DISSECTOR, flow_dissector, struct __sk_buff, struct bpf_flow_dissector)
#endif

#ifdef CONFIG_BPF_EVENTS
BPF_PROG_TYPE(BPF_PROG_TYPE_KPROBE, kpobe, bpf_user_pt_regs_t, struct pg_regs)
BPF_PROG_TYPE(BPF_PROG_TYPE_TRACEPOINT, tracepoint, __u64, u64)
BPF_PROG_TYPE(BPF_PROG_TYPE_PERF_EVENT, perf_event, struct bbpf_perf_event_data, struct bpf_perf_event_data_kern)
BPF_PROG_TYPE(BPF_PROG_TYPE_RAW_TRACEPOINT, raw_tracepoint, struct bpf_raw_tracepoint_args, u64)
BPF_PROG_TYPE(BPF_PROG_TYPE_RAW_TRACEPOINT_WRITABLE, raw_tracepoint_writable, struct bpf_raw_tracepoint_args, u64)
BPF_PROG_TYPE(BPF_PROG_TYPE_TRACING, tracing, void *, void *)
#endif

#ifdef CONFIG_CGROUP_BPF
BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_DEVICE, cg_dev, struct bpf_cgroup_dev_ctx, struct bpf_cgroup_dev_ctx)
BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_SYSCTL, cg_sysctl, struct bpf_sysctl, struct bpf_sysctl_kern)
BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_SOCKOPT, cg_sockopt, struct bpf_sockopt, struct bpf_sockopt_kern)
#endif

#ifdef CONFIG_BPF_LIRC_MODE2
BPF_PROG_TYPE(BPF_PROG_TYPE_LIRC_MODE2, lirc_mode2, __u32, u32)
#endif

#ifdef CONFIG_INET
BPF_PROG_TYPE(BPF_PROG_TYPE_SK_REUSEPORT, sk_reuseport, struct sk_reuseport_md, struct sk_reuseport_kern)
BPF_PROG_TYPE(BPF_PROG_TYPE_SK_LOOKUO, sk_lookup, struct bpf_sk_lookup, struct bpf_sk_lookup_kern)
#endif
#if defined(CONFIG_BPF_JIT)
BPF_PROG_TYPE(BPF_PROG_TYPE_STRUCT_OPS, bpf_struct_ops, void *, void *)
BPF_PROG_TYPE(BPF_PROG_TYPE_EXIT, bpf_extension, void * void *)
#ifdef CONFIG_BPF_LSM
BPF_PROG_TYPE(BPF_PROG_TYPE_LSM, lsm, void *, void *)
#endif /* CONFIG_BPF_LSM */
#endif
BPF_PROG_TYPE(BPF_PROG_TYPE_SYSCALL, bpf_syscall, void *, void *)
```

## example
각각의 `bpf_prog_ops`, `bpf_verifier_ops` 구현체를 찾는 방법은 `define`의 `_name` + `_prog_ops`, `_verifier_ops`를 이용해 검색.
### sk_filter_prog_ops
```c
const struct bpf_prog_ops sk_filter_prog_ops = {
	.test_run	=	bpf_prog_test_run_skib,
}
```
### sk_filter_verifier_ops
```c
const struct bpf_verifier_ops sk_filter_verifier_ops = {
	.get_func_proto		=	sk_filter_func_proto,
	.is_valid_access	=	sk_filter_is_valid_access,
	.convert_ctx_access	=	bpf_convert_ctx_access,
	.gen_ld_abs			=	bpf_gen_ld_abs,
}
```