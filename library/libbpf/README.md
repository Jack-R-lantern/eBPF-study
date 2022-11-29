 # libbpf

 ## API naming convention

 ## System call wrappers
 > System call wrappers는 `sys_bpf` 시스템 콜의 지원을 받는 명령어를 위한 단순한 wrappers임.\
 > wrappers들은 `bpf.h` 헤더파일에 위치해야함, 해당되는 명령어와 1:1로 맵핑함.\
 
## Objects
> libbpf API에서 제공하는 또 다른 클래스는 `Objects`와 그것과 동작하는 함수임.\
> 오브젝트들은 `BPF program`, `BPF map`에 대한 높은 추상수준을 제공함.\
> 오브젝트들은 `bpf_object`, `bpf_program`, `bpf_map`과 같은 구조체에 대응해 나타냄.\
> 이 오브젝트들은 `BPF programs`로 컴파일되고 포함된 `ELF object`와 대응됨. \
> 오브젝트들과 동작하는 함수는 오브젝트의 이름과, 함수의 목적을 설명과 더블 언더스코어로 구성됨.
> * **example**
>>```
>> object name: bpf_object
>> purpose describe: open
>>
>> result: bpf_object__open
>>```
> 모든 오브젝트와 그에 대응하는 함수중 `BTF`와 관련된 것들을 제외한 것들은 `libbpf.h`에 위치해야함.\
> `BTF`와 관련된 것들은 `btf.h`로 가야함.
>### bpf_object
>`libbpf.c`에 정의되어 있음.
>```c
>struct bpf_object {
>	char name[BPF_OBJ_NAME_LEN];
>	char license[64];
>	__u32 kern_version;
>
>	struct bpf_program *programs;
>	size_t nr_programs;
>	struct bpf_map *maps;
>	size_t nr_maps;
>	size_t maps_cap;
>
>	char *kconfig;
>	struct extern_desc *externs;
>	int nr_extern;
>	int kconfig_map_idx;
>
>	bool loaded;
>	bool has_subcalls;
>	bool has_rodata;
>
>	struct bpf_gen *gen_loader;
>
>	/* Information when doing ELF related work. Only valid if efile.elf is not NULL */
>	struct elf_state efile;
>
>	struct btf *btf;
>	struct btf_ext *btf_ext;
>	
>	/* Parse and load BTF vmlinux if any of the programs in the object need
>	 * It at load time.
>      */
>	struct btf *btf_vmlinux;
>	/* Path to the custom BTF to be used for BPF CO-RE relocations as an
>	 * override for vmlinux BTF
>	 */
>	char *btf_custom_path;
>	/* vmlinux BTF override for CO-RE relocations */
>	struct btf *btf_vmlinux_override;
>	/* Lazily initialized kernel module BTFs */
>	struct module_btf *btf_modules;
>	bool btf_modules_loaded;
>	size_t btf_module_cnt;
>	size_t btf_module_cap;
>
>	/* optional log settings passed to BPF_BTF_LOAD and BPF_PROG_LOAD commands */
>	char *log_buf;
>	size_t log_size;
>	__u32 log_level;
>
>	int *fd_array;
>	size_t fd_array_cap;
>	size_t fd_array_cnt;
>
>	struct usdt_manager *usdt_man;
>	char path[];
>}
>```
> ### bpf_program
>`libbpf.c`에 정의되어 있음.
>```c
>struct bpf_program {
>	char *name;
>	char *sec_name;
>	size_t sec_idx;
>	const struct bpf_sec_def *sec_def;
>	/* this program's instruction offset (in number of instructions)
>	 * within its containing ELF section
>	 */
>	size_t sec_insn_off;
>	/* number of original instruction in ELF section belonging to this
>	 * program, not taking into account subprogram instructions possible
>	 * appended later during relocation
>	 */
>	size_t set_insn_cnt;
>	/* Offset (in number of instructions) of the start of instruction
>	 * belonging to this BPF program within its containing main BPF program.
>	 * For the entry-point (main) BPF program, this is always zero.
>	 * For a sub-program, this gets reset before each of main BPF
>	 * programs are processed and relocated and is used to determined
>	 * whether sub-program was already appended to the main program, and 
>	 * if yes, at which instruction offset.
>	 */
>	size_t sub_insn_off;
>	
>	/* instructions that belong to BPF program; insns[0] is located at
>	 * sec_insn_off instruction within its ELF section in ELF file, so
>	 * when mapping ELF file instruction index to the local instruction,
>	 * one needs to subtract sec_insn_off; and vice versa.
>	 */
>	struct bpf_insn *insns;
>	/* actual number of instruction in this BPF program's image;
>	 * for entry-point BPF programs this includes the size of main program
>	 * itself plus all the used sub-programs, appended at the end
>	 */
>	size_t insns_cnt;
>
>	struct reloc_desc *reloc_desc;
>	int nr_reloc;
>	
>	/* BPF verifier log settings */
>	char *log_buf;
>	size_t log_size;
>	__u32 log_level;
>
>	struct bpf_object *obj;
>
>	int fd;
>	bool autoload;
>	bool autoattach;
>	bool mark_btf_static;
>	enum bpf_prog_type type;
>	enum bpf_attach_type expected_attach_type;
>
>	int prog_ifindex;
>	__u32 attach_btf_obj_fd;
>	__u32 attach_btf_id;
>	__u32 attach_prog_fd;
>
>	void *func_info;
>	__u32 func_info_rec_size;
>	__u32 func_info_cnt;
>
>	void *line_info;
>	__u32 line_info_rec_size;
>	__u32 line_info_cnt;
>	__u32 prog_flags;
>}
>```
> ### bpf_map
>`libbpf.c`에 정의되어 있음.
>```c
>struct bpf_map {
>	struct bpf_object *obj;
>	char *name;
>	/* real_name is defined for special internal maps (.rodata*,
>	 * .data*, .bss, .kconfig) and preserves their original ELF section
>	 * name. This is important to be able to find corresponding BTF
>	 * DATASEC information.
>	 */
>	char *real_name,
>	int fd;
>	int sec_idx;
>	size_t sec_offset;
>	int map_ifindex;
>	int inner_map_fd;
>	struct bpf_map_def def;
>	__u32 numa_node;
>	__u32 btf_var_idx;
>	__u32 btf_key_type_id;
>	__u32 btf_value_type_id;
>	__u32 btf_vmlinux_value_type_id;
>	enum libbpf_map_type libbpf_type;
>	void *mmaped;
>	struct bpf_struct_ops *st_ops;
>	struct bpf_map *inner_map;
>	void **init_slots;
>	int init_slots_sz;
>	char *pin_path;
>	bool pinned;
>	bool reused;
>	bool autocreate;
>	__u64 map_extra;
>}
>```
 ## Auxiliary functions