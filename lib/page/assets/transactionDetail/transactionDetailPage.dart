import 'dart:convert';

import 'package:auro_wallet/common/components/browserLink.dart';
import 'package:auro_wallet/common/components/copyContainer.dart';
import 'package:auro_wallet/common/components/customDivider.dart';
import 'package:auro_wallet/common/components/scamTag.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/service/tx_status_monitor.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/zkUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionDetailPage extends StatefulWidget {
  TransactionDetailPage(this.store);

  static final String route = '/assets/tx';
  final AppStore store;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  bool _isLoading = false;
  bool _hasError = false;
  bool _isFetching = false;
  TransferData? _txData;
  bool _initialized = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  String? _argTxUrl;
  String? _argExplorerUrl;
  String? _argSenderAddress;
  bool _argIsZeko = false;

  void _initFromArgs() {
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map) {
      _hasError = true;
      return;
    }

    _argTxUrl = args['txUrl'] is String ? args['txUrl'] as String : null;
    _argExplorerUrl = args['explorerUrl'] is String ? args['explorerUrl'] as String : null;
    _argSenderAddress = args['senderAddress'] is String ? args['senderAddress'] as String : null;
    _argIsZeko = args['isZeko'] == true;

    if (args['data'] is TransferData) {
      _txData = args['data'] as TransferData;
    } else if (args['txHash'] is String) {
      final hash = args['txHash'] as String;
      if (isValidMinaTxHash(hash)) {
        _isLoading = true;
        _loadTxByHash(hash);
      } else {
        _hasError = true;
      }
    } else {
      _hasError = true;
    }
  }

  Future<void> _loadTxByHash(String hash) async {
    if (_isFetching) return;
    _isFetching = true;
    if (mounted && _retryCount > 0) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    } else {
      _isLoading = true;
      _hasError = false;
    }
    try {
      final archiveUrl = (_argTxUrl != null && _argTxUrl!.isNotEmpty)
          ? _argTxUrl!
          : (TxStatusMonitor().getArchiveUrl() ?? '');
      if (archiveUrl.isEmpty) {
        _isFetching = false;
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
        return;
      }
      TransferData? txData;
      if (_argIsZeko && _argSenderAddress != null && _argSenderAddress!.isNotEmpty) {
        txData = await TxStatusMonitor().fetchZekoTransactionByHash(hash, archiveUrl, _argSenderAddress!);
      } else if (_argIsZeko) {
        _isFetching = false;
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
        return;
      } else {
        txData = await TxStatusMonitor().fetchTransactionByHash(hash, archiveUrl);
      }
      _isFetching = false;
      if (!mounted) return;
      if (txData != null) {
        _retryCount = 0;
        setState(() {
          _txData = txData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (_) {
      _isFetching = false;
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initFromArgs();
  }

  void _handleErrorTap() {
    if (_isLoading) return;
    if (_retryCount >= _maxRetries) return;
    _retryCount++;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args.containsKey('txHash') && args['txHash'] is String) {
      final hash = args['txHash'] as String;
      if (isValidMinaTxHash(hash)) {
        _loadTxByHash(hash);
      }
    }
  }

  Widget _buildLabel(String name) {
    return Container(
        padding: EdgeInsets.only(left: 0),
        child: Text(name,
            style: TextStyle(
                color: Color(0xFF808080),
                fontWeight: FontWeight.w500,
                fontSize: 12)));
  }

  String capitalize(String s) {
    if (s.isNotEmpty && s.length > 1) {
      return s[0].toUpperCase() + s.substring(1);
    }
    return s;
  }

  List<Widget> _buildListView(BuildContext context, TransferData tx, Map params) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    String txKindLow = tx.type.toLowerCase();

    String tokenId = params['tokenId'] ?? ZK_DEFAULT_TOKEN_ID;
    int tokenDecimal = (params['tokenDecimal'] is int)
        ? params['tokenDecimal'] as int
        : (params['tokenDecimal'] is String)
            ? (int.tryParse(params['tokenDecimal'] as String) ?? COIN.decimals)
            : COIN.decimals;
    String tokenSymbol = params['tokenSymbol'] ?? COIN.coinSymbol;

    bool isMainToken = tokenId == ZK_DEFAULT_TOKEN_ID;

    String symbol = isMainToken ? COIN.coinSymbol : tokenSymbol;
    int decimals = isMainToken ? COIN.decimals : tokenDecimal;
    Map? tokenTxData;

    final myAddress = (_argSenderAddress != null && _argSenderAddress!.isNotEmpty)
        ? _argSenderAddress!
        : widget.store.wallet!.currentAddress;

    String? showToAddress = "";
    String showAmount;
    if (!isMainToken) {
      if (txKindLow == "zkapp_token") {
        showToAddress = tx.receiver;
        showAmount = Fmt.balance(tx.amount, tokenDecimal,
                minLength: 4, maxLength: tokenDecimal) +
            " " +
            tokenSymbol;
        tokenTxData = {"isZkReceive": false};
      } else if (tx.transaction != null && tx.transaction!.isNotEmpty) {
        Map txData = jsonDecode(tx.transaction!);
        List<dynamic> accountUpdates = txData['accountUpdates'];
        Map<String, dynamic> updateInfo = getZkAppUpdateInfo(accountUpdates,
            myAddress, tx.sender ?? "", tokenId);
        tokenTxData = updateInfo;
        showToAddress = updateInfo['to'];
        String amount = Fmt.balance(
            updateInfo['totalBalanceChange'], tokenDecimal,
            minLength: 4, maxLength: tokenDecimal);
        showAmount = amount + " " + tokenSymbol;
      } else {
        showToAddress = tx.receiver;
        showAmount = Fmt.balance(tx.amount, decimals,
                minLength: 4, maxLength: decimals) +
            " " + symbol;
      }
    } else {
      if (txKindLow == "zkapp" && tx.transaction != null && tx.transaction!.isNotEmpty) {
        Map txData = jsonDecode(tx.transaction!);
        List<dynamic> accountUpdates = txData['accountUpdates'];
        Map<String, dynamic> updateInfo = getZkAppUpdateInfo(
          accountUpdates,
          myAddress,
          tx.sender ?? "",
          tokenId,
        );
        showToAddress = updateInfo['to'];
        showAmount =
            '${Fmt.balance(updateInfo['totalBalanceChange'], decimals, minLength: 4, maxLength: tokenDecimal)} $symbol';
      } else {
        showToAddress = tx.receiver;
        showAmount =
            '${Fmt.balance(tx.amount, decimals, minLength: 4, maxLength: decimals)} $symbol';
      }
    }
    String statusIcon;
    String statusText;
    Color statusColor;
    switch (tx.status) {
      case 'applied':
        statusText = dic.applied;
        statusColor = ColorsUtil.hexColor(0x38d79f);
        break;
      case 'failed':
        statusText = dic.failed;
        statusColor = ColorsUtil.hexColor(0xE84335);
        break;
      case 'pending':
        statusText = dic.pending;
        statusColor = ColorsUtil.hexColor(0xFFC633);
        break;
      case 'signed':
        statusText = dic.signed;
        statusColor = ColorsUtil.hexColor(0xFFC633);
        break;
      default:
        statusText = tx.status.toUpperCase();
        statusColor = ColorsUtil.hexColor(0xFFC633);
        break;
    }

    bool isCommonTx = txKindLow != "zkapp" && txKindLow != "zkapp_token";

    String txType = tx.type;
    if (txKindLow == "stake_delegation") {
      txType = "delegation";
    }

    if (isCommonTx) {
      txType = capitalize(txType);
    }
    if (txKindLow == "zkapp_token") {
      txType = "zkApp Token";
    }
    bool isOut = tx.sender == myAddress;
    switch (txKindLow) {
      case 'delegation':
      case 'stake_delegation':
        {
          statusIcon = 'record_stake';
        }
        break;
      case "zkapp":
      case "zkapp_token":
        if (!isMainToken) {
          statusIcon = tokenTxData?['isZkReceive'] == true ? 'tx_in' : 'tx_out';
        } else {
          statusIcon = 'tx_zkapp';
        }
        break;
      default:
        {
          statusIcon = isOut ? 'record_out' : 'record_in';
        }
        break;
    }

    final items = [
      TxInfoItem(label: dic.txType, title: txType),
      TxInfoItem(label: dic.amount, title: showAmount),
      TxInfoItem(
        label: dic.toAddress,
        title: showToAddress,
        copyText: showToAddress,
      ),
      TxInfoItem(
          label: dic.fromAddress,
          title: tx.sender,
          copyText: tx.sender,
          showScamTag: tx.isFromAddressScam == true),
      TxInfoItem(label: dic.memo2, title: tx.memo, copyText: tx.memo),
      TxInfoItem(
        label: 'Nonce',
        title: tx.nonce != null ? tx.nonce.toString() : null,
      ),
      tx.fee != null
          ? TxInfoItem(
              label: dic.fee,
              title:
                  '${Fmt.balance(tx.fee!, COIN.decimals, maxLength: COIN.decimals)} ${COIN.coinSymbol}',
            )
          : null,
      TxInfoItem(
        label: dic.time,
        title: txKindLow == "zkapp_token"
            ? Fmt.dateTimeWithTimeZoneFromTimestamp(int.parse(tx.time ?? "0"))
            : Fmt.dateTimeWithTimeZone(tx.time),
      ),
      TxInfoItem(
        label: dic.txHash,
        title: tx.hash,
        copyText: tx.hash,
      ),
    ];
    var list = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Container(
                width: 48,
                height: 48,
                decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(48.0)),
                    color: statusColor),
                child: SvgPicture.asset('assets/images/assets/$statusIcon.svg',
                    width: 48,
                    height: 48,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              )),
          Text(statusText,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          CustomDivider(margin: const EdgeInsets.only(top: 20)),
        ],
      ),
    ];
    items.forEach((i) {
      if (i == null || i.title == null || i.title!.isEmpty) {
        return;
      }
      var baseCon = Container(
          padding: EdgeInsets.only(top: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildLabel(i.label),
            CopyContainer(
              child: RichText(
                  text: TextSpan(
                text: i.title!,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
                children: <WidgetSpan>[
                  WidgetSpan(
                      child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: i.showScamTag == true
                        ? ScamTag()
                        : SizedBox(
                            height: 0,
                          ),
                  ))
                ],
              )),
              text: i.copyText,
            ),
          ]));

      list.add(baseCon);
    });
    if (txKindLow == "zkapp_token" && tx.failureReason != null) {
      list.add(_buildRiskTip(context, tx));
    }
    return list;
  }

  Widget _buildErrorView(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final bool canRetry = _retryCount < _maxRetries;
    return GestureDetector(
      onTap: canRetry ? _handleErrorTap : null,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Color(0xFF808080)),
            SizedBox(height: 16),
            Text(
              dic.txHistoryTip,
              style: TextStyle(
                color: Color(0xFF808080),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (canRetry) ...[
              SizedBox(height: 12),
              Text(
                dic.retry,
                style: TextStyle(
                  color: Color(0xFF594AF1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskTip(BuildContext context, TransferData tx) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          color: Color(0xFFD65A5A).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFD65A5A), width: 1)),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/webview/icon_alert.svg',
                height: 30,
                width: 30,
              ),
              Text(dic.failed,
                  style: TextStyle(
                      color: Color(0xFFD65A5A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500))
            ],
          ),
          Text(tx.failureReason ?? "",
              style: TextStyle(
                  color: Color(0xFFD65A5A),
                  fontSize: 12,
                  fontWeight: FontWeight.w400))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${dic.details}'),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError || _txData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${dic.details}'),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _buildErrorView(context),
        ),
      );
    }

    Map params = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    TransferData tx = _txData!;
    bool showExplorer = tx.type != "zkapp_token";
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${dic.details}'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 30, right: 20, left: 20),
                children: _buildListView(context, tx, params),
              ),
            ),
            showExplorer && tx.hash.isNotEmpty && (_argExplorerUrl ?? widget.store.settings!.currentNode?.explorerUrl ?? '').isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30)
                              .copyWith(bottom: 30),
                          child: BrowserLink(
                            '${(_argExplorerUrl ?? widget.store.settings!.currentNode?.explorerUrl ?? '').replaceAll(RegExp(r'/+$'), '')}/tx/${tx.hash}',
                            text: dic.goToExplrer,
                            launchMode: LaunchMode.inAppBrowserView,
                          ))
                    ],
                  )
                : SizedBox(
                    height: 0,
                  )
          ],
        ),
      ),
    );
  }
}

class TxInfoItem {
  TxInfoItem(
      {required this.label, this.title, this.copyText, this.showScamTag});
  final String label;
  final String? title;
  final String? copyText;
  final bool? showScamTag;
}
