import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pan/common/base/base_state.dart';
import 'package:flutter_pan/common/utils/cache_image.dart';
import 'package:flutter_pan/common/widget/provider_widget.dart';
import 'package:flutter_pan/common/widget/video_player_widget.dart';
import 'package:flutter_pan/home/home_model.dart';
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
    extends BaseState<VideoDetailViewModel, VideoDetailPage> with WidgetsBindingObserver {
  @override
  String? get title => null;

  GlobalKey<VideoPlayerWidgetState> _videoPlayerKey = new GlobalKey<VideoPlayerWidgetState>();

  @override
  VideoDetailViewModel get viewModel => VideoDetailViewModel(widget.detailId);

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused){
      _videoPlayerKey.currentState?.pause();
    }else if(state == AppLifecycleState.resumed){
      _videoPlayerKey.currentState?.play();
    }
  }
  @override
  void dispose() {
    _videoPlayerKey.currentState?.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget getChild(VideoDetailViewModel model) {
    print("id=${widget.detailId}");
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          children: [
            VideoPlayerWidget(
              key: _videoPlayerKey,
              url: widget.url,
              videoTopBarMarginTop: MediaQuery.of(context).padding.top,
            ),
            _videoInfoWidget(model.currentInfo)
          ],
        ),
      ),
    );
  }

  Widget _videoInfoWidget(ItemList? currentInfo) {
    var data = currentInfo?.data;
    if (data == null) {
      return SizedBox();
    }
    return Expanded(
      child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                  image: cachedNetworkImageProvider('${data.cover?.blurred}}/thumbnail/${MediaQuery.of(context).size.height}x${MediaQuery.of(context).size.width}'))),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title ?? "",
                      style: TextStyle(),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}
