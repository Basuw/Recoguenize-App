import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';



class Recorder {

  Future<String> get dirPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<int> startRecording(FlutterSoundRecorder audioRecord, String audioPath, int recNum) async {
    try {
      var status = await Permission.microphone.status;
      if(!status.isGranted){
        await Permission.microphone.request();
      }
      if (status.isGranted) {
        recNum++;
        audioPath = await dirPath;
        audioPath += "/rec";
        audioPath +=  recNum.toString();
        audioPath += ".wav";
        print("record $recNum started");
        await audioRecord.startRecorder(toFile: audioPath, codec: Codec.pcm16WAV);
        //await audioRecord.start(const RecordConfig(encoder: AudioEncoder.wav,numChannels: 1), path: audioPath);
      }
    } catch (e) {
      print('erreur de démarrage d"enregistrage : $e');
    }
    return recNum;
  }


  Future<void> stopRecording(FlutterSoundRecorder audioRecord) async {
    try {
      await audioRecord.stopRecorder();
    } catch (e) {
      print('erreur de stoppage d"enregistrage : $e');
    }
  }

  Future<Uint8List> loadWavFileAsBytes(String filepath) async {
    ByteData data = await rootBundle.load(filepath);
    Uint8List bytes = data.buffer.asUint8List();
    return bytes;
  }

}