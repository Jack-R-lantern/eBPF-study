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

## Macro
> `include/linux/tracepoint.h`에서 `TRACE_EVENT`에 대한 정의를 확인 할 수 있음.\
> `TRACE_EVENT` -> `DECLARE_TRACE` -> `__DECLARE_TRACE`
> 
> ### TRACE_EVENT
>> ```c
>>#define TRACE_EVENT(name, proto, args, struct, assign, print) \
>>		DECLARE_TRACE(name, PARAMS(proto), PARAMS(args), PARAMS(cond))
>> ```
> ### DECLARE_TRACE
>>```c
>>#define DECLARE_TRACE(name, proto, args) \
>>		__DECLARE_TRACE(name, PARAMS(proto), PARAMS(args), \
>>						cpu_online(raw_smp_processor_id()), \
>>						PARAMS(void *__data, proto))
>>```
> ### __DECLARE_TRACE
> **TRACEPOINTS_ENABLED**
>> ```c
>>#define __DECLARE_TRACE(name proto, args, cond, data_proto) \
>>		extern int __traceiter_##name(data_proto); \
>>		DECLARE_STATIC_CALL(tp_func_##name, __traceiter_##name); \
>>		extern struct tracepoint __tracepoint_##name; \
>>		static inline void trace_##name(proto) \
>>		{
>>			if (static_key_false(&__tracepoint_##name.key)) \
>>					__DO_TRACE(name, TP_ARGS(args), TP_CONDITION(cond), 0);
>>			if (IS_ENABLED(CONFIG_LOCKDEP) && (cond)) {
>>					rcu_read_lock_sched_notrace(); \
>>					rcu_dereference_sched(__tracepoint_##name.funcs); \	
>>					rcu_read_unlock_sched_notrace(); \
>>			} \
>>		}\
>>		__DECLARE_TRACE_RCU(name, PARAMS(proto), PARAMS(args), PARAMS(cond)) \
>>		static inline int \
>>		register_trace_##name(void (*probe)(data_proto), void *data) \
>>		{ \
>>			return tracepoint_probe_register(&__tracepoint_##name, (void *)probe, data); \
>>		}\
>>		static inline int \
>>		register_trace_prio_##name(void (*probe)(data_proto), void *data, int prio) \
>>		{\
>>			return tracepoint_probe_register_prio(&__tracepoint_##name, (void *)probe, data, prio); \
>>		}\
>>		static inline int \
>>		unregister_trace_##name(void (*probe)(data_proto), void *data) \
>>		{\
>>			return tracepoint_probe_unregister(&__tracepoint_##name, (void *)probe, data); \
>>		}\
>>		static inline void\
>>		check_trace_callback_type_##name(void (*cb)(data_proto))\
>>		{\
>>		}\
>>		static inline bool \
>>		trace_##name##_enabled(void) \
>>		{\
>>			return static_key_false(&__tracepoint_##name.key)\
>>		}
>> ```
> **!TRACEPOINTS_ENABLED**
>> ```c
>>#define __DECLARE_TRACE(name, proto, args, cond, data_proto) \
>>		static inline void trace_##name(proto) \
>>		{ } \
>>		static inline void trace_##name##_rcuidle(proto) \
>>		{ } \
>>		static inline int \
>>		register_trace_##name(void (*probe)(data_proto), void *data)\
>>		{\
>>			return -ENOSYS;
>>		}\
>>		static inline int \
>>		unregister_trace_##name(void (*probe)(data_proto), void *data)\
>>		{\
>>			return -ENOSYS;
>>		}\
>>		static inline void check_trace_callback_type_##name(void (*cb)(data_proto)) \
>>		{\
>>		}\
>>		static inline bool \
>>		trace_##name_enabled(void)
>>		{\
>>			return false;\
>>		}\
>> ```