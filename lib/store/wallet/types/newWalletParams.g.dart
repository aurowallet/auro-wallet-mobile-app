// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newWalletParams.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NewWalletParams on _NewWalletParams, Store {
  late final _$seedAtom = Atom(name: '_NewWalletParams.seed', context: context);

  @override
  String get seed {
    _$seedAtom.reportRead();
    return super.seed;
  }

  @override
  set seed(String value) {
    _$seedAtom.reportWrite(value, super.seed, () {
      super.seed = value;
    });
  }

  @override
  String toString() {
    return '''
seed: ${seed}
    ''';
  }
}
