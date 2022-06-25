# kprobes (kernel probes)

## Concepts: Kprobes and Kretprobes
`Kprobes`는 사용자가 어떤 커널 루틴에 동적으로 침입하는것과 디버깅과 퍼포먼스 정보 수집을 방해 없이 수집 할 수 있습니다. \
 사용자는 거의 모든 커널 주소를 trap 할 수 있으며, 중단점에 도달했을때 특정 핸들러 루틴을 호출 할 수 있습니다.

### kprobe
`kprobe`는 거의 모든 커널 함수에 삽입 할 수 있습니다.
### kretprobe
`kretporbe`는 특정 함수의 리턴에서 수행됩니다.

일반적인 경우, `Kprobes`기반 계측은 커널 모듈로 패키징 됩니다. \
모듈의 `init` 함수는 하나, 혹은 그 이상의 probe를 설치합니다. \
모듈의 `exit` 한수는 설치된 프로브를 제거합니다.

### How Does a Kprobe Work?
`kprobe`가 등록되면 `Kprobes`는 조사한 명령어를 복사하고 조사한 명령어의 첫번째 바이트를 `breakpoint`(e.g., int3 on i386 and x86_64) 명령어로 변경합니다. \
 CPU가 중단점 명령어에 도달하면 트랩이 발생하고 CPU의 레지스터가 저장되며 `notifier_call_chain` 메커니즘을 통해 제어가 `Kprobes`에 전달됩니다. \
`Kprobes`는 `kprobe`와 관련된 `pre_handler`를 실행하여 `kprobe` 구조체의 핸들러 주소와 저장된 레지스터를 전달합니다.