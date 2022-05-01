#!/bin/bash

export TMHOME=.tendermint


init_tendermint () {
	rm -rf ~/${TMHOME}/*
	tendermint init full 1>&2
}

run_benchmark () {
	while : ; do
		tm-load-test -T $2 -r $3 -c $4 -s 250 -N 200 --endpoints ws://localhost:22657/websocket -v --min-peer-connectivity 1 --expect-peers 1 --stats-output /home/ubuntu/tests/prp6/results_test2/results_${7}.csv
	 	if [ $? -eq 0 ]; then
			break
		fi
		BENCH_PID=$!
		sleep 0.5
	done
}

run_internal () {
	tendermint node --proxy_app=kvstore --log_level="$1" 1>&2 &
	TM_PID=$!
}

run_external () {
	tendermint node --log_level="$1" 1>&2 &
	TM_PID=$!
	abci-cli kvstore 1>&2 &
	ABCI_PID=$!
}


if [ "$5" == "no" ];
then
	LOGGING=*:error
else
	LOGGING=main:info,state:info,*:error
fi

case "$1" in
	internal)
		init_tendermint
		sed -i "s/^size = 100000/size = $6/" ~/${TMHOME}/config/config.toml
		run_internal ${LOGGING}
		run_benchmark $1 $2 $3 $4 $5 ${LOGGING} $7
		kill ${TM_PID}
		;;

	external)
		init_tendermint
		sed -i "s/^size = 100000/size = $6/" ~/${TMHOME}/config/config.toml
		run_external ${LOGGING}
		run_benchmark $1 $2 $3 $4 $5 ${LOGGING} $7
		kill ${TM_PID} ${ABCI_PID}
		;;
	*)
		echo $"Usage: $0 {internal|external} <time> <requests> <concurrency> <logging>"
		exit 1
esac
