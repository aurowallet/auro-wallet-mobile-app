import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/backgroundContainer.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/page/assets/index.dart';
import 'package:auro_wallet/page/settings/index.dart';
import 'package:auro_wallet/page/staking/index.dart';
import 'package:auro_wallet/service/notification.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';

class HomePage extends StatefulWidget {
  HomePage(this.store);

  static final String route = '/';
  final AppStore store;

  @override
  _HomePageState createState() => new _HomePageState(store);
}

class _HomePageState extends State<HomePage> {
  _HomePageState(this.store);

  final AppStore store;


  NotificationPlugin? _notificationPlugin;

  List<String> _tabList = [
    'wallet',
    'staking',
    'setting',
  ];
  List<String> _tabIcons = [
    'home_tab',
    'stake_tab',
    'setting_tab',
  ];
  int _tabIndex = 0;

  List<BottomNavigationBarItem> _navBarItems(int activeItem) {
    Map<String, String> tabs = I18n.of(context).main;
    var theme = Theme.of(context).textTheme;
    return _tabList.asMap().keys.map((index) {
      String icon = 'assets/images/public/${_tabIcons[index]}.svg';
      String label = _tabList[index];
      Color tabColor = _tabList[activeItem] == label
          ? Theme.of(context).primaryColor
          : ColorsUtil.hexColor(0x898DA2);
      return BottomNavigationBarItem(
        icon: SvgPicture.asset(
          icon,
          color: tabColor,
          height: 20,
        ),
        title: Text(
          tabs[label]!,
          style: theme.headline6!.copyWith(
              color: tabColor,
        )),
      );
    }).toList();
  }

  Widget _getPage(i) {
    switch (i) {
      case 0:
        return Assets(store);
      case 1:
        return Staking(store);
      default:
        return Profile(store);
    }
  }

  Widget _buildPage(i) {
    if (i == 0) {
      double statusBarHeight = MediaQuery.of(context).padding.top;
      // return assets page
      return BackgroundContainer(
        AssetImage("assets/images/assets/2x/top_header_bg@2x.png"),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: true,
            leading: null,
            title: null,
            toolbarHeight: 0,
            titleSpacing: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            actions: null,
          ),
          body: _getPage(0),
        ),
        maxHeight: 240 + statusBarHeight,
        fit: BoxFit.fill,
      );
    }
    // return staking page
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _getPage(i),
    );
  }

  @override
  void initState() {
    if (_notificationPlugin == null) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _notificationPlugin = NotificationPlugin();
        _notificationPlugin!.init(context);

      });
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(_tabIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        iconSize: 22.0,
        onTap: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: _navBarItems(_tabIndex),
      ),
    );
  }
}
