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