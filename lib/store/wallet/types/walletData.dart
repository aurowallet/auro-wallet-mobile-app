import 'package:json_annotation/json_annotation.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';

part 'walletData.g.dart';

@JsonSerializable(explicitToJson: true)
class WalletData extends _WalletData {
  static WalletData fromJson(Map<String, dynamic> json) =>
      _$WalletDataFromJson(json);

  static Map<String, dynamic> toJson(WalletData acc) => _$WalletDataToJson(acc);

  @override
  String toString() {
    return 'WalletData(name: $name, pubKey: $pubKey, address: $address, currentAccount: $currentAccount, createTime: $createTime, currentAccountIndex: $currentAccountIndex, walletTypeIndex: $walletTypeIndex, walletType: $walletType, id: $id, source: $source, meta: $meta, accounts: $accounts)';
  }
}

abstract class _WalletData {
  // 首个地址的名称
  String get name {
    return currentAccount.name;
  }

  // 首个地址的pubey
  String get pubKey {
    return currentAccount.pubKey;
  }

  String get address {
    return pubKey;
  }

  // 当前账户
  AccountData get currentAccount {
    if (accounts.length == 0) {
      return new AccountData();
    }
    return accounts.firstWhere(
        (account) => account.accountIndex == currentAccountIndex,
        orElse: () => new AccountData());
  }

  int createTime = 0;

  // account index in hd path
  int currentAccountIndex = 0;
  int walletTypeIndex = 0;
  String walletType = '';

  // use the first account public key as wallet id
  String id = '';

  // inside or outside
  String source = '';
  Map<String, dynamic> meta = Map<String, dynamic>();
  List<AccountData> accounts = [];
}
