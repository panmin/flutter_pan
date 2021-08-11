import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:chewie/src/material/material_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pan/common/utils/date_util.dart';
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

  // 视频播放的导航栏距离顶部的高度
  final double videoTopBarMarginTop;

  // 视频的纵横比--宽/高
  final double aspectRatio;

  const VideoPlayerWidget(
      {Key? key,
      required this.url,
      this.autoPlay = true,
      this.looping = true,
      this.allowFullScreen = true,
      this.allowPlaybackSpeedChanging = true,
      this.aspectRatio = 16 / 9,
      this.videoTopBarMarginTop = 0})
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
    //https://video.dongyin.net/video/2020-08-10/0_2020-08-10_2687449/1597050221517_1597055348990.mp4
    _videoPlayerController = VideoPlayerController.network(widget.url);
    await _videoPlayerController!.initialize();
    _cheWieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        allowFullScreen: widget.allowFullScreen,
        allowPlaybackSpeedChanging: widget.allowPlaybackSpeedChanging,
        aspectRatio: widget.aspectRatio,
        customControls: VideoPlayerControlsWidget(
          overlayUI: _videoPlayTopBar(),
          bottomGradient: _blackLinearGradient(),
        ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = width / widget.aspectRatio;
    bool isInitialized = _cheWieController != null &&
        (_cheWieController?.videoPlayerController.value.isInitialized ?? false);
    return Container(
      width: width,
      height: height,
      child: isInitialized?
          Chewie(controller: _cheWieController!)
          :Container(
            color: Colors.black,
            child: Column(
                children: [
                  _videoPlayTopBar(),
                  Padding(
                    padding: EdgeInsets.only(top: widget.videoTopBarMarginTop),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                ],
              ),
          ),
    );
  }

  /// 播放视频的 TopBar
  Widget _videoPlayTopBar() {
    return Container(
      padding: EdgeInsets.only(top: widget.videoTopBarMarginTop, right: 8),
      // 渐变背景色
      decoration: BoxDecoration(gradient: _blackLinearGradient(fromTop: true)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BackButton(color: Colors.white),
          Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  /// 渐变背景色
  _blackLinearGradient({bool fromTop = false}) {
    return LinearGradient(
      begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
      end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
      colors: [
        Colors.black54,
        Colors.black45,
        Colors.black38,
        Colors.black26,
        Colors.black12,
        Colors.transparent
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

class VideoPlayerControlsWidget extends StatefulWidget {
  // 初始化是是否显示 加载动画：默认为true
  final bool? showLoadingOnInitialize;

  // 是否显示大播放按钮：默认为true
  final bool? showBigPlayIcon;

  // 浮层 Ui
  final Widget? overlayUI;

  // 底层控制栏的背景色：一般设为渐变色
  final Gradient bottomGradient;

  const VideoPlayerControlsWidget(
      {Key? key,
      required this.overlayUI,
      required this.bottomGradient,
      this.showLoadingOnInitialize = true,
      this.showBigPlayIcon = true})
      : super(key: key);

  @override
  _VideoPlayerControlsWidgetState createState() =>
      _VideoPlayerControlsWidgetState();
}

class _VideoPlayerControlsWidgetState extends State<VideoPlayerControlsWidget>
    with SingleTickerProviderStateMixin {
  // 视频播放数据：当前播放位置，缓存状态，错误状态，设置等
  VideoPlayerValue? _latestValue;

  // 声音大小
  double? _latestVolume;
  bool _hideStuff = true;

  // 控制栏隐藏时间计时器
  Timer? _hideTimer;
  Timer? _initTimer;

  // 全屏切换 Timer
  Timer? _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;

  // 底部控制栏的高度
  final barHeight = 48.0;
  final marginSize = 5.0;

  // 视频播放控制器
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // 播放暂停图标动画控制器
  AnimationController? playPauseIconAnimationController;

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    _videoPlayerController?.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = _chewieController;
    _chewieController = ChewieController.of(context);
    _videoPlayerController = _chewieController?.videoPlayerController;

    // vsync:ticker 驱动动画,每次屏幕刷新都会调用TickerCallback，
    // 一般 SingleTickerProviderStateMixin 添加到 State，直接使用this
    playPauseIconAnimationController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
    );

    if (_oldController != _chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  /// 初始化
  Future<void> _initialize() async {
    _videoPlayerController?.addListener(_updateState);

    // 更新状态：重新获取视频播放的状态数据
    _updateState();

    if ((_videoPlayerController?.value != null &&
            _videoPlayerController?.value.isPlaying == true) ||
        _chewieController?.autoPlay == true) {
      _startHideTimer();
    }

    if (_chewieController?.showControlsOnInitialize == true) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_latestValue?.hasError == true) {
      if (_chewieController?.errorBuilder != null) {
        return _chewieController?.errorBuilder!(
                context,
                _chewieController
                        ?.videoPlayerController.value.errorDescription ??
                    "") ??
            Container();
      } else {
        return const Center(
            child: Icon(Icons.error, color: Colors.white, size: 42));
      }
    }

    return _playVideo();
  }

  /// 播放器
  Widget _playVideo() {
    return GestureDetector(
      onTap: () => _cancelAndRestartTimer(),
      // AbsorbPointer:禁止用户输入的控件，会消耗掉事件，跟 IgnorePointer(不消耗事件) 类似
      child: AbsorbPointer(
        // absorbing：true 不响应事件
        absorbing: _hideStuff,
        // 类似AndroidFrameLayout
        child: Stack(
          children: [
            // Container(),
            // 类似 垂直方向的 LinearLayout
            Column(
              children: <Widget>[
                // 不是正在播放 && duration == null || 正在缓冲
                if (_latestValue != null &&
                        _latestValue?.isPlaying == false &&
                        _latestValue?.duration == null ||
                    _latestValue?.isBuffering == true)
                  // 圆形进度条
                  Expanded(child: Center(child: _loadingIndicator()))
                else
                  // 创建点击区
                  _buildHitArea(),
                // 底部控制栏
                _buildBottomBar(context),
              ],
            ),
            // 浮层
            _overlayUI()
          ],
        ),
      ),
    );
  }

  ///中间进度条
  _loadingIndicator() {
    //初始化时是否显示loading
    return widget.showLoadingOnInitialize == true
        ? CircularProgressIndicator()
        : null;
  }

  /// 视频点击区
  Expanded _buildHitArea() {
    // 视频是否播放完：当前位置 >= 持续时间
    final bool isFinished = (_latestValue?.position ?? Duration()) >=
        (_latestValue?.duration ?? Duration());

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // 显示隐藏控制栏
          if (_latestValue != null && _latestValue?.isPlaying == true) {
            if (_displayTapped) {
              setState(() {
                _hideStuff = true;
              });
            } else {
              _cancelAndRestartTimer();
            }
          } else {
            setState(() {
              _hideStuff = true;
            });
          }
        },
        // 中间大按钮
        child: Container(
          color: Colors.transparent,
          child: Center(
            // AnimatedOpacity:使子组件变的透明
            child: AnimatedOpacity(
              opacity: _latestValue != null &&
                      _latestValue?.isPlaying == false &&
                      !_dragging
                  ? 1.0
                  : 0.0,
              // 动画执行的时间
              duration: const Duration(milliseconds: 300),
              // 中间播放按钮,showBigPlayIcon:是否显示大播放按钮
              child: widget.showBigPlayIcon == true
                  ? _palyPauseButton(isFinished)
                  : Container(),
            ),
          ),
        ),
      ),
    );
  }

  /// 播放、暂停、重播按钮
  Widget _palyPauseButton(isFinished) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(48.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Material(
            child: IconButton(
              icon: isFinished
                  ? const Icon(Icons.replay, size: 32.0)
                  // AnimatedIcon:动画图标
                  : AnimatedIcon(
                      // 播放到暂停的动画图标
                      icon: AnimatedIcons.play_pause,
                      // 设置图标的动画
                      progress: playPauseIconAnimationController!,
                      size: 32.0,
                    ),
              onPressed: () {
                // 开始播放或暂停
                _playPause();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 开始播放或者暂停
  void _playPause() {
    // 是否播放完
    bool isFinished;
    if (_latestValue?.duration != null) {
      isFinished = (_latestValue?.position ?? Duration()) >=
          (_latestValue?.duration ?? Duration());
    } else {
      isFinished = false;
    }

    setState(() {
      //如果正在播放
      if (_videoPlayerController?.value.isPlaying == true) {
        // 方向执行动画：从播放到暂停
        playPauseIconAnimationController?.reverse();
        _hideStuff = false;
        _hideTimer?.cancel();
        _videoPlayerController?.pause();
      } else {
        _cancelAndRestartTimer();

        if (_videoPlayerController?.value.isInitialized == false) {
          _videoPlayerController?.initialize().then((_) {
            _videoPlayerController?.play();
            // 正向执行动画：从暂停到播放
            playPauseIconAnimationController?.forward();
          });
        } else {
          // 如果播放完，跳转到开始
          if (isFinished) {
            _videoPlayerController?.seekTo(const Duration());
          }
          // 正向执行动画：从暂停到播放
          playPauseIconAnimationController?.forward();
          _videoPlayerController?.play();
        }
      }
    });
  }

  /// 底部控制栏
  AnimatedOpacity _buildBottomBar(BuildContext context) {
    final iconColor = Theme.of(context).textTheme.button?.color;

    // AnimatedOpacity:使子组件变的透明
    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: barHeight,
        //背景色：渐变
        decoration: BoxDecoration(gradient: widget.bottomGradient),
        child: Row(
          children: <Widget>[
            // 暂停和播放icon
            _buildPlayPause(_videoPlayerController!),
            // 进度条：如果是直播
            if (_chewieController?.isLive == true)
              // SizedBox:具有固定宽高的组件,适合控制2个组件之间的空隙
              const SizedBox()
            else
              _buildProgressBar(),
            // 播放时间：如果是直播
            if (_chewieController?.isLive == true)
              const Expanded(child: Text('LIVE'))
            else
              _buildPosition(iconColor ?? Colors.white),
            // 是否显示播放速度设置按钮
            if (_chewieController?.allowPlaybackSpeedChanging == true)
              _buildSpeedButton(_videoPlayerController!),
            // 静音按钮
            if (_chewieController?.allowMuting == true)
              _buildMuteButton(_videoPlayerController!),
            // 全屏按钮
            if (_chewieController?.allowFullScreen == true)
              _buildExpandButton(),
          ],
        ),
      ),
    );
  }

  ///底部控制栏的暂停和播放icon
  GestureDetector _buildPlayPause(VideoPlayerController controller) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 10.0,
          right: 10.0,
        ),
        child: Icon(
          controller.value.isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  ///底部控制栏的进度条
  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 15, left: 15),
        child: MaterialVideoProgressBar(
          _videoPlayerController!,
          // 开始拖拽
          onDragStart: () {
            setState(() {
              // 不让底部控制栏隐藏
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          // 拖拽结束
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: _chewieController?.materialProgressColors ??
              ChewieProgressColors(
                  playedColor: Theme.of(context).accentColor,
                  handleColor: Theme.of(context).accentColor,
                  bufferedColor: Theme.of(context).backgroundColor,
                  backgroundColor: Theme.of(context).disabledColor),
        ),
      ),
    );
  }

  ///底部控制栏播放时间
  Widget _buildPosition(Color iconColor) {
    // 当前播放到什么时候了
    final position = _latestValue != null && _latestValue?.position != null
        ? _latestValue?.position
        : Duration.zero;
    // 视频的总时长
    final duration = _latestValue != null && _latestValue?.duration != null
        ? _latestValue?.duration
        : Duration.zero;

    return Padding(
      padding: EdgeInsets.only(right: 5.0),
      child: Text(
        '${formatDuration(position ?? Duration())}/${formatDuration(duration ?? Duration())}',
        style: TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
  }

  /// 底部控制栏播放速度按钮
  Widget _buildSpeedButton(VideoPlayerController controller) {
    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        final chosenSpeed = await showModalBottomSheet<double>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => _PlaybackSpeedDialog(
            // 可以选择的播放速度
            allowedSpeeds: _chewieController!.playbackSpeeds,
            // 当前的播放速度
            currentSpeed: _latestValue?.playbackSpeed ?? 1,
          ),
        );

        if (chosenSpeed != null) {
          controller.setPlaybackSpeed(chosenSpeed);
        }

        if (_latestValue?.isPlaying == true) {
          _startHideTimer();
        }
      },
      child: Container(
        height: barHeight,
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: const Icon(Icons.speed),
      ),
    );
  }

  /// 底部控制栏静音按钮
  GestureDetector _buildMuteButton(VideoPlayerController controller) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue?.volume == 0) {
          // 打开声音
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          // 关闭声音，保存当前值
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: Container(
        height: barHeight,
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Icon(
          (_latestValue != null && (_latestValue?.volume ?? 0) > 0)
              ? Icons.volume_up
              : Icons.volume_off,
          color: Colors.white,
        ),
      ),
    );
  }

  ///底部控制栏全屏按钮
  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: Container(
        height: barHeight,
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Center(
          child: Icon(
            _chewieController?.isFullScreen == true
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// 底部控制栏 全屏按钮事件回调方法
  void _onExpandCollapse() {
    if (_chewieController?.videoPlayerController.value.size == null) {
      print('_onExpandCollapse:videoPlayerController.value.size is null.');
      return;
    }
    setState(() {
      _hideStuff = true;

      // 切换全屏
      _chewieController?.toggleFullScreen();
      _showAfterExpandCollapseTimer =
          Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  /// 取消并重新开始计时：隐藏时间
  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

  /// 开始隐藏时间计时
  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  /// 更新状态：重新获取视频播放的状态数据
  void _updateState() {
    setState(() {
      _latestValue = _videoPlayerController?.value;
    });
  }

  ///浮层
  _overlayUI() {
    return widget.overlayUI != null
        ? AnimatedOpacity(
            opacity: _hideStuff ? 0.0 : 1.0,
            duration: Duration(milliseconds: 300),
            child: widget.overlayUI)
        : Container();
  }
}

class _PlaybackSpeedDialog extends StatelessWidget {
  final List<double>? _allowedSpeeds;
  final double? _currentSpeed;

  const _PlaybackSpeedDialog({
    Key? key,
    required List<double> allowedSpeeds,
    required double currentSpeed,
  })  : _allowedSpeeds = allowedSpeeds,
        _currentSpeed = currentSpeed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).primaryColor;

    return ListView.builder(
      // shrinkWrap:决定列表的长度是否仅包裹其内容的长度。true,仅包裹其内容的长度。
      // 当ListView嵌在一个无限长的容器组件中时，shrinkWrap必须为true，否则Flutter会给出警告
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemBuilder: (context, index) {
        final _speed = _allowedSpeeds![index];
        return ListTile(
          // dense:使文本更小，并将所有内容打包在一起
          dense: true,
          title: Row(
            children: <Widget>[
              if (_speed == _currentSpeed)
                Icon(Icons.check, size: 20.0, color: selectedColor)
              else
                Container(width: 20.0),
              const SizedBox(width: 16.0),
              Text(_speed.toString()),
            ],
          ),
          selected: _speed == _currentSpeed,
          onTap: () {
            Navigator.of(context).pop(_speed);
          },
        );
      },
      itemCount: _allowedSpeeds?.length,
    );
  }
}
