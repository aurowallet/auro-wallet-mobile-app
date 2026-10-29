import 'dart:math';

import 'package:auro_wallet/common/components/appTextScale.dart';

import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/common/theme.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/component/TxListView.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final adaptive in [false, true]) {
    for (final size in [
      const Size(375, 1200),
      const Size(430, 1200),
      const Size(932, 430),
      const Size(820, 1200),
      const Size(1180, 1200),
    ]) {
      final width = size.width;
      testWidgets(
        'transaction address layout at $size (adaptive=$adaptive)',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          tester.view.display.size = size;
          tester.view.display.devicePixelRatio = 1;
          addTearDown(tester.view.display.resetSize);
          addTearDown(tester.view.display.resetDevicePixelRatio);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          const address =
              'B62qkzCugh8u2Ez1vEs7i3UjW7iypA8ovwC88rBwLqZmdWFqh96M8rM';
          final tx = TransferData()
            ..type = 'payment'
            ..sender = 'sender'
            ..receiver = address
            ..amount = '12000000'
            ..time = '2026-10-03T09:40:00Z'
            ..status = 'applied';
          await tester.pumpWidget(
            MaterialApp(
              theme: appTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              builder: (context, child) => adaptive
                  ? AppTextScale(child: child!)
                  : MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(
                          max(min(width / 375, 2.0), 1.0),
                        ),
                      ),
                      child: child!,
                    ),
              home: Scaffold(
                body: Align(
                  alignment: Alignment.topCenter,
                  child: TransferListItem(
                    store: AppStore(),
                    data: tx,
                    tokenId: ZK_DEFAULT_TOKEN_ID,
                    currentAddress: 'sender',
                    tokenSymbol: 'MINA',
                    tokenDecimal: 9,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final title = find.text(Fmt.address(address, pad: 8));
          final paragraph = tester.renderObject<RenderParagraph>(title);
          final painter = TextPainter(
            text: paragraph.text,
            textDirection: paragraph.textDirection,
            textScaler: paragraph.textScaler,
          )..layout();
          // Compare the allocated height with the complete line, not the already
          // constrained RenderParagraph height (which hid this clipping bug).
          expect(paragraph.size.height, greaterThanOrEqualTo(painter.height));
          if (size.shortestSide < 600) {
            final addressRow = find.ancestor(
              of: title,
              matching: find.byType(Container),
            ).first;
            // Keep the original 20px minimum. Larger phone text may need more
            // height (including landscape), but no extra padding is introduced.
            expect(
              tester.getSize(addressRow).height,
              closeTo(max(20.0, painter.height), 0.01),
            );
          }
          final amountRect = tester.getRect(find.text('-0.012'));
          final titleRect = tester.getRect(title);
          expect(titleRect.right, lessThanOrEqualTo(amountRect.left));
          final dateRect = tester.getRect(
            find.text(Fmt.dateTimeFromUTC(tx.time)),
          );
          expect(titleRect.bottom, lessThanOrEqualTo(dateRect.top));
          expect(tester.takeException(), isNull);
          painter.dispose();
        },
      );
    }
  }
}
