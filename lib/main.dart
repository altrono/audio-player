import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true
  );
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

  final _playList = ConcatenatingAudioSource(
      children: [
        AudioSource.uri(
          Uri.parse('asset:///assets/audio/bobmarley.mp3'),
          tag: MediaItem(
              id: '3',
              title: 'Put it on by Bob Marley',
              artist: 'Bob Marley',
              artUri: Uri.parse('https://imgs.smoothradio.com/images/278791?crop=16_9&width=660&relax=1&signature=MYrhimLcIJjp2GBHg7mvh6YsRa0='),
          )
        ),
        AudioSource.uri(
          Uri.parse('asset:///assets/audio/success.mp3'),
          tag: MediaItem(
              id: '4',
              title: 'Success',
              artist: 'Jay Z ft Nas',
              artUri: Uri.parse('https://media.distractify.com/brand-img/deRUSwTnA/2160x1130/jay-nas-1628264810026.jpg'),
          )
        ),
        AudioSource.uri(
          Uri.parse('asset:///assets/audio/hard_knock_life.mp3'),
          tag: MediaItem(
              id: '1',
              title: 'Hard knock life by Jay Z',
              artist: 'Jay Z',
              artUri: Uri.parse('https://variety.com/wp-content/uploads/2020/06/jay-z-2.jpg?w=681&h=383&crop=1&resize=681%2C383'),
            )
        ),
        AudioSource.uri(
          Uri.parse('asset:///assets/audio/diabolos.mp3'),
          tag: MediaItem(
              id: '6',
              title: 'Diabolos by Koffi Ololmide',
              artist: 'Koffi Olomide',
              artUri: Uri.parse('https://infoguidenigeria.com/wp-content/uploads/2021/12/koffi-olomide-600x470.jpg'),
            )
        ),
        AudioSource.uri(
          Uri.parse('asset:///assets/audio/2woshort_ba_straata.mp3'),
          tag: MediaItem(
              id: '3',
              title: '2woshort ba straata',
              artist: 'Dj Maphorisa',
              artUri: Uri.parse('https://i0.wp.com/mgosi.co.za/wp-content/uploads/2022/06/DJMaphorisa.jpeg?fit=1080%2C1080&ssl=1'),
            )
        ),
      ],
  );

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
    _init();
  }

  Future<void> _init() async {
    await _audioPlayer.setLoopMode(LoopMode.all);
    await _audioPlayer.setAudioSource(_playList);
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
            StreamBuilder<SequenceState?>(
                stream: _audioPlayer.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  if (state?.sequence.isEmpty ?? true) {
                    return const SizedBox();
                  }
                  final metadata = state!.currentSource!.tag as MediaItem;
                  return MediaMetadata(
                      imageUrl: metadata.artUri.toString(),
                      title: metadata.title,
                      artist: metadata.artist ?? '');
                },
            ),

            const SizedBox(height: 20,),
            StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return ProgressBar(
                      barHeight: 8,
                      baseBarColor: Colors.grey[600],
                      bufferedBarColor: Colors.grey,
                      progressBarColor: Colors.red,
                      thumbColor: Colors.red,
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



class MediaMetadata extends StatelessWidget {
  const MediaMetadata({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.artist,

  }) : super(key: key);

  final String imageUrl;

  final String title;

  final String artist;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:  [
        DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(2, 4),
                  blurRadius: 4,
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Image(
                  image: NetworkImage(imageUrl),
                  height: 300,
                  width: 300,
                  fit: BoxFit.cover,
              ),
            ),
        ),

        const SizedBox(height: 20,),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8,),

        Text(
          artist,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600
          ),
          textAlign: TextAlign.center,
        ),

      ],
    );
  }
}


class Controls extends StatelessWidget {
  const Controls({Key? key, required this.audioPlayer}) : super(key: key);

  final AudioPlayer audioPlayer;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: audioPlayer.seekToPrevious,
            iconSize: 60,
            color: Colors.white,
            icon: const Icon(Icons.skip_previous),
        ),
        StreamBuilder<PlayerState>(
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
        ),

        IconButton(
          onPressed: audioPlayer.seekToNext,
          iconSize: 60,
          color: Colors.white,
          icon: const Icon(Icons.skip_next),
        ),
      ],
    );
  }
}
