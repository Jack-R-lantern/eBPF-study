# iproute2

iproute2 는 라우팅, 네트워크 인터페이스, 터널, 트래픽 제어 및 네트워크 관련 장치 드라이버 를 포함 하여 Linux 커널 에서 네트워킹 의 다양한 측면을 제어하고 모니터링하기 위한 사용자 공간 유틸리티 모음입니다 .
| Legacy utility | Replacement Command | Note |
|----------------|---------------------|------|
|ifconfig| ip addr, ip link |Address and link configuration|
|route|ip route|Routing tables|
|arp|ip neigh|Neigbors|
|iptunnel|ip tunnel|Tunnels|
|nameif, ifrename|	ip link set name|	Rename network interfaces|
|ipmaddr|	ip maddr	|Multicast|
|netstat|	ss, ip route|	Show various networking statistics|
|brctl|	bridge|	Handle bridge addresses and devices|