#!/bin/ash
#
# Review the Modbus TCP daemon log


tail -f 1000 /tmp/mbusd.log | less
