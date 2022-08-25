# eBPF maps - Deep Dive

## include를 통한 각 type별 bpf_map_ops 객체 생성
[/include/linux/bpf.h](https://elixir.bootlin.com/linux/v5.19/source/include/linux/bpf.h#L1458) 기준
```c
#define	BPF_MAP_TYPE(_id, _ops)	extern const struct bpf_map_ops _ops;
...
#include <linux/bpf_types.h>
...
#undef BPF_MAP_TYPE
```
1458 ~ 1463까지 `BPF_MAP_TYPE` 매크로가 적용되는것을 알 수 있음.

## bpf.h
1458라인의 `struct bpf_map_ops` 구조체를 확인해보면

**[struct bpf_map_ops](https://elixir.bootlin.com/linux/v5.19/source/include/linux/bpf.h#L64)**
```c
/* map is generic key/value storage optionally accessible by eBPF programs */
struct bpf_map_ops {
	/* funcs callable from userspace (via syscall) */
	int (*map_alloc_check)(union bpf_attr *attr);
	struct bpf_map *(*map_alloc)(union bpf_attr *attr);
	void (*map_release)(struct bpf_map *map, struct file *map_file);
	void (*map_free)(struct bpf_map *map);
	int (*map_get_next_key)(struct bpf_map *map, void *key, void *next_key);
	void (*map_release_uref)(struct bpf_map *map);
	void *(*map_lookup_elem_sys_only)(struct bpf_map *map, void *key);
	int (*map_lookup_batch)(struct bpf_map *map, const union bpf_attr *attr, union bpf_attr __user *uattr);
	int (*map_lookup_and_delete_elem)(struct bpf_map *map, void *key, void *value, u64 flags);
	int (*map_lookup_and_delete_batch)(struct bpf_map *map, const union bpf_attr *attr, union bpf_attr __user *uattr);
	int (*map_update_batch)(struct bpf_map *map, const union bpf_attr *attr, union bpf_attr __user *uattr);
	int (*map_delete_batch)(struct bpf_map *map, const union bpf_attr *attr, union bpf_attr __user *uattr);

	/* funcs callable from userspace and from eBPF program */
	void *(*map_lookup_elem)(struct bpf_map *map, void *key);
	int (*map_update_elem)(struct bpf_map *map, void *key, void *value, u64 flags);
	int (*map_delete_elem)(struct bpf_map *map, void *key);
	int (*map_push_elem)(struct bpf_map *map, void *value, u64 flags);
	int (*map_pop_elem)(struct bpf_map *map, void *value);
	int (*map_peek_elem)(struct bpf_map *map, void *value);
	void *(*map_lookup_percpu_elem)(struct bpf_map *map, void *key, u32 cpu);

	/* funcs called by prog_array and perf_event_array map */
	void *(*map_fd_get_ptr)(struct bpf_map *map, struct file *map_file, int fd);
	void (*map_fd_put_ptr)(void *ptr);
	int (*map_gen_lookup)(struct bpf_map *map, struct bpf_insn, *insn_buf);
	u32 (*map_fd_sys_lookup_elem)(void *ptr)l
	void (*map_seq_show_elem)(struct bpf_map *map, void *key, struct seq_file *m);
	int (*map_check_btf)(const struct bpf_map *map, const struct btf *btf, const struct btf_type *key_type, const struct btf_type *value_type);

	/* Prog poke tracking helpers. */
	int (*map_poke_track)(struct bpf_map *map, struct bpf_prog_aux *aux);
	void (*map_poke_untrack)(struct bpf_map *map, struct bpf_prog_aux *aux);
	void (*map_poke_run)(struct bpf_map *map, u32 key, struct bpf_prog *old, struct bpf_prog *new);

	/* Direct value access helpers. */
	int (*map_direct_value_addr)(const struct bpf_map *map, u64 *imm, u32 off);
	int (*map_direct_value_meta)(const struct bpf_map *map, u64 imm, u32 *off);
	int (*map_mmap)(struct bpf_map *map, struct vm_area_struct *vma);
	__poll_t (*map_poll)(struct bpf_map *map, struct file *filep, struct poll_table_struct *pts);

	/* Functions called by bpf_local_storage maps */
	int (*map_local_storage_charge)(struct bpf_local_storage_map *smap, void *owner, u32 size);
	void (*map_local_storage_uncharge)(struct bpf_local_storage_map *smap, void *ownner, u32 size);
	struct bpf_local_storage __rcu ** (*map_owner_storage_ptr)(void *owner);

	/* Misc helpers. */
	int (*map_redirect)(struct bpf_map *map, u32 ifindex, u64 flags);

	/* map_meta_equal must be implemented for maps that can be
	 * used as an inner map. It is a runtime check to ensure
	 * an inner map can be inserted to an outer map.
	 *
	 * Some properties of the inner map has been used during the
	 * verification time. When inserting an inner map at the runtime,
	 * map_meta_equal has to ensure the inserting map has the same
	 * properties that the verifier has used earlier.
	 */
	bool (*map_meta_equal)(const struct bpf_map *meta0, const struct bpf_map *meta1);

	int (*map_set_for_each_callback_args)(struct bpf_verifier_env *env, struct bpf_func_state *caller, struct bpf_func_state *callee);
	int (*map_for_each_callback)(struct bpf_map *map, bpf_callback_t callback_fn, void *callback_ctx, u64 flags);


	/* BTF id of struct allocated by map_alloc */ 
	int *map_btf_id;

	/* bpf_iter info used to open a seq_file */
	const struct bpf_iter_seq_info *iter_seq_info;
};
```
`struct bpf_map_ops`의 필드는 대다수가 함수 포인트로 구성된것을 확인 할 수 있음.\
즉 `struct bpf_map_ops`는 interface적 성향을 가짐을 확인 할 수 있음.

## bpf_types.h
전처리 과정에서 `linux/bpf.h` 파일을 include하면서 `BPF_MAP_TYPE` 매크로가 정의된 상태로 `linux/bpf_types.h`를 호출 함.

**[bpf_types.h](https://elixir.bootlin.com/linux/v5.19/source/include/linux/bpf_types.h/#L83)**
```c
BPF_MAP_TYPE(BPF_MAP_TYPE_ARRAY, array_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_PERCPU_ARRAY, percpu_array_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_PROG_ARRAY, prog_array_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_PERF_EVENT_ARRAY, perf_event_array_map_ops)
#ifdef CONFIG_CGROUPS
BPF_MAP_TYPE(BPF_MAP_TYPE_CGROUP_ARRAY, cgroup_array_map_ops)
#endif
#ifdef CONFIG_CGROUP_BPF
BPF_MAP_TYPE(BPF_MAP_TYPE_CGROUP_STORAGE, cgroup_storage_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_PERCPU_CGROUP_STORAGE, cgroup_storage_map_ops)
#endif
BPF_MAP_TYPE(BPF_MAP_TYPE_HASH, htab_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_PERCPU_HASH, htab_percpu_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_LRU_HASH, htab_lru_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_LRU_PERCPU_HASH, htab_lru_percpu_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_LPM_TRIE, trie_map_ops)
#ifdef CONFIG_PERF_EVENTS
BPF_MAP_TYPE(BPF_MAP_TYPE_STACK_TRACE, stack_trace_map_ops)
#endif
BPF_MAP_TYPE(BPF_MAP_TYPE_ARRAY_OF_MAPS, array_of_maps_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_HASH_OF_MAPS, htab_of_maps_map_ops)
#ifdef CONFIG_BPF_LSM
BPF_MAP_TYPE(BPF_MAP_TYPE_INODE_STORAGE, inode_storage_map_ops)
#endif
BPF_MAP_TYPE(BPF_MAP_TYPE_TASK_STORAGE, task_storage_map_ops)
#ifdef CONFIG_NET
BPF_MAP_TYPE(BPF_MAP_TYPE_DEVMAP, dev_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_DEVMAP_HASH, dev_map_hash_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_SK_STORAGE, sk_storage_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_CPUMAP, cpu_map_ops)
#if defined(CONFIG_XDP_SOCKETS)
BPF_MAP_TYPE(BPF_MAP_TYPE_XSKMAP, xsk_map_ops)
#endif
#ifdef CONFIG_INET
BPF_MAP_TYPE(BPF_MAP_TYPE_SOCKMAP, sock_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_SOCKHASH, sock_hash_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_REUSEPORT_SOCKARRAY, reuseport_array_ops)
#endif
#endif
BPF_MAP_TYPE(BPF_MAP_TYPE_QUEUE, queue_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_STACK, stack_map_ops)
#if defined(CONFIG_BPF_JIT)
BPF_MAP_TYPE(BPF_MAP_TYPE_STRUCT_OPS, bpf_struct_ops_map_ops)
#endif
BPF_MAP_TYPE(BPF_MAP_TYPE_RINGBUF, ringbuf_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_BLOOM_FILTER, bloom_filter_map_ops)
```
`bpf_types.h` 헤더가 호출되면서 `bpf_map_ops`에 각각의 타입에 따른 함수를 주입함. \
실제 `maps`의 구현체들은 `/kernel/bpf/`, `/net/core/`, `net/xdp/` 하위에 존재함.

**example - BPF_MAP_TYPE_ARRAY**
>```c
>BTF_ID_LIST_SINGLE(array_map_btf_ids, struct, bpf_array)
>const struct bpf_map_ops array_map_ops = {
>	.map_meta_equal = array_map_meta_equal,
>	.map_alloc_check = array_map_alloc_check,
>	.map_alloc = array_map_alloc,
>	.map_free = array_map_free,
>	.map_get_next_key = array_map_get_next_key,
>	.map_release_uref = array_map_free_timers,
>	.map_lookup_elem = array_map_lookup_elem,
>	.map_update_elem = array_map_update_elem,
>	.map_delete_elem = array_map_delete_elem,
>	.map_gen_lookup = array_map_gen_lookup,
>	.map_direct_value_addr = array_map_direct_value_addr,
>	.map_direct_value_meta = array_map_direct_value_meta,
>	.map_mmap = array_map_mmap,
>	.map_seq_show_elem = array_map_seq_show_elem,
>	.map_check_btf = array_map_check_btf,
>	.map_lookup_batch = generic_map_lookup_batch,
>	.map_update_batch = generic_map_update_batch,
>	.map_set_for_each_callback_args = map_set_for_each_callback_args,
>	.map_for_each_callback = bpf_for_each_array_elem,
>	.map_btf_id = &array_map_btf_ids[0],
>	.iter_seq_info = &iter_seq_info,
>};
>```
>`BPF_MAP_TYPE_ARRAY`은 array_map_ops라는 변수명으로 생성됨.\
>`/kernel/bpf/arraymap.c`에서 정의되며 `bpf_maps_ops` 함수포인터에 실질 동작 함수를 주입함.\

각 map이 어떻게 동작하는지는 구현체를 통해 직접 확인 가능.