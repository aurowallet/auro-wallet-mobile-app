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

  late final _$browserConnectingListAtom =
      Atom(name: '_BrowserStore.browserConnectingList', context: context);

  @override
  Map<String, List<String>> get browserConnectingList {
    _$browserConnectingListAtom.reportRead();
    return super.browserConnectingList;
  }

  @override
  set browserConnectingList(Map<String, List<String>> value) {
    _$browserConnectingListAtom.reportWrite(value, super.browserConnectingList,
        () {
      super.browserConnectingList = value;
    });
  }

  late final _$initAsyncAction =
      AsyncAction('_BrowserStore.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$addConnectConfigAsyncAction =
      AsyncAction('_BrowserStore.addConnectConfig', context: context);

  @override
  Future<void> addConnectConfig(String url, String address) {
    return _$addConnectConfigAsyncAction
        .run(() => super.addConnectConfig(url, address));
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
browserConnectingList: ${browserConnectingList}
    ''';
  }
}
