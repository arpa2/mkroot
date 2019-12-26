#!/bin/ash

MESSAGE="
Welcome to the #Serial#Playground#

The Minicom menu is for serial port
adventures in text.  The Modbus menu
is for hexadecimal adventures, such
as with Modbus over RS-485.

You can create remote users under
\"File\" -> \"New remote user\"
and these can access TTYD at URL
http://this.server:7681/
as well as through SSH, with or
without MOSH, and with or without
the TWIN \"graphical\" interface.

(Enter or click OK to close this.)
"

/usr/bin/dialog --msgbox "$MESSAGE" 21 40

#OLD# /usr/bin/dialog --msgbox "\nUse the menu to setup or update the\nModbus TCP service on a serial port.\n\nOpen any number of client sessions,\nletting Modbus TCP multiplex them.\n\nEnter lines of hexadecimal but no\nchecksums are used in Modbus TCP.\n\nWhile working you can trace the\nModbus TCP daemon log output.\n\n(Enter or click OK to close this.)" 19 40
