// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';

import 'recorder.dart';


class RecordPage extends StatefulWidget {
  const RecordPage({super.key, required this.title});

  final String title;

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with SingleTickerProviderStateMixin {
  late AudioPlayer audioPlayer;
  bool isGlobalRecording = false;
  String audioPath = '';
  int recNum = 0;
  int tapNb = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  Recorder recorder = Recorder();
  FlutterSoundRecorder audioRecord = FlutterSoundRecorder();

  Future<String> get dirPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  void initState() {
    audioRecord.openRecorder();
    audioPlayer = AudioPlayer();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )
    ..addListener(() {
      setState(() { });
    })
    ..addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        _controller.stop();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    audioRecord.closeRecorder();
    audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> startGlobalRecording() async {
    try{
      print("start");
      _controller.repeat();
      setState(() {
        isGlobalRecording = true;
      });
      while(isGlobalRecording){
        recNum = await recorder.startRecording(audioRecord, audioPath, recNum);
        await Future.delayed(const Duration(milliseconds: 1000));
        await recorder.stopRecording(audioRecord);
        print("boucle "+recNum.toString());
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
    print("stop");
    _controller.forward(from: _controller.value);
    setState(() {
      isGlobalRecording = false;
    });

  }

  Future<void> tapDetection(TapDownDetails details) async {
    isGlobalRecording ? stopGlobalRecording() : startGlobalRecording();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF42958f),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              isGlobalRecording ? 'Recoguenizing...' : 'Tap to Recoguenize',
              style: TextStyle(color: Color(0xFFfdfefc), fontSize: 30, fontFamily: 'Arial_Rounded'),
            ),
            SizedBox(
              height: 40,
            ),
            AvatarGlow(
              endRadius: 200.0,
              animate: isGlobalRecording,
              child: GestureDetector(
                onTapDown: tapDetection,
                child: AnimatedBuilder(
                  animation: _animation,
                  child: Material(
                    shape: CircleBorder(),
                    elevation: 8,
                    child: Container(
                        padding: EdgeInsets.all(2),
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFFFFFFFF)),
                        child: Image.asset(
                          'assets/vinyle_simple.png',
                          fit: BoxFit.cover,
                        )
                    ),
                  ),
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value * 5.0 * 3.141592653589793,
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
