import 'dart:async';

import 'package:auro_wallet/common/components/tabPageTitle.dart';
import 'package:mobx/mobx.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/staking/components/delegationInfo.dart';
import 'package:auro_wallet/page/staking/components/stakingOverview.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/material.dart';

class Staking extends StatefulWidget {
  Staking(this.store);

  final AppStore store;
  static final String route = '/assets/staking';
  @override
  _StakingState createState() => _StakingState(store);
}

class _StakingState extends State<Staking> {
  _StakingState(this.store);

  final AppStore store;
  bool loading = true;
  Timer? _refreshTimer;
  ReactionDisposer? _storeChangeDisposer;
  final GlobalKey<RefreshIndicatorState> _stakingRefreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    final currentKey = '${store.wallet!.currentAddress}_${store.settings!.currentNode?.networkID}';
    final hasCachedData = store.assets!.mainTokenNetInfo.tokenBaseInfo != null;
    loading = store.staking!.lastLoadedDataKey != currentKey || !hasCachedData;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store.setStakingRefreshKey(_stakingRefreshKey);
      _fetchData();
      _refreshTimer = Timer.periodic(Duration(minutes: 3), (timer) {
        _onRefresh();
      });
      _storeChangeDisposer = reaction(
        (_) => '${store.wallet!.currentAddress}_${store.settings!.currentNode?.networkID}',
        (_) {
          store.staking!.clearAccountSpecificData();
          setState(() {
            loading = true;
          });
          _fetchData();
        },
      );
    });
  }

  Future<void> _fetchData() async {
    await Future.wait([
      webApi.staking.fetchValidators(),
      webApi.assets.fetchAllTokenAssets(),
      webApi.staking.fetchStakingOverview(),
      webApi.staking.fetchStakingAPR(),
    ]);
    if (mounted) {
      store.staking!.lastLoadedDataKey = '${store.wallet!.currentAddress}_${store.settings!.currentNode?.networkID}';
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([webApi.staking.fetchStakingOverview(), webApi.staking.fetchStakingAPR()]);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _storeChangeDisposer?.call();
    store.setStakingRefreshKey(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    bool isFromRoute = false;
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args['isFromRoute'] == true) {
      isFromRoute = true;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        title: isFromRoute ? Text(dic.staking) : null,
        toolbarHeight: isFromRoute ? null : 0,
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: RefreshIndicator(
            backgroundColor: Colors.white,
            color: Theme.of(context).primaryColor,
            key: _stakingRefreshKey,
            onRefresh: _fetchData,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isFromRoute
                    ? SizedBox(
                        height: 0,
                      )
                    : TabPageTitle(title: dic.staking),
                Expanded(
                    child: ListView(
                  children: [
                    StakingOverview(
                      store: store,
                    ),
                    DelegationInfo(store: store, loading: loading)
                  ],
                ))
              ],
            )),
      ),
    );
  }
}
