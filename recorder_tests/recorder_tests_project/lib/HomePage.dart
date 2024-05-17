import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'recorder.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AudioRecorder audioRecord;
  late AudioPlayer audioPlayer;
  bool isGlobalRecording = false;
  String audioPath = '';
  int recNum = 0;
  Recorder recorder = Recorder();

  Future<String> get dirPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioRecord = AudioRecorder();
    super.initState();
  }

  @override
  void dispose() {
    audioRecord.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> startGlobalRecording() async {
    try{
      setState(() {
        isGlobalRecording = true;
      });
      while(isGlobalRecording){
        recNum = await recorder.startRecording(audioRecord, audioPath, recNum);
        await Future.delayed(const Duration(seconds: 1));
        await recorder.stopRecording(audioRecord);
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

  /*
  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        recNum++;
        audioPath = await dirPath;
        audioPath += "/rec";
        audioPath +=  recNum.toString();
        audioPath += ".wav";
        print("record $recNum started");
        await audioRecord.start(const RecordConfig(encoder: AudioEncoder.wav), path: audioPath);
        print(audioPath);
      }
    } catch (e) {
      print('erreur de démarrage d"enregistrage : $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      await audioRecord.stop();
    } catch (e) {
      print('erreur de stoppage d"enregistrage : $e');
    }
  }
  */

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
              onPressed: isGlobalRecording ? stopGlobalRecording : startGlobalRecording,
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
