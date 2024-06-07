import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'recorder.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterSoundRecorder audioRecorder = FlutterSoundRecorder();
  late AudioPlayer audioPlayer;
  bool isGlobalRecording = false;
  String audioPath = '';
  int recNum = 0;
  Recorder recorder = Recorder();
  //del function
  late File file;

  Future<String> get dirPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioRecorder.openRecorder();
    super.initState();
  }

  @override
  void dispose() {
    audioRecorder.closeRecorder();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> startGlobalRecording() async {
    try{
      setState(() {
        isGlobalRecording = true;
      });
      print("start");
      while(isGlobalRecording){
        recNum = await recorder.startRecording(audioRecorder, audioPath, recNum);
        await Future.delayed(const Duration(seconds: 1));
        await recorder.stopRecording(audioRecorder);
      }
      audioPath = await dirPath;
      audioPath += "/rec";
      audioPath +=  recNum.toString();
      audioPath += ".wav";
    }
    catch(e){
      print("crash during globalreccording : $e");
    }
  }

  Future<void> stopGlobalRecording() async {
    setState(() {
      isGlobalRecording = false;
    });
  }


  Future<void> playRecording() async {
    try {
      Source urlSource = DeviceFileSource(audioPath, mimeType: 'audio/wav');
      await audioPlayer.play(urlSource);
    } catch (e) {
      print('error de playage : $e');
    }
  }

  Future<void> playKendji() async {
    try {
      await audioPlayer.play(AssetSource('Kendji-Girac-Cool-_4_.wav'));
    } catch (e) {
      print('error de playage : $e');
    }
  }

  Future<void> deleteRecords() async {
    String filePath = await dirPath;
    int delRecNum = 0;
    filePath += "/rec";
    file = File(filePath + delRecNum.toString() + ".wav");
    while(await file.exists()){
      await file.delete();
      recNum++;
      file = File(filePath + delRecNum.toString() + ".wav");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isGlobalRecording) const Text('Recording in progress'),
            ElevatedButton(
              onPressed: isGlobalRecording ? stopGlobalRecording : startGlobalRecording,     // A REMODIFIER
              child: isGlobalRecording
                  ? const Text('press to stop')
                  : const Text('press to record'),
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
                "$recNum"
            ),
            ElevatedButton(
              onPressed: playKendji,
                child: const Text('Play Kendji'),
            ),
            ElevatedButton(
              onPressed: deleteRecords,
              child: const Text('Delete Records'),
            ),
            if (!isGlobalRecording)
              ElevatedButton(
                onPressed: playRecording,
                child: const Text('Play Recording'),
              )
          ],
        ),
      ),
    );
  }
}
