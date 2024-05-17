import 'dart:typed_data';
import 'package:scidart/numdart.dart';
import 'package:wav/raw_file.dart';
import 'package:wav/wav.dart';
import 'package:wav/wav_io.dart';
import 'package:scidart/scidart.dart';

class SignalProcessing {

  String audioPath = '';

  Future<void> startProcess(String dirPath,int recNum) async {

    audioPath = dirPath;
    audioPath += "/rec";
    audioPath +=  recNum.toString();
    audioPath += ".wav";

    print("process $recNum started");

    // Read the audio file data
    List<Float64List> data = await readWavData();
   
    // Convert the data to Array type
    // readWavData() returns a List<Float64List> type that needs to be converted to ArrayComplexe type
    //ArrayComplex audioDataComplexe = await convertToArrayComplexType(data);

    //Perform FFT on the audio data
    //ArrayComplex spectroData = await performFFT(audioDataComplexe);


  }

  Future<List<Float64List>> readWavData() async
  => readRawAudioFile(audioPath, 1,WavFormat.pcm16bit);

  Future<ArrayComplex> convertToArrayComplexType(List<Float64List> data) async {
    Array audioData = Array(data[0]);
    ArrayComplex audioDataComplex = arrayToComplexArray(audioData);
    return audioDataComplex;
  }

  Future<ArrayComplex> performFFT(ArrayComplex audioData) async {
    ArrayComplex spectroData= fft(audioData);
    return spectroData;
  }

}

