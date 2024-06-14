from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import shutil
import os
from pydantic import BaseModel
import json

app = FastAPI()

UPLOAD_FOLDER = 'samples'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# Définir le modèle de données
class Item(BaseModel):
    data: dict

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
async def upload_json(item: Item):
    file_location = os.path.join(UPLOAD_FOLDER, 'uploaded_content.json')
    with open(file_location, "w") as buffer:
        json.dump(item.data, buffer)
    return {"info": f"content saved at '{file_location}'"}
