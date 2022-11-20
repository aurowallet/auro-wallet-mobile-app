import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/page/account/import/importSuccessPage.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';

class BackupMnemonicPage extends StatefulWidget {
  const BackupMnemonicPage(this.store);

  static final String route = '/account/backup';
  final AppStore store;

  @override
  _BackupMnemonicPageState createState() => _BackupMnemonicPageState(store);
}

class _BackupMnemonicPageState extends State<BackupMnemonicPage> {
  _BackupMnemonicPageState(this.store);

  final AppStore store;

  int _step = 0;

  late List<String> _wordsSelected;
  late List<String> _wordsLeft;
  bool submitting = false;

  @override
  void initState() {
    webApi.account.generateMnemonic();
    super.initState();
  }

  Widget _buildStep0(BuildContext context) {
    return Observer(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).main['backTips_title']!),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: 16),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        I18n.of(context).main['show_seed_content']!,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: _buildWords(
                            store.wallet!.newWalletParams.seed.split(' '),
                            false))
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 38, vertical: 30),
                child: NormalButton(
                  text: I18n.of(context).main['show_seed_button']!,
                  onPressed: () {
                    setState(() {
                      _step = 1;
                      _wordsSelected = <String>[];
                      _wordsLeft =
                          store.wallet!.newWalletParams.seed.split(' ');
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    setState(() {
      submitting = true;
    });
    var acc = await webApi.account.importWalletByWalletParams();
    await webApi.account.saveWallet(acc,
        context: context,
        seedType: WalletStore.seedTypeMnemonic,
        walletSource: WalletSource.inside);
    await Navigator.pushNamedAndRemoveUntil(
        context, ImportSuccessPage.route, (Route<dynamic> route) => false,
        arguments: {'type': 'create'});
  }

  Widget _buildStep1(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).main['backTips_title']!),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              _step = 0;
            });
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Text(
                      I18n.of(context).main['backupInOrder']!,
                      style: Theme.of(context).textTheme.headline6!,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: _buildWords(_wordsSelected, true),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20), child:  Divider(),),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: _buildWordsButtons(),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 38, vertical: 30),
              child: NormalButton(
                submitting: submitting,
                text: I18n.of(context).main['next']!,
                onPressed: _wordsSelected.length ==
                        store.wallet!.newWalletParams.seed.split(' ').length
                    ? () async {
                        if (_wordsSelected.join(' ') !=
                            store.wallet!.newWalletParams.seed) {
                          UI.toast(I18n.of(context).main['seed_incorrect']!);
                          setState(() {
                            _wordsLeft.clear();
                            _wordsLeft.addAll(
                                store.wallet!.newWalletParams.seed.split(' '));
                            _wordsSelected.clear();
                          });
                          return;
                        }
                         _save();
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWords(List<String> words, bool clickable) {
    List<Widget> cells = <Widget>[];
    for (var index = 0; index < 12; index++) {
      bool isEmpty = index >= words.length;
      String word = isEmpty ? '' : words[index];
      cells.add(
        GestureDetector(
          child: Container(
            // margin: EdgeInsets.only(left: 3, right: 3, bottom: 10),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isEmpty ? Color(0x33C4C4C4): Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              '${index + 1}. ${isEmpty ?  '' : word}',
              style: Theme.of(context).textTheme.headline6!.copyWith(color: isEmpty ? Color(0x80000000) : Colors.white),
            ),
          ),
          onTap: clickable
              ? () {
                  setState(() {
                    _wordsLeft.add(word);
                    _wordsSelected.remove(word);
                  });
                }
              : null,
        ),
      );
    }
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 10,
      childAspectRatio: 3.4666,
      children: cells,
    );

    return Container(
      padding: EdgeInsets.only(top: 0),
      child: Wrap(
        children: cells,
      ),
    );
  }

  Widget _buildWordsButtons() {
    if (_wordsLeft.length > 0) {
      _wordsLeft.sort();
    }

    List<Widget> cells = <Widget>[];
    for (var index = 0; index < _wordsLeft.length; index++) {
      String word = _wordsLeft[index];
      cells.add(Container(
          padding: EdgeInsets.only(left: 4, right: 4),
          child: GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorsUtil.hexColor(0xe4e4e4),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Text(
                '$word',
                style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: Color(0xFF000000)
                ),
              ),
            ),
            onTap: () {
              setState(() {
                _wordsLeft.remove(word);
                _wordsSelected.add(word);
              });
            },
          )));
    }
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 10,
      childAspectRatio: 3.4666,
      children: cells,
    );
    return Container(
      child: Wrap(
        children: cells,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 0:
        return _buildStep0(context);
      case 1:
        return _buildStep1(context);
      default:
        return Container();
    }
  }
}
