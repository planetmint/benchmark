#!/bin/bash

export TMHOME=.tendermint


init_tendermint () {
	rm -rf ~/${TMHOME}/*
	tendermint init full 	1>&2
}

run_benchmark () {
	while : ; do
		tm-load-test -T $1 -r $4 -c $5 -s 250 -N 200 --endpoints ws://localhost:22657/websocket -v --broadcast-tx-method async --min-peer-connectivity 1 --expect-peers 1 --stats-output /home/ubuntu/tests/prp6/results_test/results_${8}.csv
	 	if [ $? -eq 0 ]; then
			break
		fi
		BENCH_PID=$!
		sleep $2
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


if [ "$7" == "no" ];
then
	LOGGING=*:error
else
	LOGGING=main:info,state:info,*:error
fi

square_wave () {
	run_benchmark $1 $2 $3 $4 $5 $6 $7 $8
	sleep $2
}

case "$6" in
	internal)
		init_tendermint
		run_internal ${LOGGING}
		for i in $(seq 1 $3); do square_wave $1 $2 $3 $4 $5 $6 ${LOGGING} $8  | tail -f -n+2 | tr -s ' ' | cut -d ' ' -f 2-4 | tr ' ' ',' | tr '\n' ',' | sed 's/.$//' ; echo ',' ; done
		kill ${TM_PID}
		;;
	external)
		init_tendermint
		run_external ${LOGGING}
		for i in $(seq 1 $3); do square_wave $1 $2 $3 $4 $5 $6 ${LOGGING} $8 | tail -f -n+2 | tr -s ' ' | cut -d ' ' -f 2-4 | tr ' ' ',' | tr '\n' ',' | sed 's/.$//' ; echo ',' ; done
		kill ${TM_PID} ${ABCI_PID}
		;;
	*)
		echo $"Usage: $0 <high_time> <low_time> <cycles> <requests> <connections> {internal|external} <logging>"
		exit 1
esac
