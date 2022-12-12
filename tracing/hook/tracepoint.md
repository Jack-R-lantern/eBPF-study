# Tracepoint

## Purpose of tracepoints
> `tracepoint`는 코드에 위치하여 런타임때 사용자가 제공한 함수를 호출 할 수 있는 `hook`을 제공함.\
> `tracepoint`는 "on", "off"일 수 있음.
>
> **off**
>> `tracepoint`가 "off"이면 약간의 시간 손해(분기 확인 상태), 공간 손해(계측된 함수의 끝에 함수 호출을 위해 몇 바이트를 추가하고, 별도의 섹션에 데이터 구조를 추가)을 제외하고는 아무 효과가 없음.
>
> **on**
>> `tracepoint`가 "on"이면 `tracepoint`가 실행될 때마다, 사용자가 제공한 함수를 호출 할 수 있음.\
>> 사용자가 제공한 함수가 실행을 종료하면 `tracepoint` 다음 코드가 실행됨.\
>> 기존의 kernel context로 다시 되돌아 간다고 보면 됨.

## Usage
> `tracepoint`는 두 가지 요소가 필요.
> * 헤더파일에 위치한 `tracepoint` 정의
> * C code에 존재하는 `tracepoint statement`
>
> `tracepoint`를 사용하기 위해서 반드시 `linux/tracepoint.h`를 포함해야 함.
>
> ### example
> * **include/trace/events/subsys.h**
>>```c
>>#undef TRACE_SYSTEM
>>#define TRACE_SYSTEM subsys
>>
>>#if !defined(_TRACE_SUBSYS_H) || defined(TRACE_HEADER_NULTI_READ)
>>#define _TRACE_SUBSYS_H
>>
>>#include <linux/tracepoint.h>
>>
>>DEClARE_TRACE(subsys_eventname,
>>		  TP_PROTO(int firstarg, struct task_struct *p),
>>		  TP_ARGS(firstarg, p));
>>
>>#endif /* _TRACE_SUBSYS_H */
>>#include <trace/define_trace.h>
>>```
> * **subsys/file.c**
>>```c
>>#include <trace/events/subsys.h>
>>
>>#define CREATE_TRACE_POINTS
>>DEFINE_TRACE(subsys_eventname);
>>
>>void somefct(void)
>>{
>>	...
>>	trace_subsys_eventname(arg, task);
>>	...
>>}
>>```