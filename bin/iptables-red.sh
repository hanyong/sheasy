#!/bin/bash

ACTION="${1?}"
shift

RULE=( OUTPUT -p tcp -j REDSOCKS )

setup() {
	(
	set -e
	iptables -t nat -N REDSOCKS 2>/dev/null || true
	iptables -t nat -F REDSOCKS
	iptables -t nat -A REDSOCKS -d 0.0.0.0/8,10.0.0.0/8,100.0.0.0/8,127.0.0.0/8,172.16.0.0/12,192.168.0.0/16,224.0.0.0/4,240.0.0.0/4 -j RETURN
	# socks5 server and other white list
	iptables -t nat -A REDSOCKS -d 47.88.103.233,45.32.95.209
	iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345
	# TODO: REDIRECT 与 DNAT 的区别?
	#iptables -t nat -A REDSOCKS -p tcp -j DNAT --to-destination 127.0.0.1:12345
	)
}

status() {
	local msg err
	# check and setup chain REDSOCKS
	# 0: exists, 1: not exists, other: other error
	msg="$(iptables -t nat -n -L REDSOCKS 2>&1)"
	err="${?}"
	case "${err}" in
		0)
			;;
		1)
			setup
			err="${?}"
			;;
		*)
			echo "${msg}"
			return "${err}"
	esac
	if ! [ "${err}" -eq 0 ] ; then
		# "1" meas status DISABLED, use other code for other error
		[ "${err}" -eq 1 ] && err=3
		return "${err}"
	fi

	iptables -t nat -C "${RULE[@]}"
	err="${?}"
	if [ "${err}" -eq 0 ] ; then
		echo "REDSOCKS is ENABLED"
	elif [ "${err}" -eq 1 ] ; then
		echo "REDSOCKS is DISABLED"
	fi
	return "${err}"
}

start() {
	local msg err
	msg="$(status 2>&1)"
	err="${?}"
	if [ "${err}" -eq 1 ] ; then
		iptables -t nat -A "${RULE[@]}"
		err="${?}"
		status 2>/dev/null
	else
		[ -n "${msg}" ] && echo "${msg}"
	fi
	return "${err}"
}

stop() {
	local err
	iptables -t nat -D "${RULE[@]}"
	err="${?}"
	[ "${err}" -eq 0 -o "${err}" -eq 1 ] && status 2>/dev/null
	return "${err}"
}

case "${ACTION}" in
	setup|status|start|stop)
		"${ACTION}"
		;;
	*)
		echo "Unknown action: ${ACTION}"
		exit 1
		;;
esac
