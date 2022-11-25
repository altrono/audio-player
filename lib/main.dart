import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue,),
      home: const AudioPlayerScreen(),
    );
  }
}

class PositionData {
  const PositionData(
      this.position,
      this.buffuredPosition,
      this.duration,
  );

  final Duration position;
  final Duration buffuredPosition;
  final Duration duration;


}

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({Key? key}) : super(key: key);

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero)
      );

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer()..setAsset('assets/audio/bobmarley.mp3');
    // _audioPlayer = AudioPlayer()..setUrl('assets/audio/bobmarley.mp3');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.more_horiz),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF144771), Color(0xFF071A2C)
              ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return ProgressBar(
                      barHeight: 8,
                      baseBarColor: Colors.grey[600],
                      bufferedBarColor: Colors.grey,
                      progressBarColor: Colors.red,
                      timeLabelTextStyle: const TextStyle(
                        color:  Colors.white,
                        fontWeight: FontWeight.w600
                      ),
                      progress: positionData?.position ?? Duration.zero,
                      buffered: positionData?.buffuredPosition ?? Duration.zero,
                      total: positionData?.duration ?? Duration.zero,
                      onSeek: _audioPlayer.seek,
                  );
                },
            ),
            const SizedBox(height: 20,),
            Controls(audioPlayer: _audioPlayer)
          ],
        ),
      ),
    );
  }
}

class Controls extends StatelessWidget {
  const Controls({Key? key, required this.audioPlayer}) : super(key: key);

  final AudioPlayer audioPlayer;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
        stream: audioPlayer.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final processingState = playerState?.playing;
          final playing =playerState?.playing;

          if (!(playing ?? false)) {
            return IconButton(
                onPressed: audioPlayer.play, 
                iconSize: 80,
                color: Colors.white,
                icon: const Icon(Icons.play_arrow_rounded),
            );
          } else if (processingState != ProcessingState.completed) {
            return IconButton(
                onPressed: audioPlayer.pause, 
                icon: const Icon(Icons.pause_rounded),
            );
          }
          return const Icon(
            Icons.play_arrow_rounded,
            size: 80,
            color: Colors.white,
          );
        },
    );
  }
}
