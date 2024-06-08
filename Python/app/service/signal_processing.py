import numpy as np
from scipy import signal
from scipy.io.wavfile import read
import requests


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

def create_data(constellation_map):
    upper_frequency = 23000
    frequency_bits = 10
    data = []

    # On parcourt la constellation pour créer les hashs
    for idx, (time, freq) in enumerate(constellation_map[:-1]):

        other_freq = constellation_map[idx + 1][1]

        time_diff = constellation_map[idx + 1][0] - time
        freq_diff = abs(other_freq - freq)

        if time_diff <= 0 and freq_diff <= 3000 :
            continue

        freq_binned = freq / upper_frequency * (2 ** frequency_bits)
        other_freq_binned = other_freq / upper_frequency * (2 ** frequency_bits)

        invariant = freq_binned/other_freq_binned

        data.append({
            "invariantComponent": invariant,
            "variantComponent": time_diff,
            "localisation": time,
            "songID": 1
        })

    return data

def send_data_in_batches(data, url,batch_size=50):
    all_responses = []
    headers = {
    'Content-Type': 'application/json'
    }

    for i in range(0, len(data), batch_size):
        batch = data[i:i + batch_size]
        response = requests.post(url, json=batch, headers=headers)

        if response.status_code == 200:
            print(f'Batch {i//batch_size + 1} envoyé avec succès')
            print(f'Réponse du serveur : {response.text}')

            all_responses.append(response.json())
        else:
            print(f'Erreur lors de l\'envoi du batch {i//batch_size + 1}, statut: {response.status_code}')
            print(f'Réponse du serveur : {response.text}')
    
    return all_responses

def create_histograms(all_responses):
    # Pour chaque reponse (indice array)
        # Pour chaque clé de map
            # Pour chaque pair de finger print en DB et Enregistré, faire la différence de "localisation"
                #  Ajouter 1 à la valeur de la "localisation" de l'histogramme associé à la clé de la map
    # Retourner la liste qui contient le nombre d'occurence de la différence de localisation par histogramme

    # Initialisation d'un dictionnaire pour stocker les histogrammes des différences de localisation
    histograms = {}

    for response in all_responses:
        # Pour chaque clé dans la réponse (songID)
        for song_id, matches in response.items():
            if song_id not in histograms:
                histograms[song_id] = {}

            # Pour chaque paire de fingerprints dans les correspondances
            for match in matches:
                song_fp = match['songFingerprint']
                db_fp = match['databaseFingerprint']

                # Calcul de la différence de localisation
                local_diff = song_fp['localisation'] - db_fp['localisation']

                # Mise à jour de l'histogramme pour ce song_id
                if local_diff not in histograms[song_id]:
                    histograms[song_id][local_diff] = 0

                histograms[song_id][local_diff] += 1

    return histograms

def find_best_match(histograms):
    # Pour chaque histogramme
        # Pour chaque clé de l'histogramme
            # Si la valeur de la clé est supérieure à 10
                # Ajouter la clé à la liste des candidats
    # Retourner le candidat avec la valeur la plus élevée

    best_match = None
    best_score = 0
    count_offset = 10

    for song_id, histogram in histograms.items():
        for local_diff, count in histogram.items():
            if count > count_offset:
                if count > best_score:
                    best_score = count
                    best_match = song_id

    return best_match

def get_song_info(song_id):
    headers = {
    'Content-Type': 'application/json'
    }
    url = 'http://51.120.246.62:8080/song/'
    response = requests.get(url=url + str(song_id),headers=headers)

    if response.status_code == 202:
        return response.json()
    else:
        return None

def start_process(audioPath,choice = 0):
    # Si choice = 0, on fonctionne en comparaison
    Fs, data = read(audioPath)
    constellation = create_peak_constellation(data,Fs)
    data = create_data(constellation)
    
   
    if choice == 0:
        url = 'http://51.120.246.62:8080/fingerprint/compare/'
    else:
        url = 'http://51.120.246.62:8080/fingerprint/'
    
    all_responses = send_data_in_batches(data,url)
    
    if choice == 0:
        histograms = create_histograms(all_responses)
        best_match = find_best_match(histograms)
        song_info = get_song_info(best_match)

    return song_info

def hello_world():
    print("Hello World")
    return "Hello World"