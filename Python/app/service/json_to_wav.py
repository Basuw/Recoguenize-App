import json
import wave
import numpy as np

def json_to_wav(json_path, output_wav_path):
    try:
        # Load JSON data
        with open(json_path, 'r') as json_file:
            data = json.load(json_file)

        # Extract parameters
        sample_rate = data['sample_rate']
        channels = data['channels']
        audio_samples = np.array(data['audio'])

        # Write to WAV file
        with wave.open(output_wav_path, 'wb') as wf:
            wf.setnchannels(channels)
            wf.setsampwidth(2)  # Assuming 16-bit audio here, adjust if needed
            wf.setframerate(sample_rate)
            
            # Convert float audio samples (assuming they are in the range -1.0 to 1.0)
            audio_samples = np.int16(audio_samples * 32767)  # Convert to 16-bit integer
            
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
