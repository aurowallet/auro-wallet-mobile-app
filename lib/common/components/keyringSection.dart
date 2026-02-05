import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
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
        Container(
          padding: EdgeInsets.only(left: 20, right: 8, top: 16, bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  keyring.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Menu icon for wallet details (only for HD wallets with real wallet id)
              if (isHDWallet && onWalletDetails != null)
                IconButton(
                  icon: Icon(Icons.more_horiz, color: Color(0xFF594AF1), size: 20),
                  onPressed: onWalletDetails,
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                ),
            ],
          ),
        ),
        
        // Account list
        ...keyring.accounts.map((account) => _buildAccountItem(context, account)),
        
        // Add account button (only for HD wallets) - dashed border style
        if (keyring.canAddAccount && onAddAccount != null)
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 4),
            child: CustomPaint(
              painter: _DashedBorderPainter(
                color: Color(0xFFE8E8E8),
                borderRadius: 12,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onAddAccount,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        dic.addAccount,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAccountItem(BuildContext context, UIKeyringAccount account) {
    final bool isSelected = account.address == currentAddress;
    final Color bgColor = isSelected ? Color(0xFF594AF1) : Color(0xFFF9FAFC);
    final Color textColor = isSelected ? Colors.white : Colors.black;
    final Color addressColor = isSelected 
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.3);
    final Color borderColor = isSelected 
        ? Color(0xFF594AF1) 
        : Colors.black.withValues(alpha: 0.05);
    
    // Get balance
    final balance = balanceMap?[account.address] ?? BigInt.zero;
    final balanceStr = Fmt.balance(balance.toString(), 9);

    return Container(
      margin: EdgeInsets.only(top: 10, right: 20, left: 20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: bgColor,
        child: InkWell(
          onTap: () => onAccountTap(account),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: EdgeInsets.only(top: 5)),
                        Text(
                          account.name.isNotEmpty 
                              ? account.name 
                              : 'Account ${(account.hdIndex ?? 0) + 1}',
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
                        Padding(padding: EdgeInsets.only(top: 8)),
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
                  // More icon at bottom right - matching original WalletItem style
                  if (onAccountDetails != null)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => onAccountDetails?.call(account),
                          child: Icon(
                            Icons.more_horiz,
                            size: 20,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
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
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.strokeWidth = 1,
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
        final len = dashWidth;
        dashPath.addPath(
          metric.extractPath(distance, distance + len),
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
