class AccountInfo extends _AccountInfo {
  static AccountInfo fromJson(Map<String, dynamic> json) {
    AccountInfo data = AccountInfo();
    data.total = BigInt.parse(json['total'].toString());
    data.delegate =
        json['delegate'] == null ? null : json['delegate'] as String;
    data.publicKey = json['publicKey'] as String;
    data.inferredNonce = int.parse((json['inferredNonce'] as String?) ?? "0");
    return data;
  }
}

class _AccountInfo {
  // total balance
  late BigInt total;

  // delegate public key
  String? delegate;

  // public key
  late String publicKey;

  // nonce
  late int inferredNonce;

  bool get isDelegated {
    return delegate != null && delegate != publicKey;
  }
}
