#!/opt/bin/bash
## List: https://wiki.openwrt.org/doc/howto/ddns.client#detecting_local_ip
YOURIPIS=$(wget -O - -q http://myip.dnsomatic.com/)

case "$1" in
  "-v") echo "According to outside world, you are: $YOURIPIS";;
  *) echo "$YOURIPIS";;
esac

exit 0;
