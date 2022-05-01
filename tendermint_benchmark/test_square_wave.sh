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
	printf "\n🤞 $(tput setaf 2)run benchmark$(tput sgr0) $1, $2, $3 $4, $5, $6, $7\n\n" >&2
	printf "high_time,low_time,cycles,requests,concurrency,type,logging,\n"
	printf "$1,$2,$3,$4,$5,$6,$7,\n"
	printf "avg(tx/s),stddev(tx/s),max(tx/s),avg(blocks/s),stddev(blocks/s),max(blocks/s),\n"
	./runtest_square_wave.sh $1 $2 $3 $4 $5 $6 $7 $8
	printf "\n"
}

banner

# Control: Reproducing our original result, to make sure everything still works
# 10s burst
run 10 1 1 1000 10 internal yes 1

# 30s burst
run 30 1 1 1000 10 internal yes 2

# 100s burst
run 100 1 1 1000 10 internal yes 3 

# 500s burst
run 500 1 1 1000 10 internal yes 4

# Varying pause length, 10s burst
run 10 1 10 1000 10 internal yes 5
run 10 2 10 1000 10 internal yes 6
run 10 5 10 1000 10 internal yes 7
run 10 10 10 1000 10 internal yes 8
run 10 20 10 1000 10 internal yes 9

# Varying pause length, 100s burst
run 100 1 10 1000 10 internal yes 10
run 100 2 10 1000 10 internal yes 11
run 100 5 10 1000 10 internal yes 12
run 100 10 10 1000 10 internal yes 13
run 100 20 10 1000 10 internal yes 14

# Varying number of cycles
run 100 100 1 1000 10 internal yes 15
run 50 50 2 1000 10 internal yes 16
run 20 20 5 1000 10 internal yes 17
run 10 10 10 1000 10 internal yes 18
run 5 5 20 1000 10 internal yes 19

# Low Tx rate
run 2 2 10 100 10 internal yes 20
run 2 2 10 100 10 internal yes 21
run 2 2 10 100 10 internal yes 22
run 2 2 10 100 10 internal yes 23
run 2 2 10 100 10 internal yes 24
run 2 2 10 100 10 internal yes 25
run 2 2 10 100 10 internal yes 26
run 2 2 10 100 10 internal yes 27

# High Tx rate
run 10 10 10 10000 10 internal yes 28
run 10 10 10 10000 10 internal yes 29
run 10 10 10 10000 10 internal yes 30
run 10 10 10 10000 10 internal yes 31
run 10 10 10 10000 10 internal yes 32
run 10 10 10 10000 10 internal yes 33
run 10 10 10 10000 10 internal yes 34
run 10 10 10 10000 10 internal yes 35