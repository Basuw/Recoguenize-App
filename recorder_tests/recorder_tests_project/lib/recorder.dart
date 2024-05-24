import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';


class Recorder {

  Future<String> get dirPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<int> startRecording(AudioRecorder audioRecord, String audioPath, int recNum) async {
    try {
      if (await audioRecord.hasPermission()) {
        recNum++;
        audioPath = await dirPath;
        audioPath += "/rec";
        audioPath +=  recNum.toString();
        audioPath += ".wav";
        print("record $recNum started");
        await audioRecord.start(const RecordConfig(encoder: AudioEncoder.wav,numChannels: 1), path: audioPath);
      }
    } catch (e) {
      print('erreur de démarrage d"enregistrage : $e');
    }
    return recNum;
  }


  Future<void> stopRecording(AudioRecorder audioRecord) async {
    try {
      await audioRecord.stop();
    } catch (e) {
      print('erreur de stoppage d"enregistrage : $e');
    }
  }



}