import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/store/wallet/types/uiKeyring.dart';

/// Keyring section widget for displaying a group of accounts
/// Matches the app's wallet management UI design
class KeyringSection extends StatelessWidget {
  const KeyringSection({
    Key? key,
    required this.keyring,
    required this.onAccountTap,
    this.onAccountDetails,
    this.onAddAccount,
    this.onWalletDetails,
    this.currentAddress,
    this.balanceMap,
  }) : super(key: key);

  final UIKeyring keyring;
  final Function(UIKeyringAccount) onAccountTap;
  final Function(UIKeyringAccount)? onAccountDetails;
  final VoidCallback? onAddAccount;
  final VoidCallback? onWalletDetails;
  final String? currentAddress;
  final Map<String, BigInt>? balanceMap;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final bool isHDWallet = keyring.type == WalletStore.keyringTypeHD;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Keyring header - simple name with menu icon (only for HD wallets)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  keyring.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                ),
              ),
              // Menu icon for wallet details (only for HD wallets with real wallet id)
              if (isHDWallet && onWalletDetails != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: TestKeys.walletMoreButton,
                    onTap: onWalletDetails,
                    borderRadius: BorderRadius.circular(15),
                    child: SvgPicture.asset(
                      'assets/images/assets/icon_more.svg',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Account list
        ...keyring.accounts.map((account) => _buildAccountItem(context, account)),
        
        // Add account button (only for HD wallets) - dashed border style
        if (keyring.canAddAccount && onAddAccount != null)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: CustomPaint(
              painter: _DashedBorderPainter(
                color: Color.fromRGBO(0, 0, 0, 0.10),
                borderRadius: 12,
                dashWidth: 5,
                dashSpace: 3,
                strokeWidth: 1,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  key: TestKeys.addAccountButton,
                  onTap: onAddAccount,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        dic.addAccount,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF808080),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAccountItem(BuildContext context, UIKeyringAccount account) {
    final bool isSelected = account.address == currentAddress;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color bgColor = isSelected ? primaryColor : Color(0xFFF9FAFC);
    final Color textColor = isSelected ? Colors.white : Colors.black;
    final Color addressColor = isSelected 
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.3);
    final Color borderColor = isSelected 
        ? primaryColor 
        : Colors.black.withValues(alpha: 0.05);
    
    // Get balance
    final balance = balanceMap?[account.address] ?? BigInt.zero;
    final balanceStr = Fmt.balance(balance.toString(), 9);

    return Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () => onAccountTap(account),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(
                                account.name.isNotEmpty 
                                    ? account.name 
                                    : WalletStore.defaultAccountName((account.hdIndex ?? 0) + 1),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                _formatAddress(account.address),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: addressColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '$balanceStr MINA',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onAccountDetails != null)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Icon(
                              Icons.more_horiz,
                              size: 20,
                              color: textColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (onAccountDetails != null)
                  Positioned(
                    right: 10,
                    bottom: 0,
                    child: GestureDetector(
                      key: TestKeys.accountMoreButton,
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onAccountDetails?.call(account),
                      child: Container(
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 10)}...${address.substring(address.length - 10)}';
  }
}

/// Custom painter for dashed border
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dashPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
