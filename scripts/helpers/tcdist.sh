#!/opt/bin/bash
echo "Attempting tc cfg"
tc qdisc add dev wl0.1 root handle 11a3: htb default 1
tc class add dev wl0.1 parent 11a3: classid 11a3:1 htb rate 32000000.0kbit
tc class add dev wl0.1 parent 11a3: classid 11a3:2 htb rate 32000000.0Kbit ceil 32000000.0Kbit
tc qdisc add dev wl0.1 parent 11a3:2 handle 1223: netem delay 200.000000ms 20.000000ms distribution normal
tc filter add dev wl0.1 protocol ip parent 11a3: prio 2 u32 match ip dst 0.0.0.0/0 match ip src 0.0.0.0/0 match ip dport 1883 0xffff flowid 11a3:2

echo "success?"

exit 0;
