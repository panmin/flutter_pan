import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  // 视频播放链接
  final String url;

  // 自动播放
  final bool autoPlay;

  // 循环播放
  final bool looping;

  // 是否允许全屏
  final bool allowFullScreen;

  // 是否允许视频速度的改变
  final bool allowPlaybackSpeedChanging;

  // 视频的纵横比--宽/高
  final double aspectRatio;

  const VideoPlayerWidget({Key? key,
    required this.url,
    this.autoPlay = true,
    this.looping = true,
    this.allowFullScreen = true,
    this.allowPlaybackSpeedChanging = true,
    this.aspectRatio = 16 / 9})
      : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _cheWieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    print(widget.url);
    _videoPlayerController = VideoPlayerController.network(widget.url);
    await _videoPlayerController!.initialize();
    _cheWieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        allowFullScreen: widget.allowFullScreen,
        allowPlaybackSpeedChanging: widget.allowPlaybackSpeedChanging,
        aspectRatio: widget.aspectRatio,
        customControls: null);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = width / widget.aspectRatio;
    bool isInitialized = _cheWieController != null &&
        (_cheWieController?.videoPlayerController.value.isInitialized ?? false);
    return isInitialized ? Container(
      width: width,
      height: height,
      child: Chewie(
        controller: _cheWieController!,
      ),
    ) : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text('Loading'),
      ],
    );
  }

  @override
  void dispose() {
    _cheWieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void play() {
    _cheWieController?.play();
  }

  void pause() {
    _cheWieController?.pause();
  }
}
