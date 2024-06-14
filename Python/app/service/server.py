import asyncio
import websockets

from signal_processing import hello_world, start_process


async def echo(websocket, path):
    async for wavfile in websocket:
        #save the wav file
       #with open("audio.wav", "wb") as f:
        #await f.write(wavfile)
        await websocket.send("Server : Fichier audio reçu")
        start_process("sample.wav")
        hello_world();
    async for message in websocket:
        await websocket.send(f"Server : Message reçu : {message}")
hello_world();

start_server = websockets.serve(echo, "0.0.0.0", 8765)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()