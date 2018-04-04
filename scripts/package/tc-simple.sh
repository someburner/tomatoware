#!/opt/bin/bash
CMD='tc qdisc add dev wl0.1 root netem delay 100ms'
echo 'Executing $CMD'
eval $CMD;


exit 0;
