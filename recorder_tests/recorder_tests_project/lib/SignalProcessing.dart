import 'dart:typed_data';
import 'package:scidart/numdart.dart';
import 'package:wav/raw_file.dart';
import 'package:wav/wav.dart';
import 'package:wav/wav_io.dart';
import 'package:scidart/scidart.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';


class SignalProcessing {

  String audioPath = '';

  Future<void> startProcess(String dirPath,int recNum) async {


    audioPath = dirPath;
    audioPath += "/rec";
    audioPath +=  recNum.toString();
    audioPath += ".wav";

    File file = File(audioPath);
    Uint8List bytes = await file.readAsBytes();
    List<int> sample = extractSamples(bytes);
    List<double> sampleDouble = convertIntListToDoubleList(sample);

    print("process $recNum started");

    // Read the audio file data
    //List<Float64List> data = await readWavData();

    // Convert the data to Array type
    // readWavData() returns a List<Float64List> type that needs to be converted to ArrayComplexe type
    ArrayComplex audioDataComplexe = await convertToArrayComplexType(sampleDouble);
    //Perform FFT on the audio data
    ArrayComplex spectroData = await performFFT(audioDataComplexe);


  }

  List<int> extractSamples(Uint8List bytes) {
    // L'entête WAV est de 44 bytes, les échantillons commencent donc à l'offset 44
    const int headerSize = 44;
    List<int> samples = [];

    // Itérer sur les bytes pour lire les échantillons (16 bits, signed)
    for (int i = headerSize; i < bytes.length; i += 2) {
      int sample = (bytes[i + 1] << 8) | bytes[i];
      if (sample >= 0x8000) {
        sample -= 0x10000;
      }
      samples.add(sample);
    }

    return samples;
  }

  List<double> convertIntListToDoubleList(List<int> intList) {
    return intList.map((e) => e.toDouble()).toList();
  }

  Future<List<Float64List>> readWavData() async
  => readRawAudioFile(audioPath, 1,WavFormat.pcm16bit);

  Future<ArrayComplex> convertToArrayComplexType(List<double> data) async {
    Array audioData = Array(data);
    ArrayComplex audioDataComplex = arrayToComplexArray(audioData);
    return audioDataComplex;
  }

  Future<ArrayComplex> performFFT(ArrayComplex audioData) async {
    ArrayComplex spectroData= fft(audioData);
    return spectroData;
  }

}
