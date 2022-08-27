#include <stdio.h>
#include <bpf/libbpf.h>

/*
	libbpf가 정상적으로 설치됐다면 clang main.c -lbpf로 컴파일 가능
*/

int	main(void) {
	printf("version: %u.%u\n", libbpf_major_version(), libbpf_minor_version());
	printf("version: %s\n", libbpf_version_string());
}
