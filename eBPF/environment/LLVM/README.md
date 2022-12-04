# LLVM

## Basic Commands
### llc(LLVM static compiler)
`llc` 명령어는 LLVM 소스 입력을 특정 아키텍처를 위한 어셈블리 코드로 컴파일.\
어셈블리 코드는 특정 아키텍처에서 실행파일을 생성하기 위해 특정 아키텍처의 어셈블러와 링커로 전달.

### llvm-dis(LLVM disassembler)
`llvm-dis` 명령어는 LLVM 디스어셈블러.\
llvm-dis는 LLVM bitcode 파일을 받아서 사람이 읽을 수 있는 LLVM 어셈블리 코드로 변경.\
파일 이름이 생략되거나 `-`로 정해지면, `llvm-dis`는 표준 입력으로 부터 읽어들임.\
표준 입력으로부터 읽어들이면 `llvm-dis`는 기본적으로 결과를 표준출력으로 내보냄.\
그 외에는 결과를 입력파일의 이름에 접미어 `.ll`을 더해 기록함.

## GNU binutils replacements
### llvm-strip
`llvm-strip`은 object file로 부터 section과 symbols를 제거하는 도구.\
특별한 제거 옵션이 지정되지 않는 경우 기본적으로 `--strip-all`옵션이 활성화 됨.\

### llvm-objcopy
### llvm-readelf