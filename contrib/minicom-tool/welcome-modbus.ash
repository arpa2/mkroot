#!/bin/ash

MESSAGE="
Use the menu to setup or update the
Modbus TCP service on a serial port.

Open any number of client sessions,
letting Modbus TCP multiplex them.

Enter lines of hexadecimal but no
checksums are used in Modbus TCP.

While working you can trace the
Modbus TCP daemon log output.

(Enter or click OK to close this.)
"

/usr/bin/dialog --msgbox "$MESSAGE" 19 40

#OLD# /usr/bin/dialog --msgbox "\nUse the menu to setup or update the\nModbus TCP service on a serial port.\n\nOpen any number of client sessions,\nletting Modbus TCP multiplex them.\n\nEnter lines of hexadecimal but no\nchecksums are used in Modbus TCP.\n\nWhile working you can trace the\nModbus TCP daemon log output.\n\n(Enter or click OK to close this.)" 19 40
