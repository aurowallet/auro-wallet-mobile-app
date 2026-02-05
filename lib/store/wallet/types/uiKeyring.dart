/// UI layer Keyring display structure
/// Used to convert Flutter WalletData list to React-like Keyring view
class UIKeyring {
  final String id;
  final String type; // 'hd', 'imported', 'ledger', 'watch'
  final String name;
  final int createdAt;
  final bool canAddAccount;
  final List<UIKeyringAccount> accounts;
  final String? currentAddress;

  UIKeyring({
    required this.id,
    required this.type,
    required this.name,
    required this.createdAt,
    required this.canAddAccount,
    required this.accounts,
    this.currentAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'createdAt': createdAt,
      'canAddAccount': canAddAccount,
      'accounts': accounts.map((a) => a.toJson()).toList(),
      'currentAddress': currentAddress,
    };
  }
}

/// Account item within a Keyring (for UI display)
class UIKeyringAccount {
  final String address;
  final String name;
  final int? hdIndex;
  final String type;
  final String walletId; // Links back to original WalletData.id

  UIKeyringAccount({
    required this.address,
    required this.name,
    this.hdIndex,
    required this.type,
    required this.walletId,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'name': name,
      'hdIndex': hdIndex,
      'type': type,
      'walletId': walletId,
    };
  }
}
