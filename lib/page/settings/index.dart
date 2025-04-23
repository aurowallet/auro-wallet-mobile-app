import 'package:auro_wallet/common/components/tabPageTitle.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/settings/WalletConnectPage.dart';
import 'package:auro_wallet/page/settings/aboutPage.dart';
import 'package:auro_wallet/page/settings/components/settingItem.dart';
import 'package:auro_wallet/page/settings/contact/contactListPage.dart';
import 'package:auro_wallet/page/settings/currenciesPage.dart';
import 'package:auro_wallet/page/settings/localesPage.dart';
import 'package:auro_wallet/page/settings/nodes/RemoteNodeListPage.dart';
import 'package:auro_wallet/page/settings/security/securityPage.dart';
import 'package:auro_wallet/page/settings/zkAppConnectPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/page/settings/preferences/preferencesPage.dart';
class Profile extends StatelessWidget {
  Profile(this.store);

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      AppLocalizations dic = AppLocalizations.of(context)!;
      var languageCode = store.settings!.localeCode.isNotEmpty
          ? store.settings!.localeCode
          : dic.localeName.toLowerCase();
      return Scaffold(
        appBar: AppBar(
          leading: null,
          title: null,
          toolbarHeight: 0,
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          maintainBottomViewPadding: true,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TabPageTitle(title: dic.setting),
            Expanded(
                child: ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 0),
                  padding: EdgeInsets.only(left: 16, right: 10),
                  child: Column(
                    children: [
                      SettingItem(
                        icon: 'assets/images/setting/perference.svg', 
                        title: dic.perferences,
                        onTap: () =>
                            Navigator.of(context).pushNamed(PreferencesPage.route),
                      ),
                      SettingItem(
                        icon: 'assets/images/setting/security.svg',
                        title: dic.security,
                        onTap: () =>
                            Navigator.of(context).pushNamed(SecurityPage.route),
                      ),
                      SettingItem(
                        icon: 'assets/images/setting/icon_connect.svg',
                        title: dic.appConnection,
                        value: (store.browser?.zkAppConnectingList.length ?? 0).toString(),
                        onTap: () => Navigator.of(context)
                            .pushNamed(ZkAppConnectPage.route),
                      ),
                       SettingItem(
                        icon: 'assets/images/setting/icon_walletconnect.svg',
                        title: dic.walletConnectTitle,
                        value: (store.walletConnectService?.getAllPairedLinks().length ?? 0).toString(),
                        onTap: () => Navigator.of(context)
                            .pushNamed(WalletConnectPage.route)
                                  .then((_) {
                                store.walletConnectService?.getAllPairedLinks();
                              }),
                      ),
                      SettingItem(
                        icon: 'assets/images/setting/network.svg',
                        title: dic.network,
                        value: Fmt.stringSlice(
                            store.settings!.currentNode!.name, 12,
                            withEllipsis: true),
                        onTap: () => Navigator.of(context)
                            .pushNamed(RemoteNodeListPage.route),
                      ),
                      SettingItem(
                        icon: 'assets/images/setting/contact.svg',
                        title: dic.addressbook,
                        value: store.settings?.contactList.length.toString(),
                        onTap: () => Navigator.of(context)
                            .pushNamed(ContactListPage.route),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0.5,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: Color(0x1A000000)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Column(children: [
                    SettingItem(
                      icon: 'assets/images/setting/aboutus.svg',
                      title: dic.about,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AboutPage.route),
                    ),
                  ]),
                ),
              ],
            ))
          ]),
        ),
      );
    });
  }
}
