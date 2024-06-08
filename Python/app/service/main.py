from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse


app = FastAPI()

# start the server with the command: uvicorn main:app --reload

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.post("/upload-audio/")
async def upload_audio(file: UploadFile = File(...)):
    file_location = f"~/samples/{file.filename}"
    with open(file_location, "wb") as f:
        f.write(file.file.read())
    
    return JSONResponse(content={"filename": file.filename, "location": file_location})