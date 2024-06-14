import numpy as np
from scipy import signal
from scipy.io.wavfile import read
from scipy.ndimage import maximum_filter
import requests
import warnings

warnings.filterwarnings("ignore")

def create_peak_constellation(audio_data, Fs):
    """

    Explication :

    Créer une constellation contenant les pics les plus significatifs de l'audio enregistré par l'utilisateur.
    Pour cela la fonction effectue un spectrogramme de l'audio et utilise un filtre maximum pour trouver les pics.

    ---

    Paramètres :

    audio_data : np.array - Les données audio enregistrées par l'utilisateur
    Fs : int - La fréquence d'échantillonnage de l'audio

    ---

    Retourne :

    peak_dict : dict - Un dictionnaire contenant les pics les plus significatifs de l'audio enregistré par l'utilisateur
    Les clés sont les temps et les valeurs sont les fréquences des pics

    """
    frequencies, times, Sxx = signal.spectrogram(
        audio_data, fs=Fs, nperseg=1024, noverlap=64)

    # Utiliser un filtre maximum pour trouver les maximums locaux
    local_max = maximum_filter(Sxx, size=(20, 20))
    # seuil de détection des pics
    threshold = np.percentile(local_max, 75)
    peaks = (local_max == Sxx) & (local_max >= threshold)
    peak_indices = np.argwhere(peaks)
    peak_dict = {times[t]: frequencies[f] for f, t in peak_indices}
    peak_dict = dict(sorted(peak_dict.items()))
    return peak_dict

def create_data(constellation_map, song_id=1):
    """
    
    Explication :

    Créer les données à envoyer au serveur pour la comparaison des fingerprints.
    Pour cela, la fonction parcourt la constellation et crée les hashs à partir des pics.

    ---

    Paramètres :

    constellation_map : dict - Un dictionnaire contenant les pics les plus significatifs de l'audio enregistré par l'utilisateur

    ---

    Retourne :

    data : list - Une liste contenant les hashs à envoyer au serveur pour la comparaison des fingerprints au format JSON
    
    """
    data = []

    # On parcourt la constellation pour créer les hashs
    list_keys = list(constellation_map.keys())
    for idx, time in enumerate(list_keys[:-1]):

        freq = constellation_map[time]

        next_time = list_keys[idx + 1]
        other_freq = constellation_map[next_time]

        time_diff = next_time - time

        if (other_freq != 0):
            invariant = freq/other_freq
            data.append({
                "invariantComponent": invariant,
                "variantComponent": time_diff,
                "localisation": time,
                "songID": song_id
            })
    return data

def send_data_in_batches(data, url,batch_size=50):
    """
    
    Explication :

    Envoie les données au serveur en plusieurs lots pour éviter la surcharge du serveur et améliorer la performance.
    L'URL varie en fonction du choix de l'utilisateur (comparaison ou enregistrement).

    ---

    Paramètres :

    data : list - Une liste contenant les hashs à envoyer au serveur pour la comparaison des fingerprints au format JSON
    url : str - L'URL de l'API à laquelle envoyer les données
    batch_size : int - La taille de chaque lot de données à envoyer

    ---

    Retourne :

    all_responses : list - Une liste contenant les réponses du serveur pour chaque lot de données envoyé ()
    Si l'URL est pour la comparaison, les réponses contiennent les correspondances des fingerprints.
    Sinon, l'URL est pour l'enregistrement et les réponses contiennent une confirmation de l'enregistrement des fingerprints 
    dans la base de données.

    """
    all_responses = []
    headers = {
    'Content-Type': 'application/json'
    }

    for i in range(0, len(data), batch_size):
        batch = data[i:i + batch_size]
        response = requests.post(url, json=batch, headers=headers)

        if response.status_code == 200:
            # print(f'Batch {i//batch_size + 1} envoyé avec succès')
            # print(f'Réponse du serveur : {response.text}')

            all_responses.append(response.json())
        # else:
        #     print(f'Erreur lors de l\'envoi du batch {i//batch_size + 1}, statut: {response.status_code}')
        #     print(f'Réponse du serveur : {response.text}')
    
    return all_responses

def create_histograms(all_responses):
    """
    
    Explication :

    Crée des histogrammes pour chaque songID en fonction des correspondances des fingerprints.
    Les histogrammes contiennent le nombre d'occurences de la différence de localisation des fingerprints.

    ---

    Paramètres :

    all_responses : list - Une liste contenant les réponses du serveur pour chaque lot de données envoyées.
    all_responses contient les fingerprints qui sont en base de données et qui peuvent correspondre aux fingerprints envoyées.

    ---

    Retourne :

    histograms : dict - Un dictionnaire contenant les histogrammes des différences de localisation des fingerprints pour chaque songID


    """

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
    """

    Explication :

    Trouve la meilleure correspondance en fonction des histogrammes des différences de localisation des fingerprints.
    Une correspondance est considérée comme plausible si le nombre d'occurences dans un histrogramme est supérieur à 50%
    du nombre total d'occurences de toutes les correspondances.

    ---

    Paramètres :

    histograms : dict - Un dictionnaire contenant les histogrammes des différences de localisation des fingerprints pour chaque songID

    ---

    Retourne :

    best_match : int - L'ID de la chanson correspondante

    """

    best_match = None
    best_score = 0
    all_scores = 0

    for song_id, histogram in histograms.items():
        count = sum(histogram.values())
        all_scores += count


    for song_id, histogram in histograms.items():
        count = sum(histogram.values())
        if count > best_score and count > all_scores * 0.5:
            best_score = count
            best_match = song_id

    return best_match

def get_song_info(song_id):
    """
    
    Explication :

    Récupère les informations de la chanson correspondante à partir de l'ID de la chanson.

    ---

    Paramètres :

    song_id : int - L'ID de la chanson ayant la meilleure correspondance (trovée par find_best_match)

    ---

    Retourne :

    song_info : dict - Un dictionnaire contenant les informations de la chanson correspondante
    On retrouve le titre, l'artiste, l'album....

    """

    headers = {
    'Content-Type': 'application/json'
    }
    url = 'http://http://51.120.246.62:8080/song/'
    response = requests.get(url=url + str(song_id),headers=headers)

    if response.status_code == 200:
        return response.json()
    else:
        return None

def start_process(audioPath,choice=0):
    """

    Explication :

    Fonction principale pour le traitement du signal audio.

    ---

    Paramètres :

    audioPath : str - Le chemin du fichier audio enregistré par l'utilisateur
    choice : int - Le choix de l'administrateur (0 pour la comparaison, 1 pour l'enregistrement)

    ---

    Retourne :

    song_info : dict - Un dictionnaire contenant les informations de la chanson correspondante
    On retrouve le titre, l'artiste, l'album....

    """

    # Si choice = 0, on fonctionne en comparaison
    Fs, data = read(audioPath)
    constellation = create_peak_constellation(data, Fs)
    data = create_data(constellation)

    if choice == 0:
        url = 'http://51.120.246.62:8080/fingerprint/compare/'
    else:
        url = 'http://51.120.246.62:8080/fingerprint/'

    all_responses = send_data_in_batches(data, url)

    if choice == 1:
        return

    histograms = create_histograms(all_responses)
    print(histograms)
    best_match = find_best_match(histograms)
    song_info = get_song_info(best_match)

    return song_info