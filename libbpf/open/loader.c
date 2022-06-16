#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <bpf/libbpf.h>
#define DEBUGFS "/sys/kernel/debug/tracing/"

void	read_trace_pipe() {
	int trace_fd = open(DEBUGFS"trace_pip", O_RDONLY, 0);
	if (trace_fd < 0)
		return;

	while(1) {
		static char buf[4096];
		ssize_t sz;

		sz = read(trace_fd, buf, sizeof(buf) - 1);
		if (sz > 0) {
                    buf[sz] = 0;
                    puts(buf);
            }
	}
}

int	main(void) {
	struct bpf_object *obj;
	struct bpf_program *prog;
	struct bpf_link *link;
	int	err;

	libbpf_set_strict_mode(LIBBPF_STRICT_DIRECT_ERRS | LIBBPF_STRICT_CLEAN_PTRS);

	obj = bpf_object__open("./bpf_program.o");
	err = bpf_object__load(obj);
	if (err < 0) {
		perror("load failed: ");
	}
	else {
		printf("Load Success\n");
	}
	prog = bpf_object__find_program_by_name(obj, "bpf_prog"); 
	if (prog == NULL) {
		printf("program find failed\n");
	}
	else {
		printf("program find success\n");
	}
	printf("program name : %s\n", bpf_program__name(prog));
	return 0;
}
