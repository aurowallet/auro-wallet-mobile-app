import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/browser/types/webConfig.dart';
import 'package:mobx/mobx.dart';

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
  List<String> zkAppConnectingList = [];

  @action
  Future<void> init() async {
    await loadWebFavList();
    await loadWebHistoryList();
    String pubKey = rootStore.wallet!.currentAddress;
    if (pubKey.isNotEmpty) {
      await loadZkAppConnect(pubKey);
    }
  }

  @action
  Future<void> addZkAppConnect(String address, String url) async {
    bool updateStatus =
        await rootStore.localStorage.updateZkAppConnectList(address, url);
    if (updateStatus) {
      await loadZkAppConnect(address);
    }
  }
  
  @action
  Future<void> removeZkAppConnect(String address, String url) async {
    bool updateStatus =
        await rootStore.localStorage.removeZkAppConnectItem(address, url);
    if (updateStatus) {
      await loadZkAppConnect(address);
    }
  }

  @action
  Future<void> clearZkAppConnect(String address) async {
    await rootStore.localStorage.removeZkAppAllConnect(address);
    await loadZkAppConnect(address);
  }

  @action
  Future<void> loadZkAppConnect(String address) async {
    try {
      List<String> connectList =
          await rootStore.localStorage.getZkAppConnectList(address);
      zkAppConnectingList = connectList;
    } catch (e) {
      print('loadZkAppConnect failed');
      print(e);
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