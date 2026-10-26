import 'package:auro_wallet/common/components/appTextScale.dart';
import 'package:flutter/material.dart';

/// Uses the existing three-column phone layout and keeps tablet recovery words
/// readable in both full-screen and narrow split-view windows.
class MnemonicGrid extends StatelessWidget {
  const MnemonicGrid({
    super.key,
    required this.children,
    this.mainAxisSpacing = 10,
  });

  final List<Widget> children;
  final double mainAxisSpacing;

  @override
  Widget build(BuildContext context) {
    if (!AppTextScale.isTablet(context)) {
      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: 3.4666,
        children: children,
      );
    }
    return LayoutBuilder(
      builder: (_, constraints) => GridView.count(
        shrinkWrap: true,
        crossAxisCount: constraints.maxWidth < 560 ? 2 : 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: mainAxisSpacing,
        mainAxisExtent: 48,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      ),
    );
  }
}
