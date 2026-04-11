import 'package:auro_wallet/common/components/switchItem.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/settings/currenciesPage.dart';
import 'package:auro_wallet/page/settings/localesPage.dart';
import 'package:auro_wallet/service/notification_service.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/common/components/menuItem.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage(this.store);

  static final String route = '/setting/preferences';
  final AppStore store;

  @override
  _PreferencesPageState createState() => _PreferencesPageState(store);
}

class _PreferencesPageState extends State<PreferencesPage> {
  _PreferencesPageState(this.store);

  final AppStore store;
  bool _isNotificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _initNotificationState();
  }

  Future<void> _initNotificationState() async {
    final storedEnabled = NotificationService().isNotificationEnabled;
    final wasExplicitlySet = NotificationService().isNotificationExplicitlySet;
    if (storedEnabled && wasExplicitlySet) {
      final osGranted = await NotificationService().isPermissionGranted();
      if (!osGranted) {
        await NotificationService().setNotificationEnabled(false);
        if (mounted) {
          setState(() {
            _isNotificationEnabled = false;
          });
        }
        return;
      }
    }
    if (storedEnabled && !wasExplicitlySet) {
      final osGranted = await NotificationService().isPermissionGranted();
      if (mounted) {
        setState(() {
          _isNotificationEnabled = osGranted;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _isNotificationEnabled = storedEnabled;
      });
    }
  }

  Future<void> _onToggleNotification(bool isOn) async {
    if (isOn) {
      final granted = await NotificationService().requestPermission();
      if (granted) {
        await NotificationService().setNotificationEnabled(true);
        if (mounted) {
          setState(() {
            _isNotificationEnabled = true;
          });
        }
      } else {
        if (mounted) {
          AppLocalizations dic = AppLocalizations.of(context)!;
          UI.toast(dic.failed);
        }
      }
    } else {
      await NotificationService().setNotificationEnabled(false);
      if (mounted) {
        setState(() {
          _isNotificationEnabled = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.preferences),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Observer(
        builder: (_) {
          var languageCode = store.settings!.localeCode.isNotEmpty
              ? store.settings!.localeCode
              : dic.localeName.toLowerCase();
          return SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: <Widget>[
                    SwitchItem(
                      text: dic.notificationEnable,
                      onClick: (isOn) => _onToggleNotification(isOn),
                      isOn: _isNotificationEnabled,
                    ),
                    MenuItem(
                      text: dic.language,
                      value: languageConfig[languageCode],
                      onTap: () =>
                          Navigator.of(context).pushNamed(LocalesPage.route),
                    ),
                    MenuItem(
                      text: dic.currency,
                      value: store.settings?.currencyCode.toUpperCase(),
                      onTap: () =>
                          Navigator.of(context).pushNamed(CurrenciesPage.route),
                    ),
                  ],
                )),
          );
        },
      ),
    );
  }
}
