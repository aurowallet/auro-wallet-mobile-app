import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:auro_wallet/walletSdk/rust_api_generated.dart';
const base = 'rust-signer';
final path = 'lib$base.so';
late final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : DynamicLibrary.open(path);
late final api = RustSignerImpl(dylib);

Future<void> callHi(String name) async {
  final words = await api.hi(name: name);
  print(words as String);
}