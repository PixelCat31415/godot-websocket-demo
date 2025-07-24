import math
import time
import struct
import asyncio
import websockets
from websockets.asyncio.client import connect

def var_to_bytes(*args):
    res = bytearray()
    res += struct.pack("i", 28)  # type of gdscript arrays
    res += struct.pack("i", len(args))
    for i in args:
        if i is None:
            res += struct.pack("i", 0)
        elif type(i) is bool:
            res += struct.pack("i", 1)
            res += struct.pack("i", int(i))
        elif type(i) is int:
            res += struct.pack("i", 2)
            res += struct.pack("i", i)
        elif type(i) is tuple:
            res += struct.pack("i", 5)
            res += struct.pack("f", i[0])
            res += struct.pack("f", i[1])
        else:
            raise ValueError
    return res

async def wait_message(socket: websockets.ClientConnection, min_recv: int = 1):
    received: list = []
    while True:
        try:
            msg = await asyncio.wait_for(socket.recv(), timeout=0.1)
            received.append(msg)
        except asyncio.TimeoutError:
            if len(received) >= min_recv:
                return received

async def main():
    socket = await connect("ws://localhost:7749")

    authed = False
    while not authed:
        token = input("enter token: ")
        await socket.send(token)
        ret = await wait_message(socket)
        assert len(ret) == 1
        authed = ret[0].endswith("OK")

    last_poll = time.time()
    try:
        cps, last_cps_log = 0, time.time()
        while True:
            t = time.time()
            dx = math.cos(t * 2)
            dy = math.sin(t * 2)
            await socket.send(var_to_bytes(1, (dx, dy)))
            this_sent = time.time()
            # poll and clear messages
            if this_sent - last_poll >= 1:
                await wait_message(socket)
                last_poll = this_sent
            # log calls per second
            # may not be accurate since wait_message() waits for 0.1s every second
            cps += 1
            if this_sent - last_cps_log >= 1:
                print(f"calls per sec: {cps / (this_sent - last_cps_log)}")
                cps = 0
                last_cps_log = this_sent
    except KeyboardInterrupt:
        print("interrupted")
        pass
    except websockets.exceptions.ConnectionClosed:
        print("disconnected")
        pass
    await socket.close()

asyncio.run(main())
