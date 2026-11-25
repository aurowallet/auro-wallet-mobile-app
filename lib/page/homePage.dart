import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/index.dart';
import 'package:auro_wallet/page/browser/index.dart';
import 'package:auro_wallet/page/settings/index.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/material.dart';
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
    'browser',
    'setting',
  ];

  List<String> _tabIconsSelected = [
    'tab_home_active',
    "tab_browser_active",
    'tab_setting_active',
  ];
  List<String> _tabIconsUnSelected = [
    'tab_home',
    "tab_browser",
    'tab_setting',
  ];
  int _tabIndex = 0;

  List<BottomNavigationBarItem> _navBarItems(int activeItem) {
    Map<String, String> tabI10n = {
      'wallet': AppLocalizations.of(context)!.wallet,
      'browser': AppLocalizations.of(context)!.browser,
      'setting': AppLocalizations.of(context)!.setting
    };

    return _tabList.asMap().keys.map((index) {
      String label = _tabList[index];
      String showLabel = tabI10n[label]!;
      bool isActive = activeItem == index;
      List<String> nextList = isActive
          ? _tabIconsSelected
          : _tabIconsUnSelected;
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
    switch (i) {
      case 0:
        return Assets(store);
      case 1:
        return Browser(store);
      default:
        return Profile(store);
    }
  }

  Widget _buildPage(int i) {
    if (i == 0) {
      return Scaffold(
        backgroundColor: Color(0xFFEDEFF2),
        appBar: AppBar(
          leading: null,
          title: null,
          toolbarHeight: 0,
          backgroundColor: Color(0xFFEDEFF2),
          actions: null,
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
    initWalletConnect();
  }

  Future<void> initWalletConnect() async {
    store.walletConnectService!.setContext(context);
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
              _tabIndex = index;
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
  }
}
