# ftrace

## HAVE_FUNCTION_TRACER
`mcount`함수는 함수 포인터인 `ftrace_trace_function`이 `ftrace_stub`로 설정됐는지 확인해야 합니다. \
만일 `ftrace_trace_function`이 `ftrace_stub`로 설정됐다면 `mcount`함수는 아무것도 수행하지 않고 즉시 리턴됩니다. \
`ftrace_trace_function`이 `ftrace_stub`이외의 것으로 설정됐다면 `__mcount_internal`을 호출하는것과 동일한 방식으로 해당 함수를 호출합니다. \
`ftrace_trace_function`의 인자는 `__mcount_internal`처럼 `frompc`, `selfpc`입니다.

**pseudo code**
```c
void ftrace_stub(void) {
	return;
}

void mcount(void) {
	/* save any bare state needed in order to do initial checking */
	
	extern void (*ftrace_trace_function)(unsigned long, unsigned long);
	if (ftrace_trace_function != ftrace_stub)
		goto do_trace;
	
	/* restore any bare state */
	
	return;
	
	do_trace:
	/* save all state needed by the ABI(see paragraph above) */
	
	unsigned long frompc = ...;
	unsigned long selfpc = <return address> - MCOUNT_INSN_SIZE;
	ftrace_trace_function(frompc, selfpc);
	
	/* restore all state needed by the ABI */
}
```

## HAVE_SYSCALL_TRACEPOINTS
