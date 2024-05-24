import numpy as np
from scipy import signal
from scipy.io.wavfile import read


# Création de la constellation des pics significatifs
# audio_data correspond au data du fichier .wav
# fs correspond à la fréquence d'échantillonage

def create_peak_constellation(audio_data, Fs):
    num_peaks = 15

    # On applique une STFT sur l'audio étudié

    frequencies, times, stft = signal.stft(
        x = audio_data, fs = Fs, nperseg= 512, nfft = 512, return_onesided=True, noverlap= 0,
    )

    constellation_map = []

    for time_index, window in enumerate(stft.T):
        # On convertit le spectre en valeur réel
        spectrum = abs(window)
        
        # On identifie les pics les plus importants 
        peaks, props = signal.find_peaks(spectrum, prominence=0, distance=21)

        n_peaks = min(num_peaks, len(peaks))

        largest_peaks = np.argpartition(props["prominences"], -n_peaks)[-n_peaks:]
        for peak in peaks[largest_peaks]:
            frequency = frequencies[peak]
            time_in_seconds = times[time_index]
            constellation_map.append([time_in_seconds, frequency])
    
    return constellation_map

Fs, data = read("Documents/rec1.wav")
constellation = create_peak_constellation(data,Fs)