#!/bin/bash

ACTION="${1?}"
shift

NET="${1}" && shift || NET="192.168.0.0/16"
RULE=( POSTROUTING -s "${NET}" ! -d "${NET}" -j MASQUERADE )

start() {
	local error code
	error="$(status 2>&1 >/dev/null)"
	code="${?}"
	if [ "${code}" -eq 1 ] ; then
		iptables -t nat -A "${RULE[@]}"
	else
		echo "${error}" >&2
		return "${code}"
	fi
}

status() {
	iptables -t nat -C "${RULE[@]}"
	local code="${?}"
	if [ "${code}" -eq 0 ] ; then
		echo "NAT for ${NET} is ENABLED"
	elif [ "${code}" -eq 1 ] ; then
		echo "NAT for ${NET} is DISABLED"
	fi
	return "${code}"
}

stop() {
	iptables -t nat -D "${RULE[@]}"
}

case "${ACTION}" in
start|status|stop)
	"${ACTION}" "${@}"
	;;
*)
	echo "unkown action: ${ACTION}"
	exit 1
	;;
esac
