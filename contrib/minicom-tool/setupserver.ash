#!/bin/ash
#
# Setup the serial port(s) to use


#
# Determine the serial device
#

MENU=
for KIND in S USB
do
	case $KIND in
	S)
		KINDSTR='RS-232/485_serial_port'
		;;
	USB)
		KINDSTR='USB_serial_port'
		;;
	esac
	for ITEM in 0 1 2 3
	do
		case $ITEM in
		0)
			ITEMSTR='First'
			;;
		1)
			ITEMSTR='Second'
			;;
		2)
			ITEMSTR='Third'
			;;
		3)
			ITEMSTR='Fourth'
			;;
		esac
		if [ -w "/dev/tty$KIND$ITEM" ]
		then
			MENU="${MENU:+$MENU }tty$KIND$ITEM $ITEMSTR_$KINDSTR"
		fi
	done
done

if [ -z "$MENU" ]
then
	dialog --msgbox "\n No serial ports detected in\n\n - /dev/ttyS0..ttyS3\n - /dev/ttyUSB0..ttyUSB3" 10 40
	exit 0
fi

dialog --output-fd 4 --menu 'What serial port to use?' 20 50 15 $MENU 4>/tmp/port

PORT=$(cat /tmp/port)
DEVICE="/dev/$PORT"


#
# Then select a speed (and 8N1)
#

MENU=
for SPD in 1200 2400 4800 9600 115200 
do
	MENU="${MENU:+$MENU }${SPD} ${SPD}_baud_or_bps_8N1"
done

dialog --output-fd 5 --menu 'What speed and format to use?' 20 50 15 $MENU 5> /tmp/speed
echo 8N1 > /tmp/mode

SPEED=$(cat /tmp/speed)
MODE=$(cat /tmp/mode)


#
# Decide about direction control
#

dialog --output-fd 6 --menu 'What direction control to use?' 20 50 15 default 'Default mechanism' rts-controlled 'Through RS-232 pin RTS' sysfs-xmit 'Through sysfs, active transmit' sysfs-recv 'Through sysfs, active receive' 6>/tmp/dirctl

case $(cat /tmp/dirctl) in
default)
	DIRCTL=
	;;
rts-controlled)
	DIRCTL='-t'
	;;
sysfs-xmit)
	DIRCTL='-y transmit'
	;;
sysfs-recv)
	DIRCTL='-Y receive'
	;;
esac


#
# Process settings with a restart of mbusd
#

killall -0 mbusd 2>/dev/null
if [ $? -eq 0 ]
then
	killall mbusd
fi
killall hexin 2>/dev/null

/usr/bin/mbusd -p "$DEVICE" -s "$SPEED" -m "$MODE" -A 127.0.0.1 -v 5 -L /tmp/mbusd.log $DIRCTL
ERROR=$?


#
# Report any error
#

if [ $ERROR -ne 0 ]
then
	dialog --msgbox "\n Modbus TCP daemon exited with $ERROR\n\n Please check the log for details" 10 40
fi
