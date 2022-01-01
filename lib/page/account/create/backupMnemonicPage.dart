import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';


import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: 16),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Text(
                        I18n.of(context).main['show_seed_content']!,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16, top: 20),
                      child: _buildWords(store.wallet!.newWalletParams.seed.split(' '), false)
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: NormalButton(
                  text: I18n.of(context).main['show_seed_button']!,
                  onPressed: () {
                    setState(() {
                      _step = 1;
                      _wordsSelected = <String>[];
                      _wordsLeft = store.wallet!.newWalletParams.seed.split(' ');
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 30, right: 30),
                    child: Text(
                      I18n.of(context).main['backupInOrder']!,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 16, right: 16),
                    child: _buildWords(_wordsSelected, true),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 16, right: 16),
                    child: _buildWordsButtons(),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: NormalButton(
                text: I18n.of(context).main['next']!,
                onPressed:
                _wordsSelected.length == store.wallet!.newWalletParams.seed.split(' ').length
                    ? () async  {
                  if (_wordsSelected.join(' ') != store.wallet!.newWalletParams.seed) {
                    UI.toast(I18n.of(context).main['seed_error']!);
                    setState(() {
                      _wordsLeft.clear();
                      _wordsLeft.addAll(store.wallet!.newWalletParams.seed.split(' '));
                      _wordsSelected.clear();
                    });
                    return;
                  }
                  final Map args = ModalRoute.of(context)!.settings.arguments as Map;
                  Future<void> Function(bool) callback = args['callback'];
                  if (callback != null) {
                    await callback(true);
                  } else {
                    Navigator.of(context).pop(true);
                  }
                } : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildWords(List<String> words, bool clickable) {
    List<Widget> cells = <Widget>[];
    for (var index = 0; index < words.length; index++) {
      String word = words[index];
      cells.add(
          GestureDetector(
            child: Container(
              margin:  EdgeInsets.only(left: 3, right: 3, bottom: 10),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ColorsUtil.hexColor(0x02A8FF),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Text(
                '${index + 1}. $word',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                ),
              ),
            ),
            onTap: clickable ? () {
              setState(() {
                _wordsLeft.add(word);
                _wordsSelected.remove(word);
              });
            } : null,
          )
      );
    }
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
      cells.add(
          Container(
              padding: EdgeInsets.only(left: 4, right: 4),
              child:
              GestureDetector(
                child: Container(
                  margin:  EdgeInsets.only(left: 3, right: 3, bottom: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: ColorsUtil.hexColor(0xe4e4e4),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Text(
                    '$word',
                    style: TextStyle(
                        color: ColorsUtil.hexColor(0x333333),
                        fontSize: 16
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _wordsLeft.remove(word);
                    _wordsSelected.add(word);
                  });
                },
              )
          )
      );
    }
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
