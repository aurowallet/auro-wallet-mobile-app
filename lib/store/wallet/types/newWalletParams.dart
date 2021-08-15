import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
part 'newWalletParams.g.dart';

class NewWalletParams extends _NewWalletParams with _$NewWalletParams {}

abstract class _NewWalletParams with Store {
  String? name;

  String password = '';

  @observable
  String seed = '';

  String seedType = '';
}

