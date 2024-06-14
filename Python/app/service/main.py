from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import shutil
import subprocess
import os
from pydantic import BaseModel
import json

app = FastAPI()

from json_to_wav import json_to_wav

app = FastAPI()

UPLOAD_FOLDER = 'samples'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# Chemin vers le script de conversion JSON vers WAV
JSON_TO_WAV = 'json_to_wav.py'

# Import de la fonction de conversion
from json_to_wav import json_to_wav

# Définir le modèle de données
class Item(BaseModel):
    data: dict

class AudioData(BaseModel):
    audio_data: str
    sample_rate: int
    channels: int
    sample_width: int
    
class AudioRequest(BaseModel):
    sample_rate: int
    channels: int
    audio: list
    name:str
    base:str
    
class Name(BaseModel):
    name: str

# start the server with the command: uvicorn main:app --reload

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.post("/upload-audio/")
async def upload_json(file: UploadFile = File(...)):
    file_location = os.path.join(UPLOAD_FOLDER, file.filename)
    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    return {"info": f"file '{file.filename}' saved at '{file_location}'"}

@app.post("/upload-json/")
async def save_json(audio_data: AudioRequest):
    try:
        file_location = os.path.join(UPLOAD_FOLDER, audio_data.name+".json")
        with open(file_location, "w") as json_file:
            json.dump(audio_data.dict(), json_file, indent=4)
        return {"info": f"JSON file saved at '{file_location}' under the name "+audio_data.name+".json"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/jsontowav/")
async def jsontowav(name: Name):
    json_input_path = 'samples/'+name.name+".json"
    wav_output_path = 'music/'+name.name+'.wav'
    json_to_wav(json_input_path,wav_output_path)
    return name.name