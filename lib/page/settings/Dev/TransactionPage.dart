import 'dart:convert';

import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/settings/Dev/constants.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class TransactionPage extends StatefulWidget {
  TransactionPage(this.store);

  final AppStore store;

  static final String route = '/setting/dev/transaction';

  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<TransactionPage> {
  bool isLoading = false;
  String responseBody = "";
  late DevPageTypes pageType;
  late String pageTitle = "UNKNOWN";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      DevPageTypes nextPageType = params?['type'] ?? null;
      String nextPageTitle = params?['title'] ?? "UNKNOWN";
      setState(() {
        pageType = nextPageType;
        pageTitle = nextPageTitle;
      });
      _fetchData();
    });
    super.initState();
  }

  _fetchData() async {
    setState(() {
      isLoading = true;
    });
    dynamic result;
    if (pageType == DevPageTypes.transaction) {
      result = await webApi.assets.fetchFullTransactions(
          widget.store.wallet!.currentAddress,
          isDev: true);
    } else if (pageType == DevPageTypes.pendingTx) {
      result = await webApi.assets.fetchPendingTransactions(
          widget.store.wallet!.currentAddress,
          isDev: true);
    } else if (pageType == DevPageTypes.pendingZkTx) {
      result = await webApi.assets.fetchPendingZkTransactions(
          widget.store.wallet!.currentAddress,
          isDev: true);
    } else if (pageType == DevPageTypes.balance) {
      result = await webApi.assets
          .fetchAllTokenAssets(showIndicator: false, isDev: true);
    }
    setState(() {
      responseBody = jsonEncode(result);
      isLoading = false;
    });
  }

  void _onCopyResult() async {
    String copyContent = jsonEncode({
      "address": widget.store.wallet!.currentAddress,
      "responseBody": responseBody,
      "type": pageType.toString(),
    });
    UI.copyAndNotify(context, copyContent);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text(pageTitle),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent)),
            child: Text(
              dic.copy,
              style: TextStyle(
                  fontSize: 14, color: Theme.of(context).primaryColor),
            ),
            onPressed: _onCopyResult,
          ),
        ],
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Observer(
          builder: (_) {
            return Column(children: [
              Expanded(
                  child: ListView(children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AccountInfoItem(
                        label: dic.accountAddress,
                        value: widget.store.wallet!.currentAddress,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(bottom: 10, left: 20, right: 20),
                        height: 1,
                        decoration: BoxDecoration(
                          color: Color(0x1A000000),
                        ),
                      ),
                      isLoading
                          ? Ink(
                              color: Color(0xFFFFFFFF),
                              child: Container(
                                child: Center(
                                  child: LoadingCircle(),
                                ),
                              ))
                          : AccountInfoItem(
                              label: dic.response,
                              value: responseBody,
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                            ),
                    ],
                  ),
                )
              ])),
              Container(
                padding:
                    EdgeInsets.only(left: 38, right: 38, top: 12, bottom: 30),
                child: NormalButton(
                  text: dic.retry,
                  onPressed: () {
                    _fetchData();
                  },
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class AccountInfoItem extends StatelessWidget {
  AccountInfoItem(
      {required this.label, this.value, this.onClick, this.padding});

  final String label;
  final String? value;
  final EdgeInsets? padding;
  final void Function()? onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onClick,
        child: Container(
            constraints: BoxConstraints(minHeight: 55),
            padding: padding?.copyWith(left: 20, right: 20) ??
                EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                      value == null || value!.isEmpty
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(value!,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      height: 1.2)))
                    ],
                  ),
                ),
              ],
            )));
  }
}
