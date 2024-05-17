import 'dart:typed_data';
import 'package:wav/raw_file.dart';
import 'package:wav/wav.dart';
import 'package:wav/wav_io.dart';

class SignalProcessing {

  String audioPath = '';

  Future<void> startProcess(String dirPath,int recNum) async {

    audioPath = dirPath;
    audioPath += "/rec";
    audioPath +=  recNum.toString();
    audioPath += ".wav";

    readWavData();

  }

  Future<List<Float64List>> readWavData() async => readRawAudio(await internalReadFile(audioPath), 1,WavFormat.float64);

}

