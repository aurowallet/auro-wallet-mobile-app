// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BrowserStore on _BrowserStore, Store {
  late final _$webFavListAtom =
      Atom(name: '_BrowserStore.webFavList', context: context);

  @override
  List<WebConfig> get webFavList {
    _$webFavListAtom.reportRead();
    return super.webFavList;
  }

  @override
  set webFavList(List<WebConfig> value) {
    _$webFavListAtom.reportWrite(value, super.webFavList, () {
      super.webFavList = value;
    });
  }

  late final _$webHistoryListAtom =
      Atom(name: '_BrowserStore.webHistoryList', context: context);

  @override
  List<WebConfig> get webHistoryList {
    _$webHistoryListAtom.reportRead();
    return super.webHistoryList;
  }

  @override
  set webHistoryList(List<WebConfig> value) {
    _$webHistoryListAtom.reportWrite(value, super.webHistoryList, () {
      super.webHistoryList = value;
    });
  }

  late final _$zkAppConnectingListAtom =
      Atom(name: '_BrowserStore.zkAppConnectingList', context: context);

  @override
  List<String> get zkAppConnectingList {
    _$zkAppConnectingListAtom.reportRead();
    return super.zkAppConnectingList;
  }

  @override
  set zkAppConnectingList(List<String> value) {
    _$zkAppConnectingListAtom.reportWrite(value, super.zkAppConnectingList, () {
      super.zkAppConnectingList = value;
    });
  }

  late final _$initAsyncAction =
      AsyncAction('_BrowserStore.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$addZkAppConnectAsyncAction =
      AsyncAction('_BrowserStore.addZkAppConnect', context: context);

  @override
  Future<void> addZkAppConnect(String address, String url) {
    return _$addZkAppConnectAsyncAction
        .run(() => super.addZkAppConnect(address, url));
  }

  late final _$removeZkAppConnectAsyncAction =
      AsyncAction('_BrowserStore.removeZkAppConnect', context: context);

  @override
  Future<void> removeZkAppConnect(String address, String url) {
    return _$removeZkAppConnectAsyncAction
        .run(() => super.removeZkAppConnect(address, url));
  }

  late final _$clearZkAppConnectAsyncAction =
      AsyncAction('_BrowserStore.clearZkAppConnect', context: context);

  @override
  Future<void> clearZkAppConnect(String address) {
    return _$clearZkAppConnectAsyncAction
        .run(() => super.clearZkAppConnect(address));
  }

  late final _$loadZkAppConnectAsyncAction =
      AsyncAction('_BrowserStore.loadZkAppConnect', context: context);

  @override
  Future<void> loadZkAppConnect(String address) {
    return _$loadZkAppConnectAsyncAction
        .run(() => super.loadZkAppConnect(address));
  }

  late final _$updateFavItemAsyncAction =
      AsyncAction('_BrowserStore.updateFavItem', context: context);

  @override
  Future<void> updateFavItem(Map<String, dynamic> con, String url) {
    return _$updateFavItemAsyncAction.run(() => super.updateFavItem(con, url));
  }

  late final _$removeFavItemAsyncAction =
      AsyncAction('_BrowserStore.removeFavItem', context: context);

  @override
  Future<void> removeFavItem(String url) {
    return _$removeFavItemAsyncAction.run(() => super.removeFavItem(url));
  }

  late final _$updateHistoryItemAsyncAction =
      AsyncAction('_BrowserStore.updateHistoryItem', context: context);

  @override
  Future<void> updateHistoryItem(Map<String, dynamic> con, String url) {
    return _$updateHistoryItemAsyncAction
        .run(() => super.updateHistoryItem(con, url));
  }

  late final _$removeWebHistoryItemAsyncAction =
      AsyncAction('_BrowserStore.removeWebHistoryItem', context: context);

  @override
  Future<void> removeWebHistoryItem(String url) {
    return _$removeWebHistoryItemAsyncAction
        .run(() => super.removeWebHistoryItem(url));
  }

  late final _$clearWebHistoryListAsyncAction =
      AsyncAction('_BrowserStore.clearWebHistoryList', context: context);

  @override
  Future<void> clearWebHistoryList() {
    return _$clearWebHistoryListAsyncAction
        .run(() => super.clearWebHistoryList());
  }

  late final _$loadWebFavListAsyncAction =
      AsyncAction('_BrowserStore.loadWebFavList', context: context);

  @override
  Future<void> loadWebFavList() {
    return _$loadWebFavListAsyncAction.run(() => super.loadWebFavList());
  }

  late final _$loadWebHistoryListAsyncAction =
      AsyncAction('_BrowserStore.loadWebHistoryList', context: context);

  @override
  Future<void> loadWebHistoryList() {
    return _$loadWebHistoryListAsyncAction
        .run(() => super.loadWebHistoryList());
  }

  @override
  String toString() {
    return '''
webFavList: ${webFavList},
webHistoryList: ${webHistoryList},
zkAppConnectingList: ${zkAppConnectingList}
    ''';
  }
}
