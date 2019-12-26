#!/bin/ash
#
# Client to Modbus TCP on 127.0.0.1:502


killall -0 mbusd 2>/dev/null

if [ $? -ne 0 ]
then
	dialog --msgbox "\n Modbus TCP daemon is not running\n\n Please start it or check the log" 10 40
	exit 0
fi

#LIBRARIES# hexin | socat -x - tcp:127.0.0.1:502
/usr/local/bin/hexin | nc 127.0.0.1 502 | /usr/local/bin/hexout

