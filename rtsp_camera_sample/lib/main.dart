import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraStreamPage(camera: camera),
    );
  }
}

class CameraStreamPage extends StatefulWidget {
  final CameraDescription camera;

  const CameraStreamPage({super.key, required this.camera});

  @override
  State<CameraStreamPage> createState() => _CameraStreamPageState();
}

class _CameraStreamPageState extends State<CameraStreamPage> {
  static const _ipAndPort='YOUR IP AND PORT TO RTSP SERVER';
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  late String _rtspUrl;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    // _controller = CameraController(
    //   widget.camera,
    //   ResolutionPreset.high,
    // );
    // _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _startStreaming() async {
    _rtspUrl = 'rtsp://$_ipAndPort/mystream';

    // Використання команд без 'preset' опції
    final String ffmpegCommand =
        '-f android_camera -video_size 1280x720 -i 0 -c:v mpeg4 -f rtsp $_rtspUrl';

    _flutterFFmpeg.executeAsync(ffmpegCommand, (execution) {
      print(
          "FFmpeg process exited with rc ${execution.executionId} ${execution.returnCode}");
      if (execution.returnCode == 0) {
        print("Streaming started successfully");
      } else {
        print("Streaming failed with return code ${execution.returnCode}");
      }
    });

    setState(() {
      _isStreaming = true;
    });
  }

  Future<void> _stopStreaming() async {
    if (_isStreaming) {
      _flutterFFmpeg.cancel();
      setState(() {
        _isStreaming = false;
      });
      print('Streaming stopped');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RTSP Camera Stream')),
      body: Container(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            child: const Text('Start'),
            onPressed: () async {
              await _startStreaming();
              print('Streaming started');
            },
          ),
          FloatingActionButton(
            child: const Text('Stop'),
            onPressed: () async {
              await _stopStreaming();
            },
          ),
        ],
      ),
    );
  }
}
