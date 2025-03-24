import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

class WalletConnectPage extends StatefulWidget {
  WalletConnectPage(this.store);

  final AppStore store;
  static final String route = '/profile/walletConnect';

  @override
  _WalletConnectPageState createState() => _WalletConnectPageState(store);
}

class _WalletConnectPageState extends State<WalletConnectPage>
    with WidgetsBindingObserver {
  _WalletConnectPageState(this.store);

  final AppStore store;
  List<PairingInfo> _pairedLinks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(this);
      fetchPairedLinks();
    });
  }

  void fetchPairedLinks() {
    setState(() {
      _pairedLinks = store.walletConnectService!.getAllPairedLinks();
    });
  }

  Widget _renderEmpty() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/setting/empty_contact.svg',
            width: 100,
            height: 100,
          ),
          Text(
            dic.noConnectedApps,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.3),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderConnectList(BuildContext context) {
    if (_pairedLinks.isEmpty) {
      return _renderEmpty();
    }
    return ListView.separated(
      itemCount: _pairedLinks.length,
      padding: const EdgeInsets.only(top: 20),
      separatorBuilder: (BuildContext context, int index) => Container(
        color: Colors.black.withValues(alpha: 0.1),
        height: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 0),
      ),
      itemBuilder: (BuildContext context, int index) {
        final pairing = _pairedLinks[index];
        return Padding(
          key: Key(pairing.topic),
          padding: EdgeInsets.zero,
          child: WalletConnectItem(
            pairing: pairing,
            onDisconnect: () async {
              await store.walletConnectService!.disconnect(pairing.topic);
              fetchPairedLinks();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.appConnection),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Observer(builder: (_) {
          return Column(
            children: [
              Expanded(
                child: _renderConnectList(context),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class WalletConnectItem extends StatelessWidget {
  const WalletConnectItem({
    required this.pairing,
    required this.onDisconnect,
    Key? key,
  }) : super(key: key);

  final PairingInfo pairing;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final metadata = pairing.peerMetadata;
    if (metadata == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Text(dic.noConnectedApps),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          metadata.icons.isNotEmpty
              ? Image.network(
                  metadata.icons.first,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      SvgPicture.asset(
                          width: 40,
                          "assets/images/public/tab/tab_browser_active.svg",
                          colorFilter:
                              ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                )
              : SvgPicture.asset(
                  "assets/images/public/tab/tab_browser_active.svg",
                  width: 40,
                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metadata.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pairing.topic,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  metadata.url,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metadata.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onDisconnect,
            child: SvgPicture.asset(
              'assets/images/setting/icon_delete.svg',
            ),
          ),
        ],
      ),
    );
  }
}
