# eBPF Instruction Set

## Register and calling convention
eBPF는 10개의 범용 레지스터와 읽기 전용 프레임 포인터 레지스터가 있으며 모두 64비트 입니다.

### eBPF 호출 규약
* R0: 함수 호출에 대한 리턴 값, eBPF 프로그램에 대한 종료 값
* R1 ~ R5: 함수 호출에 대한 인수
* R6 ~ R9: 함수 호출이 보존할 호출 수신자 저장 레지스터
* R10: 스택에 접근하기 위한 읽기 전용 프레임 포인터

Ro ~ R5는 기본적인 레지스터이고 eBPF 프로그램은 호출 전반에 걸쳐 필요한 경우 레지스터를 비우거나 채울 필요가 있습니다.

## Instruction encoding
eBPF는 두 가지 명령어 인코딩을 가지고 있습니다.
* 기본 명령어 인코딩은, 64비트를 명령어 인코딩 하기 위해 사용합니다.
* 확장 명령어 인코딩은, 기본 명령어 뒤에 64비트 상수 값을 추가해 128bits로 확장합니다.

| 32bits (MSB) | 16bits |    4bits        | 4bits | 8 bits (LSB) |
|--------------|--------|-----------------|----------------------|--------------|
| immediate    | offset | source register | destination register | opcode |

### Instruction Classes
opcode의 최하위 3비트를 명령어 클래스를 저장하는데 사용합니다.

| class  | value | description                  | reference |
|--------|-------|------------------------------|-----------|
| BPF_LD | 0x00  | non-standard load operations | Load and store instructions |
| BPF_LDX | 0x01 | load into register operations | Load and store instructions |
| BPF_ST | 0x02 | store from immediate operations | Load and store instructions |
| BPF_STX | 0x03 | store from register operations | Load and store instructions |
| BPF_ALU | 0x04 | 32-bit arithmetric operations | Arithmetic and jump instructions |
| BPF_JMP | 0x05 | 64-bit jump operations | Arithmetic and jump instructions |
| BPF_JMP32 | 0x06 | 32-bit jump operations | Arithmetic and jump instructions
| BPF_ALU64 | 0x07 | 64-bit arithmetic operations | Arithmetic and jump instructions |

## Arithmetic and jump instructions
산술, 점프 명령어를 위해 `8-bit opcode`의 필드는 3 부분으로 나누어집니다.\
| 4  bits (MSB) | 1 bit  | 3 bits (LSB)      |
|---------------|--------|-------------------|
| operation code| source | instruction class |

LSB에서 부터 4번째 bit는 source 피연산자를 인코딩합니다.
| source | value | description                              |
|--------|-------|------------------------------------------|
| BPF_K  | 0x00  | use 32-bit immediate as source operand   |
| BPF_X  | 0x08  | use 'src_reg' register as source operand |

상위 4비트인 MSB는 명령어 코드를 저장합니다.

### Arithmetic instructions
`BPF_ALU`는 32-bit의 피연산자 크기를 사용하는 반면, `BPF_ALU64`는 64비트 와이드 피연산자를 사용합니다.\
명령어 코드 부분을 아래의 명령어로 인코딩합니다.
| code    | value | description |
|---------|-------|-------------|
| BPF_ADD | 0x00  | dst += src  |
| BPF_SUB | 0x10  | dst -= src  |
| BPF_MUL | 0x20  | dst *= src  |
| BPF_DIV | 0x30  | dst /= src  |
| BPF_OR  | 0x40  | dst |= src  |
| BPF_AND | 0x50  | dst &= src  |
| BPF_LSH | 0x60  | dst <<=src  |
| BPF_RSH | 0x70  | dst >>=src  |
| BPF_NEG | 0x80  | dst = ~src  |
| BPF_MOD | 0x90  | dst %= src  |
| BPF_XOR | 0xa0  | dst ^= src  |
| BPF_MOV | 0xb0  | dst = src   |
| BPF_ARSH| 0xc0  | sign extending shift right |
| BPF_END | 0xd0  | byte swap operations (see Byte swap instruction below)

### example
* **`BPF_ADD | BPF_X | BPF_ALU` 의미**
```shell
dst_reg = (u32) dst_reg + (u32) src_reg
```

* **`BPF_ADD | BPF_X | BPF_ALU64` 의미**
```shell
dst_reg = dst_reg + src_reg;
```

* **`BPF_XOR | BPF_K | BPF_ALU` 의미**
```shell
src_reg = (u32) src_reg ^ (u32) imm32
```

