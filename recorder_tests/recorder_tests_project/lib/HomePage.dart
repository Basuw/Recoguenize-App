import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'customPopup/custom_dialog_widget.dart';
import 'recorder.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


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
  File? _audioFile;

  //del function
  late File file;

  Future<String> get dirPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<void> _loadAudioFile() async {
    final ByteData data = await rootBundle.load('assets/Kendji-Girac-Cool-_4_.wav');
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File('${tempDir.path}/Kendji-Girac-Cool-_4_.wav');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    setState(() {
      _audioFile = tempFile;
    });
  }

  Future<String> getFilePath(String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/$fileName';
    return filePath;
  }

  Future<Int16List> readAudioFileAsBytes(String fileName) async {
    try {
      String filePath = await getFilePath(fileName);
      File audioFile = File(filePath);
      Uint8List fileBytes = await audioFile.readAsBytes();
      return fileBytes.buffer.asInt16List();
    } 
    catch (e) {
      print("Error reading audio file: $e");
      return Int16List(0);
    }
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
        await Future.delayed(const Duration(seconds: 10));
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

  Future<void> callBackend(BuildContext context) async {
    print("call api");
    final response = await http.get(Uri.parse("http://51.120.246.62:8080/song/5"));

    if(response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      print(data);

      String titre = data["title"];
      String artist = data["artists"][0]["name"];

      showDialog(
        context: context,
        builder: (context) => CustomDialogWidget(titre: titre, artiste: artist),
      );

    }
    else {
      print("ERROR API");
    }

  }


  Future<void> callBackend2() async {
    print("load file");
    print("call api upload audio");
    Int16List fileBytes = await readAudioFileAsBytes("rec" + recNum.toString() + ".wav");

    /*var requestBody = {
      'audio': base64Encode(fileBytes),
      'filename': "kendji",
    };*/

    String jsonName = "json" + recNum.toString();

    var requestBody = {
      "sample_rate": 44100,
      "channels": 1,
      "audio": fileBytes,
      "name": jsonName
    };

    var response = await http.post(
      Uri.parse("http://192.168.194.178:8000/upload-json/"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print(response.statusCode);
    print(response.body);

    
  }


  Future<void> callBackend3() async {

    String jsonName = "json" + recNum.toString();

    var info = {
      "name": jsonName,
    };

    final response = await http.post(
        Uri.parse("http://192.168.194.178:8000/jsontowav/"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(info),
    );

    print(response.statusCode);
    print(response.body);
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
            ElevatedButton(
              onPressed: deleteRecords,
              child: const Text('Delete Records'),
            ),
            if (!isGlobalRecording)(
              ElevatedButton(
                onPressed: playRecording,
                child: const Text('Play Recording'),
              )
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => CustomDialogWidget(titre: '', artiste: '',),
                );
              },
              child: const Text("popup song"),
            ),
            ElevatedButton(
                onPressed: () => {callBackend2()},
                child: const Text("callAPI")
            ),
            ElevatedButton(
                onPressed: () => {callBackend3()},
                child: const Text("save to wav")
            ),
          ],
        ),
      ),
    );
  }
}
