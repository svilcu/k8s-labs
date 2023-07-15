# TO DO

- [ ] Mercury
- [x] Venus
- [x] Earth (Orbit/Moon)
- [x] Mars
- [ ] Jupiter
- [ ] Saturn
- [ ] Uranus
- [ ] Neptune
- [ ] Comet Haley


root@OpenWrt:/# uci show network
network.loopback=interface
network.loopback.device='lo'
network.loopback.proto='static'
network.loopback.ipaddr='127.0.0.1'
network.loopback.netmask='255.0.0.0'
network.globals=globals
network.@device[0]=device
network.@device[0].name='br-lan'
network.@device[0].type='bridge'
network.@device[0].ports='lan1' 'lan2' 'lan3' 'lan4' 'sfp2'
network.@device[0].ipv6='0'
network.lan=interface
network.lan.device='br-lan'
network.lan.proto='static'
network.lan.ipaddr='192.168.1.1'
network.lan.netmask='255.255.255.0'
network.lan.ipv6='off'
network.lan.delegate='0'
network.@device[1]=device
network.@device[1].name='br-wan'
network.@device[1].type='bridge'
network.@device[1].ports='eth1' 'wan'
network.@device[1].ipv6='0'
network.@device[2]=device
network.@device[2].name='eth1'
network.@device[2].macaddr='96:01:df:e5:33:75'
network.@device[2].ipv6='0'
network.@device[3]=device
network.@device[3].name='wan'
network.@device[3].macaddr='96:01:df:e5:33:75'
network.@device[3].ipv6='0'
network.wan=interface
network.wan.device='br-wan'
network.wan.proto='dhcp'
network.wan.ipv6='0'
