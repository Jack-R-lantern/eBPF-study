# eBPF environment

## bpftool
### libbfd
`Binary File Descriptor Library(BFD)`는 GNU Project이며, 다양한 형식의 개체 파일을 이식 가능한 조작을 위한 주요 메커니즘.\
`BFD`는 목적파일의 공통된 추상 뷰를 제공하는것으로 동작함.\
목적파일은 설명 정보가 포함된 헤더를 가지고 있음.\
헤더는 각각 이름과 속성을 가지는 섹션, 심볼 테이블, relocation 항목 등을 확인 가능.\
`BFD`의 주요 사용처는 `GNU Assembler`, `GNU Linker`, `GNU Binutils`, `GNU Debugger`이며 결과적으로 `BFD`는 별도로 배포되지 않음.\
대신 항상 `binutils`, `GDB`에 포함됨.

### disassembler-four-args

### libcap

### zlib

### clang-bpf-co-re
