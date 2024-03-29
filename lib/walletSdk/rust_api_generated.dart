// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`.

// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports

import 'dart:convert';
import 'dart:typed_data';

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'dart:ffi' as ffi;

abstract class RustSigner {
  Future<String> getAddressFromSecretHex(
      {required String secretHex, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetAddressFromSecretHexConstMeta;

  Future<SignatureData> signPayment(
      {required String secretHex,
      required String to,
      required int amount,
      required int fee,
      required int nonce,
      required int validUntil,
      required String memo,
      required int networkId,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSignPaymentConstMeta;

  Future<SignatureData> signDelegation(
      {required String secretHex,
      required String to,
      required int fee,
      required int nonce,
      required int validUntil,
      required String memo,
      required int networkId,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSignDelegationConstMeta;
}

class SignatureData {
  final String field;
  final String scalar;

  SignatureData({
    required this.field,
    required this.scalar,
  });
}

class RustSignerImpl extends FlutterRustBridgeBase<RustSignerWire>
    implements RustSigner {
  factory RustSignerImpl(ffi.DynamicLibrary dylib) =>
      RustSignerImpl.raw(RustSignerWire(dylib));

  RustSignerImpl.raw(RustSignerWire inner) : super(inner);

  Future<String> getAddressFromSecretHex(
          {required String secretHex, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_getAddressFromSecretHex(
            port_, _api2wire_String(secretHex)),
        parseSuccessData: _wire2api_String,
        constMeta: kGetAddressFromSecretHexConstMeta,
        argValues: [secretHex],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kGetAddressFromSecretHexConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "getAddressFromSecretHex",
        argNames: ["secretHex"],
      );

  Future<SignatureData> signPayment(
          {required String secretHex,
          required String to,
          required int amount,
          required int fee,
          required int nonce,
          required int validUntil,
          required String memo,
          required int networkId,
          dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_signPayment(
            port_,
            _api2wire_String(secretHex),
            _api2wire_String(to),
            _api2wire_u64(amount),
            _api2wire_u64(fee),
            _api2wire_u32(nonce),
            _api2wire_u32(validUntil),
            _api2wire_String(memo),
            _api2wire_u8(networkId)),
        parseSuccessData: _wire2api_signature_data,
        constMeta: kSignPaymentConstMeta,
        argValues: [
          secretHex,
          to,
          amount,
          fee,
          nonce,
          validUntil,
          memo,
          networkId
        ],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kSignPaymentConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "signPayment",
        argNames: [
          "secretHex",
          "to",
          "amount",
          "fee",
          "nonce",
          "validUntil",
          "memo",
          "networkId"
        ],
      );

  Future<SignatureData> signDelegation(
          {required String secretHex,
          required String to,
          required int fee,
          required int nonce,
          required int validUntil,
          required String memo,
          required int networkId,
          dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_signDelegation(
            port_,
            _api2wire_String(secretHex),
            _api2wire_String(to),
            _api2wire_u64(fee),
            _api2wire_u32(nonce),
            _api2wire_u32(validUntil),
            _api2wire_String(memo),
            _api2wire_u8(networkId)),
        parseSuccessData: _wire2api_signature_data,
        constMeta: kSignDelegationConstMeta,
        argValues: [secretHex, to, fee, nonce, validUntil, memo, networkId],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kSignDelegationConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "signDelegation",
        argNames: [
          "secretHex",
          "to",
          "fee",
          "nonce",
          "validUntil",
          "memo",
          "networkId"
        ],
      );

  // Section: api2wire
  ffi.Pointer<wire_uint_8_list> _api2wire_String(String raw) {
    return _api2wire_uint_8_list(utf8.encoder.convert(raw));
  }

  int _api2wire_u32(int raw) {
    return raw;
  }

  int _api2wire_u64(int raw) {
    return raw;
  }

  int _api2wire_u8(int raw) {
    return raw;
  }

  ffi.Pointer<wire_uint_8_list> _api2wire_uint_8_list(Uint8List raw) {
    final ans = inner.new_uint_8_list(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }

  // Section: api_fill_to_wire

}

// Section: wire2api
String _wire2api_String(dynamic raw) {
  return raw as String;
}

SignatureData _wire2api_signature_data(dynamic raw) {
  final arr = raw as List<dynamic>;
  if (arr.length != 2)
    throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
  return SignatureData(
    field: _wire2api_String(arr[0]),
    scalar: _wire2api_String(arr[1]),
  );
}

int _wire2api_u8(dynamic raw) {
  return raw as int;
}

Uint8List _wire2api_uint_8_list(dynamic raw) {
  return raw as Uint8List;
}

// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_positional_boolean_parameters, annotate_overrides, constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.

/// generated by flutter_rust_bridge
class RustSignerWire implements FlutterRustBridgeWireBase {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  RustSignerWire(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  RustSignerWire.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void wire_getAddressFromSecretHex(
    int port_,
    ffi.Pointer<wire_uint_8_list> secret_hex,
  ) {
    return _wire_getAddressFromSecretHex(
      port_,
      secret_hex,
    );
  }

  late final _wire_getAddressFromSecretHexPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64,
              ffi.Pointer<wire_uint_8_list>)>>('wire_getAddressFromSecretHex');
  late final _wire_getAddressFromSecretHex = _wire_getAddressFromSecretHexPtr
      .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_signPayment(
    int port_,
    ffi.Pointer<wire_uint_8_list> secret_hex,
    ffi.Pointer<wire_uint_8_list> to,
    int amount,
    int fee,
    int nonce,
    int valid_until,
    ffi.Pointer<wire_uint_8_list> memo,
    int network_id,
  ) {
    return _wire_signPayment(
      port_,
      secret_hex,
      to,
      amount,
      fee,
      nonce,
      valid_until,
      memo,
      network_id,
    );
  }

  late final _wire_signPaymentPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64,
              ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>,
              ffi.Uint64,
              ffi.Uint64,
              ffi.Uint32,
              ffi.Uint32,
              ffi.Pointer<wire_uint_8_list>,
              ffi.Uint8)>>('wire_signPayment');
  late final _wire_signPayment = _wire_signPaymentPtr.asFunction<
      void Function(
          int,
          ffi.Pointer<wire_uint_8_list>,
          ffi.Pointer<wire_uint_8_list>,
          int,
          int,
          int,
          int,
          ffi.Pointer<wire_uint_8_list>,
          int)>();

  void wire_signDelegation(
    int port_,
    ffi.Pointer<wire_uint_8_list> secret_hex,
    ffi.Pointer<wire_uint_8_list> to,
    int fee,
    int nonce,
    int valid_until,
    ffi.Pointer<wire_uint_8_list> memo,
    int network_id,
  ) {
    return _wire_signDelegation(
      port_,
      secret_hex,
      to,
      fee,
      nonce,
      valid_until,
      memo,
      network_id,
    );
  }

  late final _wire_signDelegationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64,
              ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>,
              ffi.Uint64,
              ffi.Uint32,
              ffi.Uint32,
              ffi.Pointer<wire_uint_8_list>,
              ffi.Uint8)>>('wire_signDelegation');
  late final _wire_signDelegation = _wire_signDelegationPtr.asFunction<
      void Function(
          int,
          ffi.Pointer<wire_uint_8_list>,
          ffi.Pointer<wire_uint_8_list>,
          int,
          int,
          int,
          ffi.Pointer<wire_uint_8_list>,
          int)>();

  ffi.Pointer<wire_uint_8_list> new_uint_8_list(
    int len,
  ) {
    return _new_uint_8_list(
      len,
    );
  }

  late final _new_uint_8_listPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_uint_8_list> Function(
              ffi.Int32)>>('new_uint_8_list');
  late final _new_uint_8_list = _new_uint_8_listPtr
      .asFunction<ffi.Pointer<wire_uint_8_list> Function(int)>();

  void free_WireSyncReturnStruct(
    WireSyncReturnStruct val,
  ) {
    return _free_WireSyncReturnStruct(
      val,
    );
  }

  late final _free_WireSyncReturnStructPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(WireSyncReturnStruct)>>(
          'free_WireSyncReturnStruct');
  late final _free_WireSyncReturnStruct = _free_WireSyncReturnStructPtr
      .asFunction<void Function(WireSyncReturnStruct)>();

  void store_dart_post_cobject(
    DartPostCObjectFnType ptr,
  ) {
    return _store_dart_post_cobject(
      ptr,
    );
  }

  late final _store_dart_post_cobjectPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(DartPostCObjectFnType)>>(
          'store_dart_post_cobject');
  late final _store_dart_post_cobject = _store_dart_post_cobjectPtr
      .asFunction<void Function(DartPostCObjectFnType)>();
}

class wire_uint_8_list extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.Int32()
  external int len;
}

typedef DartPostCObjectFnType = ffi.Pointer<
    ffi.NativeFunction<ffi.Bool Function(DartPort, ffi.Pointer<ffi.Void>)>>;
typedef DartPort = ffi.Int64;
