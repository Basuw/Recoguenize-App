import json
import wave
import numpy as np

# Example JSON data (replace with your actual JSON data loading)
json_data = '''
{
  "sample_rate": 44100,
  "channels": 1,
  "audio": [0.1, 0.2, 0.3]
}
'''

# Parse JSON data
data = json.loads(json_data)

# Extract parameters
sample_rate = data['sample_rate']
channels = data['channels']
audio_samples = np.array(data['audio'])  # Convert audio to numpy array if necessary

# Write to WAV file
with wave.open('output.wav', 'wb') as wf:
    wf.setnchannels(channels)
    wf.setsampwidth(2)  # Assuming 16-bit audio here, adjust if needed
    wf.setframerate(sample_rate)
    
    # Convert float audio samples (assuming they are in the range -1.0 to 1.0)
    audio_samples = np.int16(audio_samples * 32767)  # Convert to 16-bit integer
    
    # Write audio frames to WAV file
    wf.writeframes(audio_samples.tobytes())
