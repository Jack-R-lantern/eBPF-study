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
