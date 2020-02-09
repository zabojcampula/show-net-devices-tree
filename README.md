# show-net-devices-tree
A simple bash script showing hierarchy of networking devices.

The script is inspired by the question at stackexchange
http://unix.stackexchange.com/questions/328754.

The goal is to show network adapters in a tree to where the dependecy
between particular adapters are clearly visible. The script just calls
'ip link', parse the result and adapters with a link to a master shows
in tree under the master.

The hierarchy tree can be show from bottom up or from top to bottom.

Example:

```
$ ./nettree.sh -u
eth3
    bond1
       bond0
eth2
    bond0
eth1
    bond0
eth0
lupen3
    bond1
       bond0
lo
lxcbr0
virbr0
veth6404e35
    docker0

$ ./nettree.sh -d
docker0
    veth6404e35
eth0
lo
bond0
    eth1
    eth2
    bond1
       eth3
       lupen3
lxcbr0
virbr0
```
