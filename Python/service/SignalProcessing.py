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

def create_hashes(constellation_map):
    upper_frequency = 23_000
    frequency_bits = 10
    hashes = []

    # On parcourt la constellation pour créer les hashs
    for idx, (time, freq) in enumerate(constellation_map):
        # On compare chaque pic avec le pic suivant
        for other_time, other_freq in constellation_map[idx : idx + 1]:
            diff = other_time - time
            
            # On ne prend pas en compte les pics qui sont trop proches 
            if diff >= 1:
                continue

            # On convertit les fréquences en valeurs binaires
            freq_binned = freq / upper_frequency * (2 ** frequency_bits)
            other_freq_binned = other_freq / upper_frequency * (2 ** frequency_bits)

            # On crée le hash sur 32 bits
            hash = int(freq_binned) | (int(other_freq_binned) << 10) | (int(diff) << 20)
            hashes.append(hash)
    return hashes