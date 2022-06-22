import re
import sys
import base64
import argparse
import logging
from functools import partial
from itertools import cycle, repeat
from threading import Thread
from time import sleep, time
import json
import os
import multiprocessing as mp
from datetime import datetime

from queue import Empty

import coloredlogs
from websocket import create_connection

import planetmint_benchmark

from .utils import ts

from . import utils, bdb


logger = logging.getLogger(__name__)

TRACKER = {}
CSV_WRITER = None
OUT_FILE = None
PENDING = True
START_TIME = 0
DURATION = 0
CHECKER = None


def run_send(args):
    global START_TIME
    global DURATION
    from bigchaindb_driver.crypto import generate_keypair
    from urllib.parse import urlparse

    ls = planetmint_benchmark.config["ls"]

    keypair = generate_keypair()

    BDB_ENDPOINT = args.peer[0]
    # WS_ENDPOINT = 'ws://{}:26657/websocket'.format(urlparse(BDB_ENDPOINT).hostname)
    WS_ENDPOINT = "ws://{}:9985/api/v1/streams/valid_transactions".format(
        urlparse(BDB_ENDPOINT).hostname
    )
    sent_transactions = []
    requests_queue = None
    time = args.time
    if time is not None:
        requests_queue = mp.Queue(maxsize=10000)
    else:
        requests_queue = mp.Queue(args.requests)
    results_queue = mp.Queue()
    start_time = datetime.now().timestamp()
    START_TIME = start_time
    DURATION = args.time
    logger.info("Connecting to WebSocket %s", WS_ENDPOINT)
    logger.info(f"TIME: {args.time} ")
    ws = create_connection(WS_ENDPOINT, timeout=5)

    def check_abort(duration, starttime):
        if bdb.get_timelft(duration, starttime) <= 0:
            return True
        else:
            return False

    def sample_queue(requests_queue, args):
        while True:
            ls["queue"] = requests_queue.qsize()
            sleep(1)
            if check_abort(args.time, args.starttime):
                exit(0)

    def ping(ws, args):
        global PENDING
        while PENDING:
            ws.ping()
            sleep(2)
            if check_abort(args.time, args.starttime):
                exit(0)

    def listen(ws, args):
        global PENDING
        global CHECKER
        while PENDING:
            if check_abort(args.time, args.starttime):

                PENDING = False
                exit(0)
            if time is not None and requests_queue.full() is False:
                requests_queue.maxsize = 1000
                if bdb.get_timelft(args.time, args.starttime) >= 0:
                    CHECKER = False
            if requests_queue.full() is False and time is None:
                CHECKER = False
            try:
                result = ws.recv()
            except:
                continue
            else:
                transaction_id = json.loads(result)["transaction_id"]
                if transaction_id in TRACKER:
                    TRACKER[transaction_id]["ts_commit"] = ts()
                    CSV_WRITER.writerow(TRACKER[transaction_id])
                    del TRACKER[transaction_id]
                    ls["commit"] += 1
                    ls["mempool"] = ls["accept"] - ls["commit"]
                if not TRACKER or check_abort(args.time, args.starttime):
                    ls()
                    OUT_FILE.flush()
                    PENDING = False
                    exit(0)

    args.starttime = datetime.now().timestamp()

    Thread(
        target=listen,
        args=(
            ws,
            args,
        ),
        daemon=False,
    ).start()
    Thread(
        target=ping,
        args=(
            ws,
            args,
        ),
        daemon=True,
    ).start()
    Thread(
        target=sample_queue,
        args=(
            requests_queue,
            args,
        ),
        daemon=True,
    ).start()

    print(f"PROCESSES: {args.processes}")
    logger.info("Start sending transactions to %s", BDB_ENDPOINT)
    for i in range(args.processes):
        mp.Process(target=bdb.worker_generate, args=(args, requests_queue)).start()

    print(f"started GENERATION state, queue size: {args.queuesize}")

    while not requests_queue.full():
        sleep(0.1)

    print(f"entering SENDING state")
    for i in range(args.processes):

        mp.Process(
            target=bdb.worker_send,
            args=(args, requests_queue, results_queue),
            daemon=True,
        ).start()
    global PENDING
    while PENDING:
        if check_abort(args.time, args.starttime):
            exit(0)
        try:
            peer, txid, size, ts_send, ts_accept, ts_error = results_queue.get(
                timeout=0.1
            )
        except Empty:
            continue
        except:
            continue
        TRACKER[txid] = {
            "txid": txid,
            "size": size,
            "ts_send": ts_send,
            "ts_accept": ts_accept,
            "ts_commit": None,
            "ts_error": ts_error,
        }

        if ts_accept:
            ls["accept"] += 1
            delta = ts_accept - ts_send
            status = "Success"
            ls["mempool"] = ls["accept"] - ls["commit"]
            CSV_WRITER.writerow(TRACKER[txid])
        else:
            ls["error"] += 1
            delta = ts_error - ts_send
            status = "Error"
            CSV_WRITER.writerow(TRACKER[txid])
            del TRACKER[txid]

        logger.debug("%s: %s to %s [%ims]", status, txid, peer, delta)
    exit(0)


