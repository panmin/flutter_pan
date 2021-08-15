import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pan/common/base/base_state.dart';
import 'package:flutter_pan/common/widget/video_player_widget.dart';
import 'package:flutter_pan/video_detail/video_detail_viewmodel.dart';

/// 视频详情页
class VideoDetailPage extends StatefulWidget {
  final String url;
  final String detailId;

  const VideoDetailPage({Key? key, required this.url, required this.detailId})
      : super(key: key);

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState
    extends BaseState<VideoDetailViewModel, VideoDetailPage> {
  @override
  String? get title => null;

  @override
  VideoDetailViewModel get viewModel => VideoDetailViewModel();

  @override
  Widget getChild(VideoDetailViewModel model) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: VideoPlayerWidget(
          url: widget.url,
          videoTopBarMarginTop: MediaQuery.of(context).padding.top,
        ),
      ),
    );
  }
}
