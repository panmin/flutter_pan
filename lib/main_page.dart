import 'package:flutter/material.dart';
import 'package:flutter_pan/common/base/base_change_notifier.dart';
import 'package:flutter_pan/common/utils/toast.dart';
import 'package:flutter_pan/common/widget/provider_widget.dart';
import 'package:provider/provider.dart';

/// 主页
/// 相当于Android里面的MainActivity
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PageController _pageController;
  late List<BottomNavigationBarItem> listItem;

  DateTime? _dateTime;

  @override
  void initState() {
    _pageController = new PageController();
    listItem = [
      _buildBottomItem(Icons.home, "首页"),
      _buildBottomItem(Icons.search, "发现"),
      _buildBottomItem(Icons.whatshot_outlined, "热门"),
      _buildBottomItem(Icons.person, "我的"),
    ];
    super.initState();
  }

  BottomNavigationBarItem _buildBottomItem(IconData icon, String name) {
    return BottomNavigationBarItem(icon: Icon(icon), label: name);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          children: [
            Container(
              color: Colors.blue,
            ),
            Container(
              color: Colors.yellow,
            ),
            Container(
              color: Colors.green,
            ),
            Container(
              color: Colors.red,
            ),
          ],
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: ProviderWidget<TabNavigationViewModel>(
          model: TabNavigationViewModel(),
          builder: (context,TabNavigationViewModel model,child){
            return BottomNavigationBar(
              currentIndex: model.index,
              items: listItem,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 14,
              unselectedFontSize: 14,
              onTap: (index) {
                if(model.index!=index) {
                  _pageController.jumpToPage(index);
                  model.setBottomBarIndex(index);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async{
    if(_dateTime==null){
      _dateTime = DateTime.now();
      ToastUtil.show("再按一次退出");
      return false;
    }else if(DateTime.now().difference(_dateTime!)>Duration(seconds: 1)){
      _dateTime = DateTime.now();
      ToastUtil.show("再按一次退出");
      return false;
    }else{
      return true;
    }
  }
}

class TabNavigationViewModel extends BaseChangeNotifier{
  int index = 0;
  void setBottomBarIndex(int index){
    this.index = index;
    notifyListeners();
  }
}
