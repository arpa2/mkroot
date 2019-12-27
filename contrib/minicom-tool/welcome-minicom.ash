#!/bin/ash

MESSAGE="
Use the menu to access serial ports
and USB serial devices with Minicom
or the Qodem BBS client.

Minicom emulates a terminal window
with the usual +++ and AT attention
codes to access a modem on it, and
send it commands.  Menu entries that
say \"modem\" initialise for modem,
others give the raw interface.

Qodem is a bit of fun.  It can also
access servers over the Internet.

(Enter or click OK to close this.)
"

/usr/bin/dialog --msgbox "$MESSAGE" 20 40

#OLD# /usr/bin/dialog --msgbox "\nUse the menu to setup or update the\nModbus TCP service on a serial port.\n\nOpen any number of client sessions,\nletting Modbus TCP multiplex them.\n\nEnter lines of hexadecimal but no\nchecksums are used in Modbus TCP.\n\nWhile working you can trace the\nModbus TCP daemon log output.\n\n(Enter or click OK to close this.)" 19 40
