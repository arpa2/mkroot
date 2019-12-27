#!/bin/ash

case "$1" in

deconfig)
	ifconfig $interface 0.0.0.0
	ifconfig $interface up
	route del default
	;;

bound|renew)
	ifconfig $interface $ip $subnet ttl $ipttl mtu $mtu
	(
		echo domain $domain
		echo search $domain
		for ns in $dns $namesvr
		do
			echo nameserver $ns
		done
	) > /etc/resolv.conf
	ip route add default via $router dev $interface
	;;

nak)
	;;

esac
