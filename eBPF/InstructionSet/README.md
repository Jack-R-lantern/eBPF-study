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