def create_parser():
    parser = argparse.ArgumentParser(description="Benchmarking tools for Planetmint.")

    parser.add_argument("--csv", type=str, default="out.csv")

    parser.add_argument("-l", "--log-level", default="INFO")

    parser.add_argument(
        "-p",
        "--peer",
        action="append",
        help="Planetmint peer to use. This option can be " "used multiple times.",
    )

    parser.add_argument(
        "-a",
        "--auth",
        help="Set authentication tokens, " "format: <app_id>:<app_key>).",
    )

    parser.add_argument(
        "--processes",
        default=mp.cpu_count(),
        type=int,
        help="Number of processes to spawn.",
    )

    # all the commands are contained in the subparsers object,
    # the command selected by the user will be stored in `args.command`
    # that is used by the `main` function to select which other
    # function to call.
    subparsers = parser.add_subparsers(title="Commands", dest="command")

    send_parser = subparsers.add_parser(
        "send", help="Send a single create " "transaction from a random keypair"
    )

    send_parser.add_argument(
        "--size", "-s", help="Asset size in bytes", type=int, default=0
    )

    send_parser.add_argument(
        "--mode",
        "-m",
        help="Sending mode",
        choices=["sync", "async", "commit"],
        default="sync",
    )

    send_parser.add_argument(
        "--requests",
        "-r",
        help="Number of transactions to send to a peer.",
        type=int,
        default=1,
    )

    send_parser.add_argument(
        "--unconfirmed_tx_th",
        "-th",
        help="Threshold for number of unconfirmed transactions in tendermint mempool",
        type=int,
        default=5000,
    )

    send_parser.add_argument(
        "--queuesize",
        "-qs",
        help="The size of the message queue.",
        type=int,
        default=10000,
    )
    send_parser.add_argument(
        "--time", "-t", help="time based constraint", type=int, default=0
    )

    return parser


def configure(args):
    global CSV_WRITER
    global OUT_FILE
    coloredlogs.install(level=args.log_level, logger=logger)
    global CHECKER
    import csv

    if CHECKER is False:
        os._exit(0)
    OUT_FILE = open(args.csv, "w")

    CSV_WRITER = csv.DictWriter(
        OUT_FILE,
        # Might be useful to add 'operation' and 'size'
        fieldnames=["txid", "size", "ts_send", "ts_accept", "ts_commit", "ts_error"],
    )
    CSV_WRITER.writeheader()

    def emit(stats):
        global PENDING
        global DURATION
        global START_TIME
        if bdb.get_timelft(DURATION, START_TIME) <= 0:
            SystemExit()
        if not PENDING:
            exit(0)
        logger.info(
            "Processing transactions CONFIGDUDE, "
            "queue: %s (%s tx/s), accepted: %s (%s tx/s), committed %s (%s tx/s), errored %s (%s tx/s), mempool %s (%s tx/s)",
            stats["queue"],
            stats.get("queue.speed", 0),
            stats["accept"],
            stats.get("accept.speed", 0),
            stats["commit"],
            stats.get("commit.speed", 0),
            stats["error"],
            stats.get("error.speed", 0),
            stats["mempool"],
            stats.get("mempool.speed", 0),
        )

    import logstats

    ls = logstats.Logstats(emit_func=emit)
    ls["accept"] = 0
    ls["commit"] = 0
    ls["error"] = 0

    logstats.thread.start(ls)
    planetmint_benchmark.config = {"ls": ls}


def main():
    utils.start(create_parser(), sys.argv[1:], globals(), callback_before=configure)