* **`BPF_ADD | BPF_X | BPF_ALU64` 의미**
```shell
src_reg = src_reg ^ imm32
```

### Byte swap instructions
byte 스왑 명령어는 `BPF_ALU` 명령어 클래스와, operation code의 4비트인 `BPF_END`를 사용합니다.\
byte 스왑 명령어는 오직 목적지 레스터에 대해서만 수행합니다. \
분리된 원천 레지스터, 또는 상수값에는 사용하지 말아야합니다. \
`opcode`의 `source`필드의 1비트를 바이트 정렬 규칙을 선택하는데 사용합니다.
| source    | value | description                                       |
|-----------|-------|---------------------------------------------------|
| BPF_TO_LE | 0x00  | convert between host byte order and little endian |
| BPF-TO_BE | 0x08  | convert between host byte order and big endian    |

`imm` 필드는 스왑 명령어의 폭으로 변환합니다. \
폭은 16, 32, 64를 지원합니다.

### Jump instructions
`instruction class`가 `BPF_JMP32`라면 32bit 피연산자를 사용합니다.\
`instruction class`가 `BPF_JMP`라면 64bit 피연산자를 사용합니다.\
`operation code` 부분은 아래의 명령에 따라 인코딩 됩니다.
| code     | value | description               | notes        |
|----------|-------|---------------------------|--------------|
| BPF_JA   | 0x00  | PC += off                 | BPF_JMP only |
| BPF_JEQ  | 0x10  | PC += off if dst == src   |              |
| BPF_JGT  | 0x20  | PC += off if dst > src    | unsigned     |
| BPF_JGE  | 0x30  | PC += off if dst >= src   | unsigned     |
| BPF_JSET | 0x40  | PC += off if dst & src    |              |
| BPF_JNE  | 0x50  | PC += off if dst != src   |              |
| BPF_JSGT | 0x60  | PC += off if dst > src    | signed       |
| BPF_JSGE | 0x70  | PC += off if dst >= src   | signed       |
| BPF_CALL | 0x80  | function call             |              |
| BPF_EXIT | 0x90  | function / program return | BPF_JMP only |
| BPF_JLT  | 0xa0  | PC += off if dst < src    | unsigned     |
| BPF_JLE  | 0xb0  | PC += off if dst <= src   | unsigned     |
| BPF_JSLT | 0xc0  | PC += off if dst < src    | signed       |
| BPF_JSLE | 0xd0  | PC += off if dst <= src   | signed       |
eBPF 프로그램은 BPF_EXIT를 수행하기 전에 반환 값을 레지스터 R0에 저장해야 합니다.

## Load and store instructions
`load`, `store` 명령어인 `BPF_LD`, `BPF_LDX`, `BPF_ST`, `BPF_STX`는 8 bit `opcode`를 아래와 같이 나눕니다.
| 3 bits (MSB) | 2 bits | 3 bits (LSB)      |
|--------------|--------|-------------------|
| mode         | size   | instruction class |

모드는 다음 중 하나로 정의됩니다.
| mode modifier | value | description |
|---------------|-------|-------------|
| BPF_IMM       | 0x00  | 64-bit immediate | 
| BPF_ABS       | 0x20  | legacy BPF packet access (absolute) |
| BPF_IND       | 0x40  | legacy BPF packet access (indirect) |
| BPF_MEM       | 0x60  | regular load and store operations   |
| BPF_ATOMIC    | 0xc0  | atomic operations |

사이즈는 다음중 하나로 정의됩니다.
| size modifier | value | description |
|---------------|-------|-------------|
| BPF_W         | 0x00  | word (4 bytes) |
| BPF_H         | 0x08  | half word (2 bytes) |
| BPF_B         | 0x10  | byte        |
| BPF_DW        | 0x18  | double word (8 bytes) |

## Regular load and store operations
`BPF_MEM` 모드는 레지스터와 메모리간의 데이터 이동을 위한 일반적인 `load`, `store`명령어로 인코딩 하기 위해 사용합니다.
### example
* **`BPF_MEM | <size> | BPF_STX` 의미**
```shell
*(size *) (dst_reg + off) = src_reg
```
* **`BPF_MEM | <size> | BPF_ST` 의미**
```shell
*(size *) (dst_reg + off) = imm32
```
* **`BPF_MEM | <size> | BPF_LDX` 의미**
```shell
dst_reg = *(size *) (src_reg + off)
```
### Atomic operations