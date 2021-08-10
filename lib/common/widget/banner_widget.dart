import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pan/common/utils/cache_image.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';


class BannerWidget extends StatefulWidget {
  final List<BannerModel> banners;
  final SwiperOnTap? onItemTap;

  const BannerWidget({Key? key, required this.banners, this.onItemTap}) : super(key: key);

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  @override
  Widget build(BuildContext context) {
    return Swiper(
        autoplay: true,
        itemCount: widget.banners.length,
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            children: <Widget>[
              Container(
                // decoration:装饰,设置子控件的背景颜色、形状等
                decoration: BoxDecoration(
                  image: DecorationImage(
                    // 网络获取图片
                    image: cachedNetworkImageProvider(
                        widget.banners[index].imgUrl),
                    // 图片显示样式,类似Android缩放设置
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // banner底部透明黑条
              Positioned(
                // 默认显示内容宽度
                width: MediaQuery.of(context).size.width - 30,
                // 放于底部
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
                  // decoration:装饰,设置子控件的背景颜色、形状等
                  decoration: BoxDecoration(color: Colors.black12),
                  child: Text(
                    widget.banners[index].title??"",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              )
            ],
          );
        },
        onTap: widget.onItemTap,
        // banner 指示器
        pagination: new SwiperPagination(
          // 位置：右下角
          alignment: Alignment.bottomRight,
          // 指示器的样式
          builder: DotSwiperPaginationBuilder(
              size: 8,
              activeSize: 8,
              activeColor: Colors.white,
              color: Colors.white24),
        )
    );
  }
}

class BannerModel {
  final String? title;
  final String? desc;
  final String imgUrl;
  final String? routerUrl;

  BannerModel(this.imgUrl,{this.title, this.desc, this.routerUrl});
}
