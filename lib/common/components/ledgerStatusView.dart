import 'dart:async';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/ledger/ledger.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';

class LedgerStatusView extends StatefulWidget {
  LedgerStatusView();

  @override
  _LedgerStatusViewState createState() => new _LedgerStatusViewState();
}

class _LedgerStatusViewState extends State<LedgerStatusView>
    with WidgetsBindingObserver {
  final store = globalAppStore;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshStatus();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshStatus();
    }
  }

  void _refreshStatus() {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      unawaited(store.ledger!.refreshStatus());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Observer(builder: (_) {
      final ledgerAvailable =
          store.ledger!.ledgerStatus == LedgerStatusTypes.available;
      return GestureDetector(
          onTap: () async {
            await store.ledger!.refreshStatus();
            if (!mounted) return;
            UI.toast(store.ledger!.ledgerStatus == LedgerStatusTypes.available
                ? dic.ledgerConnected
                : dic.ledgerNotConnected);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            child: SvgPicture.asset(
              'assets/images/ledger/icon_legder_status.svg',
              width: 28,
              height: 30,
              colorFilter: ColorFilter.mode(ledgerAvailable ? Color(0xFF0DB27C) : Color(0xFFD65A5A), BlendMode.srcIn)
            ),
          ));
    });
  }
}
