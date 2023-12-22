import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/page/assets/index.dart';
import 'package:auro_wallet/page/settings/index.dart';
import 'package:auro_wallet/page/staking/index.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/services.dart';
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
    'setting',
  ];
  List<String> _tabIcons = [
    'home_tab',
    'stake_tab',
    'setting_tab',
  ];
  int _tabIndex = 0;

  List<BottomNavigationBarItem> _navBarItems(int activeItem) {
    Map<String, String> tabI10n = {
      'wallet':AppLocalizations.of(context)!.wallet,
      'staking':AppLocalizations.of(context)!.staking,
      'setting':AppLocalizations.of(context)!.setting
    };
    return _tabList.asMap().keys.map((index) {
      String icon = 'assets/images/public/${_tabIcons[index]}.svg';
      String label = _tabList[index];
      String showLabel = tabI10n[label]!;
      Color tabColor = _tabList[activeItem] == label
          ? Colors.black
          : Colors.black.withOpacity(0.5);
      return BottomNavigationBarItem(
          icon: Container(
            padding: EdgeInsets.only(bottom: 6, top: 10),
            child: SvgPicture.asset(
              icon,
              color: tabColor,
            ),
          ),
          label: showLabel
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
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        resizeToAvoidBottomInset: false,
        body: _getPage(0),
      );
    }
    // return staking page
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
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
                color: Colors.black.withOpacity(0.1),
                width: 0.5
            )
          )
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
          selectedLabelStyle: textStyle.copyWith(
              color: Colors.black
          ),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black.withOpacity(0.5),
          type: BottomNavigationBarType.fixed,
          items: _navBarItems(_tabIndex),
        ),
      ),
    );
  }
}
