import requests

# pip3 install requests
# pip3 install fastapi uvicorn



response = requests.get("http://api.open-notify.org/astros") 
print(response.status_code)


