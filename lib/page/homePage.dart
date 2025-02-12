import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/index.dart';
import 'package:auro_wallet/page/browser/index.dart';
import 'package:auro_wallet/page/settings/index.dart';
import 'package:auro_wallet/page/staking/index.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  List<String> _tabList = [
    'wallet',
    'staking',
    'browser',
    'setting',
  ];

  List<String> _tabIconsSelected = [
    'tab_home_active',
    'tab_stake_active',
    "tab_browser_active",
    'tab_setting_active',
  ];
  List<String> _tabIconsUnSelected = [
    'tab_home',
    'tab_stake',
    "tab_browser",
    'tab_setting',
  ];
  int _tabIndex = 0;

  List<BottomNavigationBarItem> _navBarItems(int activeItem) {
    Map<String, String> tabI10n = {
      'wallet': AppLocalizations.of(context)!.wallet,
      'staking': AppLocalizations.of(context)!.staking,
      'browser': AppLocalizations.of(context)!.browser,
      'setting': AppLocalizations.of(context)!.setting
    };

    bool showStaking = !store.settings!.isZekoNet;
    List<String> filteredTabList = showStaking
        ? _tabList
        : _tabList.where((tab) => tab != 'staking').toList();
    List<String> filteredTabIconsSelected = showStaking
        ? _tabIconsSelected
        : _tabIconsSelected
            .where((icon) => icon != "tab_stake_active")
            .toList();
    List<String> filteredTabIconsUnSelected = showStaking
        ? _tabIconsUnSelected
        : _tabIconsUnSelected.where((icon) => icon != "tab_stake").toList();

    return filteredTabList.asMap().keys.map((index) {
      String label = filteredTabList[index];
      String showLabel = tabI10n[label]!;
      bool isActive = filteredTabList[activeItem] == label;
      List<String> nextList =
          isActive ? filteredTabIconsSelected : filteredTabIconsUnSelected;
      String icon = 'assets/images/public/tab/${nextList[index]}.svg';

      return BottomNavigationBarItem(
          icon: Container(
            padding: EdgeInsets.only(bottom: 6, top: 10),
            child: SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
            ),
          ),
          label: showLabel);
    }).toList();
  }

  Widget _getPage(int i) {
    if (store.settings!.isZekoNet) {
      switch (i) {
        case 0:
          return Assets(store);
        case 1:
          return Browser(store);
        default:
          return Profile(store);
      }
    }
    switch (i) {
      case 0:
        return Assets(store);
      case 1:
        return Staking(store);
      case 2:
        return Browser(store);
      default:
        return Profile(store);
    }
  }

  Widget _buildPage(int i) {
    if (i == 0) {
      double statusBarHeight = MediaQuery.of(context).padding.top;
      return Scaffold(
        backgroundColor: Color(0xFFEDEFF2),
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
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarDividerColor: Colors.white,
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: _getPage(0),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: _getPage(i),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 12,
    );
    return Observer(builder: (_) {
      int maxIndex = !store.settings!.isZekoNet
          ? _tabList.length - 1
          : _tabList.length - 2;
      if (_tabIndex > maxIndex) _tabIndex = maxIndex;

      return Scaffold(
        body: _buildPage(_tabIndex),
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.black.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _tabIndex,
              backgroundColor: Colors.white,
              elevation: 0,
              iconSize: 24,
              onTap: (index) {
                setState(() {
                  int newMaxIndex = !store.settings!.isZekoNet
                      ? _tabList.length - 1
                      : _tabList.length - 2;
                  _tabIndex = index <= newMaxIndex ? index : newMaxIndex;
                });
              },
              unselectedLabelStyle: textStyle,
              selectedLabelStyle: textStyle.copyWith(color: Colors.black),
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black.withValues(alpha: 0.5),
              type: BottomNavigationBarType.fixed,
              items: _navBarItems(_tabIndex),
            ),
          ),
      );
    });
  }
}
