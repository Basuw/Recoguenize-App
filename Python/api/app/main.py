from fastapi import FastAPI

app = FastAPI()

# start the server with the command: uvicorn main:app --reload

@app.get("/")
async def root():
    return {"message": "Hello World"}