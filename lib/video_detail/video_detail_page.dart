import 'package:flutter/material.dart';
import 'package:flutter_pan/common/base/base_state.dart';
import 'package:flutter_pan/video_detail/video_detail_viewmodel.dart';

/// 视频详情页
class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({Key? key}) : super(key: key);

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends BaseState<VideoDetailViewModel,VideoDetailPage> {

  @override
  String? get title => null;

  @override
  VideoDetailViewModel get viewModel => VideoDetailViewModel();

  @override
  Widget getChild(VideoDetailViewModel model) {

    return Container(
      child: Center(
        child: Text("视频详情"),
      ),
    );
  }
}
