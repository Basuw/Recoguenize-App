from flask import Flask, request, jsonify
import os

app = Flask(__name__)

# Assurez-vous que le répertoire de sauvegarde existe
UPLOAD_FOLDER = 'uploaded_files'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@app.route('/uploadjson/', methods=['POST'])
def upload_json():
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    if file:
        file_location = os.path.join(UPLOAD_FOLDER, file.filename)
        file.save(file_location)
        return jsonify({"info": f"file '{file.filename}' saved at '{file_location}'"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
