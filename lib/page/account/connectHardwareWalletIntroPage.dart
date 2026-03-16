import 'package:auro_wallet/common/components/customStyledText.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/selectHDPathPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class ConnectHardwareWalletIntroParams {
  ConnectHardwareWalletIntroParams({
    required this.defaultName,
    this.fromInitialization = false,
  });

  final String defaultName;
  final bool fromInitialization;
}

class ConnectHardwareWalletIntroPage extends StatelessWidget {
  const ConnectHardwareWalletIntroPage(this.store);

  static final String route = '/wallet/connectHardwareWalletIntro';
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final params = ModalRoute.of(context)!.settings.arguments
        as ConnectHardwareWalletIntroParams;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic.connectHardwareWallet),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        dic.ledgerTip3,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Ledger card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF594AF1),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AspectRatio(
                          // Match the exported asset ratio so the logo card expands correctly.
                          aspectRatio: 335 / 50,
                          child: SvgPicture.asset(
                            'assets/images/ledger/ledger_logo.svg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      // Get Started
                      Text(
                        dic.getStarted,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        dic.ledgerIntroDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 24),
                      // Step 1
                      _StepItem(
                        num: '1',
                        text: dic.ledgerIntroStep1,
                      ),
                      // Step 2
                      _StepItem(
                        num: '2',
                        text: dic.ledgerIntroStep2,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                child: NormalButton(
                  color: ColorsUtil.hexColor(0x594AF1),
                  text: dic.next,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      SelectHDPathPage.route,
                      arguments: SelectHDPathParams(
                        defaultName: params.defaultName,
                        fromInitialization: params.fromInitialization,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.num,
    required this.text,
  });

  final String num;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFF594AF1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                num,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: CustomStyledText(
              text: text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
