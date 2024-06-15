import json
import wave
import numpy as np


def json_to_wav(json_path, output_wav_path):
    try:
        # Load JSON data
        with open(json_path, 'r') as json_file:
            data = json.load(json_file)

        # Extract parameters
        audio_samples = np.array(data['audio'], dtype=np.int16)

        # Write to WAV file
        with wave.open(output_wav_path, 'wb') as wf:
            wf.setnchannels(1)
            wf.setsampwidth(2)  # Assuming 16-bit audio here, adjust if needed
            wf.setframerate(44100)

            # Write audio frames to WAV file
            wf.writeframes(audio_samples.tobytes())

        print(f"WAV file '{output_wav_path}' has been successfully created.")

    except FileNotFoundError:
        print(f"Error: JSON file '{json_path}' not found.")
    except KeyError:
        print("Error: JSON file does not contain required audio parameters.")
    except Exception as e:
        print(f"Error: {str(e)}")

# Example usage:
# json_input_path = '/Users/bastienjacquelin/Documents/Projects/SAE/recoguenize_app/Python/app/service/samples/temp_audio_data.json'
# wav_output_path = '/Users/bastienjacquelin/Documents/Projects/SAE/recoguenize_app/Python/app/service/samples/temp_audio_data.json/music/output.wav'

# json_to_wav(json_input_path, wav_output_path)
