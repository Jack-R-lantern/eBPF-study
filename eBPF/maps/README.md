# eBPF maps
`maps`은 커널과 유저영역 사이의 데이터 공유를 위한 다양한 타입의 범용 저장소.\
`maps`은 `BPF` syscall을 통해 유저영역에서 접근함.

## map attribute
* type
* max number of elements
* key size in bytes
* value size in bytes

## [map types](./MapType.md)
> 구체적 type은 별도로 정리

## commands
### create
```c
/*	
	type, attributes를 이용해 map 생성 
	
	사용하는 속성
		attr->map_type
		attr->key_size
		attr->value_size
		attr->max_entries

	성공 시 : process-local file descriptor
	실패 시 : negative error
*/
map_fd = bpf(BPF_MAP_CREATE, union bpf_attr *attr, u32 size);
```
### update
```c
/*
	map에 key/value pair를 새로 만들거나 업데이트

	사용하는 속성
		attr->map_fd
		attr->key
		attr->value

	성공 시 : zero
	실패 시 : negative error
*/
err = bpf(BPF_MAP_UPDATE_ELEM, union bpf_attr *attr, u32 size);
```
### lookup
```c
/*
	map에서 key를 이용해 요소 검색

	사용하는 속성
		attr->map_fd
		attr->key
		attr->value

	성공 시 : 0을 리턴 key가 있는 경우 attr->value에 요소를 저장
	실패 시 : negatvice error
*/
err = bpf(BPF_MAP_LOOKUP_ELEM, union bpf_attr *attr, u32 size);
```
### delete 
```c
/*
	map에서 key를 이용해 요소 삭제

	사용하는 속성
		attr->map_fd
		attr->key
*/
err = bpf(BPF_MAP_DELETE_ELEM, union bpf_attr *attr, u32 size);
```