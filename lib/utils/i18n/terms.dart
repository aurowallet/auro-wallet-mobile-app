import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
class TermsZH extends StatelessWidget {
  TermsZH({required this.termsUrl,required this.privacyUrl});
  final String termsUrl;
  final String privacyUrl;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    var normalStyle = theme.headline5!.copyWith(
        color: ColorsUtil.hexColor(0x666666)
    );
    return new RichText(
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      text: TextSpan(
          children: [
            new TextSpan(
              text: '使用 Auro 钱包提供的服务，你需要阅读并充分理解使用条款和隐私政策相关的内容。\n\n你可以阅读',
              style: normalStyle,
            ),
            new TextSpan(
              text: '《使用条款》',
              style: theme.headline5!.copyWith(color: Theme.of(context).primaryColor),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launch(termsUrl);
                },
            ),
            new TextSpan(
              text: '和',
              style: normalStyle,
            ),
            new TextSpan(
              text: '《隐私政策》',
              style: theme.headline5!.copyWith(color: Theme.of(context).primaryColor),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launch(termsUrl);
                },
            ),
            new TextSpan(
              text: '了解详细信息，如果你同意，请点击【同意】开始使用钱包服务。',
              style: normalStyle,
            ),
          ]
      ),
    );
  }
}

class TermsEN extends StatelessWidget {
  TermsEN({required this.termsUrl,required this.privacyUrl});
  final String termsUrl;
  final String privacyUrl;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    var normalStyle = theme.headline5!.copyWith(
        color: ColorsUtil.hexColor(0x666666)
    );
    return new RichText(
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      text: TextSpan(
          children: [
            new TextSpan(
              text: 'To use the services provided by Auro Wallet, you need to carefully read and fully understand the Terms of Conditions and Privacy Policy. \n\nYou can read',
              style: normalStyle,
            ),
            new TextSpan(
              text: '"Terms and Conditions"',
              style: theme.headline5!.copyWith(color: Theme.of(context).primaryColor),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launch(termsUrl);
                },
            ),
            new TextSpan(
              text: ' and ',
              style: normalStyle,
            ),
            new TextSpan(
              text: '"Privacy Policy"',
              style: theme.headline5!.copyWith(color: Theme.of(context).primaryColor),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launch(termsUrl);
                },
            ),
            new TextSpan(
              text: ' to learn the details. If you agree, please click  [Agree] to start using the wallet service.',
              style: normalStyle,
            ),
          ]
      ),
    );
  }
}