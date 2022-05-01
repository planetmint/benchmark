#!/bin/bash

banner () {
cat << EOF
$(tput setaf 7)
╺┳╸┏━╸┏┓╻╺┳┓┏━╸┏━┓┏┳┓╻┏┓╻╺┳╸
 ┃ ┣╸ ┃┗┫ ┃┃┣╸ ┣┳┛┃┃┃┃┃┗┫ ┃
 ╹ ┗━╸╹ ╹╺┻┛┗━╸╹┗╸╹ ╹╹╹ ╹ ╹ $(tput setaf 1)
           ┏┓ ╻  ┏━┓┏━┓╺┳╸┏━╸┏━┓
           ┣┻┓┃  ┣━┫┗━┓ ┃ ┣╸ ┣┳┛
           ┗━┛┗━╸╹ ╹┗━┛ ╹ ┗━╸╹┗╸$(tput setaf 3)
     ___________________    . , ; .
    (___________________|~~~~~X.;' .
                          ' \`' ' \`
$(tput sgr0)
EOF
} >&2

run () {
	printf "\n🤞 $(tput setaf 2)run benchmark$(tput sgr0) $1, $2, $3, $4, $5\n\n" >&2
	printf  "$1,$2,$3,$4,$5,$6,"
	./runtest.sh $1 $2 $3 $4 $5 $6 $7 | tail -n+2 | tr -s ' ' | cut -d ' ' -f 2-4 | tr '\n ' ',' | sed 's/.$//'
	printf "\n"
}

banner

printf "type,time,requests,concurrency,logging,mempool,avg(tx/s),stddev(tx/s),max(tx/s),avg(blocks/s),stddev(blocks/s),max(blocks/s)\n"

for mode in "internal"; do # "external"; do
	for logging in "yes"; do # "no"; do
		# Testing Performance Degradation at Low Load
  	run ${mode} 1 100 10 ${logging} 100000 1
 		run ${mode} 2 100 10 ${logging} 100000 2
 		run ${mode} 5 100 10 ${logging} 100000 3
 		run ${mode} 10 100 10 ${logging} 100000 4
 		run ${mode} 20 100 10 ${logging} 100000 5
 		run ${mode} 50 100 10 ${logging} 100000 6
 		run ${mode} 100 100 10 ${logging} 100000 7
 		run ${mode} 200 100 10 ${logging} 100000 8
 		run ${mode} 500 100 10 ${logging} 100000 9
 		run ${mode} 1000 100 10 ${logging} 100000 10
 		run ${mode} 2000 100 10 ${logging} 100000 11
 		run ${mode} 5000 100 10 ${logging} 100000 12
		# Testing Performance Degradation at High Load
		run ${mode} 1 10000 10 ${logging} 100000 13
 		run ${mode} 2 10000 10 ${logging} 100000 14
 		run ${mode} 5 10000 10 ${logging} 100000 15
 		run ${mode} 10 10000 10 ${logging} 100000 16
 		run ${mode} 20 10000 10 ${logging} 100000 17
 		run ${mode} 50 10000 10 ${logging} 100000 18
 		run ${mode} 100 10000 10 ${logging} 100000 19
 		run ${mode} 200 10000 10 ${logging} 100000 20
 		run ${mode} 500 10000 10 ${logging} 100000 21
 		run ${mode} 1000 10000 10 ${logging} 100000 22
 		run ${mode} 2000 10000 10 ${logging} 100000 23
 		run ${mode} 5000 10000 10 ${logging} 100000 24
		# Testing Performance Degradation Over Different Mempool Sizes
 		run ${mode} 1 1000 10 ${logging} 10 25
 		run ${mode} 2 1000 10 ${logging} 10 26
 		run ${mode} 5 1000 10 ${logging} 10 27
 		run ${mode} 10 1000 10 ${logging} 10 28
 		run ${mode} 20 1000 10 ${logging} 10 29
 		run ${mode} 50 1000 10 ${logging} 10 30
 		run ${mode} 100 1000 10 ${logging} 10 31
 		run ${mode} 200 1000 10 ${logging} 10 32
 		run ${mode} 500 1000 10 ${logging} 10 33
 		run ${mode} 1000 1000 10 ${logging} 10 34
 		run ${mode} 2000 1000 10 ${logging} 10 35
 		run ${mode} 5000 1000 10 ${logging} 10 36
   	run ${mode} 1 1000 10 ${logging} 1000 37
   	run ${mode} 2 1000 10 ${logging} 1000 38
   	run ${mode} 5 1000 10 ${logging} 1000 39
 		run ${mode} 10 1000 10 ${logging} 1000 40
 		run ${mode} 20 1000 10 ${logging} 1000 41 
 		run ${mode} 50 1000 10 ${logging} 1000 42
 		run ${mode} 100 1000 10 ${logging} 1000 43
 		run ${mode} 200 1000 10 ${logging} 1000 44
 		run ${mode} 500 1000 10 ${logging} 1000 45
 		run ${mode} 1000 1000 10 ${logging} 1000 46
 		run ${mode} 2000 1000 10 ${logging} 1000 47
 		run ${mode} 5000 1000 10 ${logging} 1000 48
		run ${mode} 1 1000 10 ${logging} 100000 49
		run ${mode} 2 1000 10 ${logging} 100000 50
		run ${mode} 5 1000 10 ${logging} 100000 51
		run ${mode} 10 1000 10 ${logging} 100000 52
		run ${mode} 20 1000 10 ${logging} 100000 53
		run ${mode} 50 1000 10 ${logging} 100000 54
 		run ${mode} 100 1000 10 ${logging} 100000 55
 		run ${mode} 200 1000 10 ${logging} 100000 56
 		run ${mode} 500 1000 10 ${logging} 100000 57
 		run ${mode} 1000 1000 10 ${logging} 100000 58
 		run ${mode} 2000 1000 10 ${logging} 100000 59
 		run ${mode} 5000 1000 10 ${logging} 100000 60
		run ${mode} 1 1000 10 ${logging} 1000000 61
		run ${mode} 2 1000 10 ${logging} 1000000 62
		run ${mode} 5 1000 10 ${logging} 1000000 63
 		run ${mode} 10 1000 10 ${logging} 1000000 64
 		run ${mode} 20 1000 10 ${logging} 1000000 65
 		run ${mode} 50 1000 10 ${logging} 1000000 66
 		run ${mode} 100 1000 10 ${logging} 1000000 67
 		run ${mode} 200 1000 10 ${logging} 1000000 68
 		run ${mode} 500 1000 10 ${logging} 1000000 69
 		run ${mode} 1000 1000 10 ${logging} 1000000 70
 		run ${mode} 2000 1000 10 ${logging} 1000000 71
 		run ${mode} 5000 1000 10 ${logging} 1000000 72
	done
done
