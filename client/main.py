import math
import time
import struct
import asyncio
import websockets
from websockets.asyncio.client import connect
from Crypto.Util.number import bytes_to_long

def byte_to_str(byte: int):
    return f"{byte // 16:x}{byte % 16:x}"

def log(msg: str | bytearray):
    return
    if type(msg) == str:
        print(f"Received string: {msg}")
        return
    print(f"Received Bytes:")
    print(f"  [{', '.join(map(byte_to_str, msg))}]")
    print(f"  [{', '.join([str(bytes_to_long(msg[i:i + 4][::-1])) for i in range(0, len(msg), 4)])}]")

def var_to_bytes(*args):
    res = bytearray()
    res += struct.pack("i", 28)  # type of gdscript arrays
    res += struct.pack("i", len(args))
    for i in args:
        if i is None:
            res += struct.pack("i", 0)
        elif type(i) == bool:
            res += struct.pack("i", 1)
            res += struct.pack("i", int(i))
        elif type(i) == int:
            res += struct.pack("i", 2)
            res += struct.pack("i", i)
        elif type(i) == tuple:
            res += struct.pack("i", 5)
            res += struct.pack("f", i[0])
            res += struct.pack("f", i[1])
        else:
            raise ValueError
    log(res)
    return res

async def wait_message(socket: websockets.ClientConnection, min_recv: int = 1):
    received: list = []
    while True:
        try:
            msg = await asyncio.wait_for(socket.recv(), timeout=0.1)
            log(msg)
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
        while True:
            t = time.time()
            dx = math.cos(t * 2)
            dy = math.sin(t * 2)
            last_sent = time.time()
            await socket.send(var_to_bytes(1, (dx, dy)))
            # await socket.send(var_to_bytes(3, (300, 300)))
            this_sent = time.time()
            sent_interval = (this_sent - last_sent) / 2
            print(f"interval: {sent_interval}, calls per sec: {1/sent_interval}")
            last_sent = this_sent
            # await wait_message(socket)
            # break
            if this_sent - last_poll >= 1:
                await wait_message(socket)
                last_poll = this_sent
                last_sent = this_sent
    except KeyboardInterrupt:
        print("interrupted")
        pass
    except websockets.exceptions.ConnectionClosed:
        print("disconnected")
        pass
    # while True:
    #     try:
    #         msg = input("client: ")
    #         await socket.send("client: " + msg)
    #         # await socket.send(bytes(msg, encoding='ascii'))
    #         await wait_message(socket)
    #     except websockets.exceptions.ConnectionClosed:
    #         log("connection closed")
    #         break
    #     except EOFError:
    #         print("interrupted. exiting")
    #         break
    await socket.close()

asyncio.run(main())
