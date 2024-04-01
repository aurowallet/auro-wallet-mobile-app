import 'dart:convert';

import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/browser/types/webConfig.dart';
import 'package:mobx/mobx.dart';
import 'package:json_annotation/json_annotation.dart';

part 'browser.g.dart';

class BrowserStore extends _BrowserStore with _$BrowserStore {
  BrowserStore(AppStore store) : super(store);
}

abstract class _BrowserStore with Store {
  _BrowserStore(this.rootStore);

  final AppStore rootStore;

  @observable
  List<WebConfig> webFavList = [];

  @observable
  List<WebConfig> webHistoryList = [];

  @observable
  Map<String, List<String>> browserConnectingList = {};

  @action
  Future<void> init() async {
    await loadWebFavList();
    await loadWebHistoryList();
  }

  @action
  Future<void> addConnectConfig(String url, String address) async {
    if (browserConnectingList.containsKey(address)) {
      if (!(browserConnectingList[address]?.contains(url) ?? false)) {
        browserConnectingList[address]?.add(url);
      }
    } else {
      browserConnectingList[address] = [url];
    }
  }

  @action
  Future<void> updateFavItem(Map<String, dynamic> con, String url) async {
    await rootStore.localStorage.updateWebviewFav(con, url);
    await loadWebFavList();
  }

  @action
  Future<void> removeFavItem(String url) async {
    await rootStore.localStorage.removeWebviewFav(url);
    await loadWebFavList();
  }

  @action
  Future<void> updateHistoryItem(Map<String, dynamic> con, String url) async {
    await rootStore.localStorage.updateWebHistoryList(con, url);
    await loadWebHistoryList();
  }

  @action
  Future<void> removeWebHistoryItem(String url) async {
    await rootStore.localStorage.removeWebHistory(url);
    await loadWebHistoryList();
  }

  @action
  Future<void> clearWebHistoryList() async {
    webHistoryList = [];
    rootStore.localStorage.clearWebHistoryList();
  }

  @action
  Future<void> loadWebFavList() async {
    List<Map<String, dynamic>> ls =
        await rootStore.localStorage.getWebviewFavList();
    try {
      webFavList = ObservableList.of(ls.map((i) => WebConfig.fromJson(i)));
      webFavList.sort((a, b) => b.time.compareTo(a.time));
    } catch (e) {
      print('loadWebFavList failed');
      print(e);
    }
  }

  @action
  Future<void> loadWebHistoryList() async {
    List<Map<String, dynamic>> ls =
        await rootStore.localStorage.getWebHistoryList();

    try {
      webHistoryList = ObservableList.of(ls.map((i) => WebConfig.fromJson(i)));
      webHistoryList.sort((a, b) => b.time.compareTo(a.time));
    } catch (e) {
      print('loadWebHistoryList failed');
      print(e);
    }
  }
}
