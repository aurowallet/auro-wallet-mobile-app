// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get passwordError => 'Hatalı şifre';

  @override
  String get createWallet => 'Cüzdan Oluştur';

  @override
  String get restoreWallet => 'Cüzdanı Geri Yükle';

  @override
  String get inputPassword => 'Şifresini giriniz';

  @override
  String get createPasswordTip =>
      'Şifresi, Auro Wallet’ta işlem onaylamak için kimlik doğrulama amacıyla kullanılacaktır. Auro Wallet, şifresini saklamaz veya sizin için geri alamaz. Lütfen şifrenizi güvende tutun.';

  @override
  String get next => 'Sonraki';

  @override
  String get atLeastOneLowercaseLetter => 'Bir küçük harf';

  @override
  String get atLeastOneUppercaseLetter => 'Bir büyük harf';

  @override
  String get atLeastOneNumber => 'Bir rakam';

  @override
  String get passwordRequires => 'En az 8 karakter';

  @override
  String get passwordDifferent => 'Şifreler uyuşmuyor';

  @override
  String get backTips_1 => 'Anımsatıcı ifadenizi şimdi yedekleyin!';

  @override
  String get backTips_2 =>
      'Anımsatıcı ifade, kaybolmaları durumunda geri getirilemeyen 12 İngilizce kelimeden oluşur. Anımsatıcı ifadenin güvenli bir yerde saklandığından emin olunuz.';

  @override
  String get backTips_3 =>
      'Cihazınız kaybolduğunda veya başka bir nedenden dolayı cüzdana erişilemiyorsa, varlıklarınızı geri almanın tek yolu anımsatıcı ifadeyi içe aktarmaktır.';

  @override
  String get show_seed_content =>
      'Lütfen aşağıdaki anımsatıcı cümleyi yazın ve güvenli bir yerde saklayın.';

  @override
  String get show_seed_button => 'Onaylanmış Yedek';

  @override
  String get seed_error => 'Anımsatıcı ifade yanlış girildi';

  @override
  String get backup_success => 'Tebrikler, Başarıyla bir cüzdan oluşturdunuz!';

  @override
  String get backup_success_restore =>
      'Tebrikler, Bir cüzdanı başarıyla geri yüklediniz!';

  @override
  String get inputSeed =>
      'Lütfen 12 anımsatıcı ifadeyi, büyük harf ve noktalama işareti olmadan, sırayla girin.';

  @override
  String get confirm => 'Onayla';

  @override
  String get wallet => 'Cüzdan';

  @override
  String get staking => 'Staking';

  @override
  String get setting => 'Ayarlar';

  @override
  String get stakingStatus_1 => 'Delege Edildi';

  @override
  String get stakingStatus_2 => 'Delege İptal Edildi';

  @override
  String get send => 'Gönder';

  @override
  String get receive => 'Al';

  @override
  String get history => 'GEÇMİŞ';

  @override
  String get toAddress => 'Kime';

  @override
  String get fromAddress => 'Kimden';

  @override
  String get amount => 'Tutar';

  @override
  String get memo => 'Not (İsteğe Bağlı)';

  @override
  String get memo2 => 'Not';

  @override
  String get fee => 'Ücret';

  @override
  String get fee_slow => 'Yavaş';

  @override
  String get fee_default => 'Varsayılan';

  @override
  String get fee_fast => 'Hızlı';

  @override
  String get advanceMode => 'Gelişmiş';

  @override
  String get sendDetail => 'İşlemlere Bakış';

  @override
  String get sendAddressError => 'Lütfen geçerli bir cüzdan adresi girin';

  @override
  String get amountError => 'Girdiğiniz tutarın formatı hatalı';

  @override
  String get balanceNotEnough => 'Yetersiz Bakiye';

  @override
  String get txHash => 'İşlem Kodu';

  @override
  String get time => 'Süre';

  @override
  String get goToExplrer => 'Sorgu Detayları';

  @override
  String get details => 'Detaylar';

  @override
  String get walletAddress => 'Cüzdan Adresi';

  @override
  String get copySuccess => 'Kopyalandı';

  @override
  String get accountManage => 'Hesap Yönetimi';

  @override
  String get create => 'Oluştur';

  @override
  String get import => 'İçe Aktar';

  @override
  String get importLedger => 'Ledger';

  @override
  String get accountName => 'Hesap Adı';

  @override
  String get inputAccountName => 'Lütfen hesap adınızı girin';

  @override
  String get importAccount_2 =>
      'İçe aktarılan hesaplar, orijinal olarak oluşturduğunuz Auro Wallet ile ilişkilendirilmeyecektir.';

  @override
  String get importAccount_3 =>
      'İçe aktarılan hesaplar, hesap listesinde [İçe Aktarıldı] olarak işaretlenecektir.';

  @override
  String get accountInfo => 'Hesap Detayları';

  @override
  String get accountAddress => 'Hesap Adresi';

  @override
  String get exportPrivateKey => 'Özel Anahtarı Dışa Aktar';

  @override
  String get accountDelete => 'Hesabı Sil';

  @override
  String get cancel => 'İptal';

  @override
  String get privateKeyTip_1 =>
      'Özel anahtar bir dizi karakterden oluşur ve özel anahtara sahip olmak, bütün varlığa sahip olmakla eşdeğerdir.';

  @override
  String get privateKeyTip_2 =>
      'Özel anahtar kaybolduğunda geri alınamaz. Lütfen özel anahtarı yedeklediğinizden ve güvenli bir yerde sakladığınızdan emin olun.';

  @override
  String get security => 'Güvenlik';

  @override
  String get network => 'Ağ';

  @override
  String get language => 'Dil';

  @override
  String get currency => 'Para Birimi';

  @override
  String get about => 'Hakkında';

  @override
  String get restoreSeed => 'Anımsatıcı İfadeyi Yedekleme';

  @override
  String get changePassword => 'Şifresini Değiştir';

  @override
  String get inputOldPwd => 'Lütfen <bold>eski</bold> şifreyi girin';

  @override
  String get inputNewPwd => 'Lütfen <bold>yeni</bold> şifreyi girin';

  @override
  String get inputNewPwdRepeat =>
      'Lütfen <bold>yeni</bold> şifreyi tekrar girin';

  @override
  String get pwdChangeSuccess => 'Şifre başarıyla değiştirildi';

  @override
  String get delete => 'Sil';

  @override
  String get urlError_1 => 'Geçersiz düğüm URL’si';

  @override
  String get urlError_2 => 'Adres zaten mevcut';

  @override
  String get urlError_3 => 'Düğüm adresi zaten mevcut';

  @override
  String get prompt => 'Hatırlatıcı';

  @override
  String get deleteAccountTip =>
      'Silinen bir hesap yalnızca Anımsatıcı İfade veya Özel Anahtar kullanılarak geri yüklenebilir. Lütfen Anımsatıcı İfadenizi ve Özel Anahtarınızı yedeklediğinizden emin olun.';

  @override
  String get isee => 'TAMAM';

  @override
  String get walletHomeTip =>
      'Mina ağı, spam önleme için tek seferlik 1 MINA tutarında hesap oluşturma ücreti alır. Yapılan ilk işlemden otomatik olarak düşülecektir.';

  @override
  String get startHome => 'Başla';

  @override
  String get walletName => 'Auro Wallet';

  @override
  String get privateError => 'Özel Anahtar Hatalı';

  @override
  String get improtRepeat => 'Tekrar tekrar içe aktarmayınız';

  @override
  String get confirmDeleteNode => 'Bunu silmek istediğinizden emin misiniz?';

  @override
  String get backupSuccess => 'Başarılı';

  @override
  String get walletAbout =>
      'Auro Wallet, topluluk tarafından geliştirilen, gözetimsiz bir cüzdandır. Basit, kullanışlı ve tamamen açık kaynaktır. Şu anda Mina Protokolünün tüm işlevlerini desteklemektedir.';

  @override
  String get copyTipContent =>
      'Özel anahtarın kopyalanması risklidir ve pano üçüncü taraf uygulamalar tarafından kolayca izlenebilir ve çalınabilir.';

  @override
  String get copyTipContent2 =>
      'Lütfen bu işlemi gerçekleştirmeden önce kullandığınız sistem ve ağ ortamının kesinlikle güvenli olduğundan emin olun.';

  @override
  String get copyConfirm => 'Yine de Kopyala';

  @override
  String get copyCancel => 'Kopyalamayı Durdur';

  @override
  String get scantopay => 'Kendinize ödeme yapmak için tarayın';

  @override
  String addressQrTip(String symbol) {
    return 'QR kodunu tarayın ve <strongBlack>$symbol</strongBlack>\'yı ona aktarın';
  }

  @override
  String get goToExplorer => 'Daha fazla işlem geçmişini kontrol edin';

  @override
  String get homeNoTx => 'Bilinmeyen düğüm, geçmiş sağlanamıyor.';

  @override
  String get followUs => 'Bizi Takip Edin';

  @override
  String get createPassword => 'Şifre Oluştur';

  @override
  String get epochInfo => 'Dönem Bilgisi';

  @override
  String get delegationInfo => 'Delegasyon Bilgisi';

  @override
  String get emptyDelegateTitle => 'Henüz delege etmediniz';

  @override
  String get emptyDelegateDesc1 =>
      'MINA\'yı Blok Üreticisine delege etmek, blok üretme karşılığında ödüller almanıza yardımcı olabilir. Blok Üreticisi, ödülleri sizin belirlediğiniz orana göre dağıtacaktır ve ödüllerin yüzdesi, Blok Üreticisi tarafından belirlenen orana bağlıdır.';

  @override
  String get emptyDelegateDesc2 =>
      'Delegasyon için etkili zaman ve ödül dağıtım kuralları:';

  @override
  String get emptyDelegateDesc3 => 'Staking Kılavuzu';

  @override
  String get changeNode => 'Değiştir';

  @override
  String get stakingProviderName => 'Blok Üreticisi';

  @override
  String get goStake => 'Staking’e git';

  @override
  String get epochEndTime => 'Mevcut dönem şu tarihte sona eriyor';

  @override
  String get searchPlaceholder => 'Blok Üreticisi adı veya adresi';

  @override
  String get inputNodeAddress => 'Lütfen düğüm sağlayıcı adresini girin';

  @override
  String get nodeProviders => 'Blok Üreticisi';

  @override
  String get manualAdd => 'Blok Üreticisi düğüm adresini girin';

  @override
  String get providerAddress => 'BÜ Adresi';

  @override
  String get copyToClipboard => 'Panoya Kopyala';

  @override
  String get loading => 'Yükleniyor';

  @override
  String get keystoreError => 'Anahtar deposu içeriği veya şifresi yanlış';

  @override
  String get pleaseInputKeyPair =>
      'Lütfen Anahtar Deposu dosyasının içeriğini girin.';

  @override
  String get pleaseInputKeyPairPwd => 'Anahtar Deposu Şifresi';

  @override
  String get pleaseInputPriKey => 'Lütfen Özel Anahtarı girin.';

  @override
  String get privateKey => 'Özel Anahtar';

  @override
  String get applied => 'GERÇEKLEŞTİ';

  @override
  String get failed => 'HATALI';

  @override
  String get pending => 'BEKLEMEDE';

  @override
  String get blockProducerName => 'Blok Üreticisi İsmi';

  @override
  String get producerName => 'Blok Üreticisi İsmi';

  @override
  String get blockProducerAddress => 'Blok Üreticisi Adresi';

  @override
  String get notValidAddress => 'Geçerli bir MINA adresi değil';

  @override
  String get agree => 'Kabul Ediyorum';

  @override
  String get userAgree => 'Şartlar ve Koşullar';

  @override
  String get imported => 'İçe Aktarıldı';

  @override
  String get watchAccount => 'Hesabı İzle';

  @override
  String get watchMode => 'İzleme Modu';

  @override
  String get textWatchModeAddress => 'Cüzdan Adresini girin veya yapıştırın';

  @override
  String get watchLabel => 'İzle';

  @override
  String get timeout => 'İstek Zaman Aşımına Uğradı';

  @override
  String get rootTip =>
      'Sistemin Root olduğu veya simülatör kullandığı tespit edildi. Kullanıma devam edilmesi risklidir!';

  @override
  String get exitConfirm => 'Uygulamadan çıkmak istiyor musunuz?';

  @override
  String get unlockBioEnable => 'Biyometrik Kimlik Doğrulama';

  @override
  String get unlockBio => 'Kilidi açmak için kimlik doğrulaması yapın';

  @override
  String get feeTooLarge => 'Ücretler ortalamanın çok üstünde';

  @override
  String get add => 'Ekle';

  @override
  String get addressbook => 'Adres Defteri';

  @override
  String get name => 'İsim';

  @override
  String get address => 'Adres';

  @override
  String get repeatContact => 'Adres mevcut';

  @override
  String get backupInOrder =>
      'Anımsatıcı Cümleyi yedeklediğinizden emin olmak için lütfen 12 anımsatıcı kelimeye sırayla dokunun.';

  @override
  String get refuse => 'Reddet';

  @override
  String get termsDialogTitle => 'Şartlar ve Gizlilik Politikası';

  @override
  String get privacy => 'Gizlilik Politikası';

  @override
  String get scan => 'Tara';

  @override
  String get restoreTip =>
      'Özel anahtarı/anahtar deposunu içe aktarmak veya Ledger’a bağlanmak istiyorsanız, önce [Cüzdan Oluştur] veya [Cüzdanı Geri Yükle] yapmanız gerekir.';

  @override
  String get reset => 'Sıfırla';

  @override
  String get resetWarnContentTitle =>
      'Cüzdanınızı sıfırlamak istediğinizden emin misiniz?';

  @override
  String get resetWarnContent =>
      'Mevcut cüzdanınızı sıfırladıktan sonra tüm veriler kaybolacaktır. Geri yüklemek için yalnızca anımsatıcı cümleyi kullanabilirsiniz. Lütfen cüzdanı sıfırlamadan önce anımsatıcı cümleyi yedeklediğinizden emin olun.';

  @override
  String get confirmReset => 'Sıfırla';

  @override
  String get cancelReset => 'İptal';

  @override
  String deleteConfirm(String tag) {
    return 'Mevcut cüzdanı kalıcı olarak silmek için ‘$tag’ yazın';
  }

  @override
  String get edit => 'Düzenle';

  @override
  String get save => 'Kaydet';

  @override
  String get watchModeWarn2 =>
      'Auro Wallet artık [İzleme Hesabı]’nı desteklemiyor, kullanmaya devam edebilmeniz için <red>tüm izleme hesaplarını silmeniz</red> gerekiyor.';

  @override
  String get deleteWatch => 'İzleme hesabını sil';

  @override
  String get allTransfer => 'Tümü';

  @override
  String get noMoreSupported => 'Artık desteklenmeyen hesap';

  @override
  String get password => 'Şifresi';

  @override
  String get confirmPasswordShort => 'Şifresini Onayla';

  @override
  String get share => 'Paylaş';

  @override
  String get copy => 'Kopyala';

  @override
  String get mnemonicLost =>
      'Anımsatıcı cümleniz kaybolursa, varlıklarınız sonsuza kadar kaybolacak.';

  @override
  String get protectMnemonic =>
      'Anımsatıcı cümleyi korumanın tüm sorumluluğunu alıyorum.';

  @override
  String get scam => 'sahtekarlık';

  @override
  String get hdDerivedPath => 'HD Yolu';

  @override
  String get emptyAddress => 'Adres kaydedilmedi';

  @override
  String get speedUp => 'Hızlandır';

  @override
  String get speedUpTitle => 'İşlemi Hızlandırın';

  @override
  String get cancelTransaction => 'İşlemi İptal Et';

  @override
  String get speedUpTip =>
      'Normalde bir işlemin onaylanması <light>3 dakika</light> sürer. Ancak ağın yoğun olduğu ve işleminizin 3 dakikadan uzun sürebildiği durumlarda işlem ücretini artırarak işlem sürecini hızlandırabilirsiniz.';

  @override
  String get transactionCancelTip =>
      'Aynı Nonce ile kendinize bir işlem göndererek işlemi iptal edin. Ücret, mevcut işlem ücretinden (+0,0001 MINA) daha yüksek olacaktır.';

  @override
  String get currentFee => 'Güncel Ücret';

  @override
  String get stakedBalance => 'Staked';

  @override
  String get testnet => 'Test ağı';

  @override
  String get myWallet => 'Cüzdanım';

  @override
  String get renameAccountName => 'Hesap Adını Değiştir';

  @override
  String get accountNameLimit => 'En fazla 16 karakter';

  @override
  String get github => 'Github’da göz atın';

  @override
  String get noAddress => 'Adres Yok';

  @override
  String get addaddress => 'Adres Ekle';

  @override
  String get editaddress => 'Adresi Düzenle';

  @override
  String get deleteaddress => 'Adres Silinsin Mi?';

  @override
  String get addNetWork => 'Ağ Ekle';

  @override
  String get editNetWork => 'Ağı Düzenle';

  @override
  String get nodeAddress => 'Düğüm URL';

  @override
  String get nodeAlert =>
      'Yalnızca güvendiğiniz özel düğümleri ekleyin. Bilinmeyen düğümlerin kullanılması riskli olabilir.';

  @override
  String get invalidContact => 'Geçersiz Adres';

  @override
  String get submitNode => 'Düğümünüzü bu listeye gönderin/güncelleyin';

  @override
  String get ledgerTip1 => 'Ledger’ınızı telefona bağlayın.';

  @override
  String get ledgerTip2 =>
      '<semiBold>Mina hazır</semiBold> mesajını görene kadar Ledger cihazınızda Mina uygulamasını açın.';

  @override
  String get ledgerTip3 =>
      'Auro Wallet ile kullanmak istediğiniz donanım cüzdanını seçin.';

  @override
  String get connectHardwareWallet => 'Donanım Cüzdanını Bağlayın';

  @override
  String get selectHdPath => 'HD Yolunu Seçin';

  @override
  String get ledgerStatus => 'Ledger Durumu';

  @override
  String get ledgerAddressTip1 =>
      'Lütfen işleme Ledger donanım cüzdanındaki bildirimlere göre devam edin.';

  @override
  String get ledgerAddressTip3 =>
      '<lightred>Bu pencereyi kapatmayın.</lightred> Ledger tamamlandığında sayfa otomatik olarak yönlendirilecektir.';

  @override
  String get ledgerWaitingTip =>
      '<yellowBold>SAKIN</yellowBold><yellow> bu ekrandan ayrılmayın.\n</yellow>Ledger tamamlandığında sayfa otomatik olarak yönlendirilecektir.';

  @override
  String get waitingLedger => 'İmza bekleniyor';

  @override
  String get waitingLedgerSign =>
      'Lütfen Ledger donanım cüzdanında onaylayın, imzanın atılması 1-3 dakika sürebilir.';

  @override
  String get openMinaApp =>
      'Ledger cihazı bağlı ancak Mina uygulaması açık değil. Lütfen Mina uygulamasını Ledger’da açın.';

  @override
  String get unlockLedger =>
      'Bağlantı hatası. Lütfen Ledger cihazınızın kilidinin açık olduğundan emin olun.';

  @override
  String get ledgerPairingError =>
      'Bluetooth eşleştirme başarısız oldu. Lütfen cihazınızın Bluetooth ayarlarına gidin, Ledger cihazınızı bulun, dokunun ve \"Bu Aygıtı Unut\" seçeneğini seçin, ardından tekrar bağlanmayı deneyin.';

  @override
  String get ledgerReject => 'Ledger tarafından reddedildi';

  @override
  String get ledgerSearching => 'Arıyor…';

  @override
  String get ledgerSupport =>
      '(<lightred>Yalnızca Ledger Nano X’i destekler</lightred>)';

  @override
  String get termsAndPrivacy_line1 =>
      'Bu hizmet Auro Wallet tarafından sağlanmaktadır, lütfen Şartlar ve Koşullar ile Gizlilik Politikasını dikkatlice okuyup anlamak için zaman ayırın.';

  @override
  String get termsAndPrivacy_line2 =>
      'Lütfen <conditions>Şartlar ve Koşullar</conditions> ile <policy>Gizlilik Politikası</policy>’nI dikkatlice okuyun. Tamamen anladıysanız ve kabul ediyorsanız, bu cüzdan hizmetini kullanmaya başlamak için lütfen [Kabul Ediyorum]’a tıklayın.';

  @override
  String get contributeLanguage => 'Dile Katkıda Bulunun';

  @override
  String get available => 'Mevcut';

  @override
  String importSameAccount_1(String address) {
    return 'Oluşturulacak hesabın adresi: <theme>$address</theme>';
  }

  @override
  String importSameAccount_2(String accountName) {
    return 'Mevcut bir içe aktarılmış hesap [$accountName] bu adresin kopyasıdır. Auro Wallet, yinelenen hesap adreslerinin oluşturulmasını desteklemez. İçe aktarılan hesabı silmek için lütfen <acmanage>Cüzdan Yönetimi</acmanage>’ne gidin.';
  }

  @override
  String get browser => 'Tarayıcı';

  @override
  String get searchOrInputUrl => 'Ara veya URL Gir';

  @override
  String get allowSiteAddNode => 'Bu sitenin ağ eklemesine izin ver';

  @override
  String get removeFavorites => 'Favorilerden çıkar';

  @override
  String get addFavorites => 'Favorilere ekle';

  @override
  String get copyLink => 'Bağlantıyı Kopyala';

  @override
  String get openInBrowser => 'Tarayıcıda aç';

  @override
  String get connectionRequest => 'Bağlantı İsteği';

  @override
  String get connectTip => 'Bu web sitesi hesabınızı görüntülemek istiyor';

  @override
  String get trustedSitesTip =>
      'Yalnızca güvenilir sitelere bağlandığınızdan emin olun';

  @override
  String get signatureRequest => 'İmza Talebi';

  @override
  String get content => 'İçerik';

  @override
  String get transactionFee => 'İşlem Ücreti';

  @override
  String get siteSuggested => 'Önerilen site';

  @override
  String get rawData => 'İşlenmemiş veri';

  @override
  String get showData => 'Veriyi göster';

  @override
  String get warning => 'UYARI';

  @override
  String get warningTip =>
      'Sahtekarlık olarak işaretlenmiş bir adres veya sözleşmeyle etkileşimde bulunuyorsunuz. İmzalarsanız tüm NFT\'lerinize ve cüzdanınızdaki tüm fonlara veya diğer varlıklara erişiminizi kaybedebilirsiniz.';

  @override
  String get switchNetwork => 'Ağ Değiştir';

  @override
  String get allowSwitch => 'Bu sitenin ağı değiştirmesine izin verilsin mi?';

  @override
  String get current => 'Geçerli';

  @override
  String get target => 'Hedef';

  @override
  String get recently => 'Geçmiş';

  @override
  String get favorites => 'Favoriler';

  @override
  String get browserEmptyTip => 'Favorileriniz ve geçmişiniz burada görünecek';

  @override
  String get websiteNotFound => 'Web Sitesi Bulunamadı';

  @override
  String get ledgerNotSupportSign => 'Ledger imza mesajını desteklemiyor';

  @override
  String get notSupportNow => 'Henüz desteklenmiyor';

  @override
  String get newFee => 'Yeni Ücret';

  @override
  String get addAccount => 'Hesap Ekle';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get hardwareWallet => 'Donanım Cüzdanı';

  @override
  String get showTestnet => 'Test Ağını Göster';

  @override
  String get ledgerConnected => 'Ledger bağlandı';

  @override
  String get ledgerNotConnected => 'Ledger cihazı bağlı değil';

  @override
  String get txType => 'İşlem Türü';

  @override
  String get appConnection => 'Uygulama Bağlantıları';

  @override
  String get noConnectedApps => 'Bağlı uygulama yok';

  @override
  String get txHistoryTip => 'İşlem geçmişi sağlanamıyor';

  @override
  String get tokens => 'TOKENS';

  @override
  String get assetManagement => 'Varlık Yönetimi';

  @override
  String newTokenFound(String count) {
    return '$count yeni jeton bulundu';
  }

  @override
  String get ignore => 'Yoksay';

  @override
  String get balance => 'Bakiye';

  @override
  String get updateTokenInfo =>
      'Jeton bilgilerinizi güncellemek ister misiniz?';

  @override
  String get noTxHistory => 'İşlem geçmişi yok';

  @override
  String get buildFailed => 'Paketleme başarısız oldu';

  @override
  String get appAccess => 'App Erişimi';

  @override
  String get transactions => 'İşlemler';

  @override
  String get unlock => 'Kilidi Aç';

  @override
  String get useBiometricAuthentication => 'Biyometrik Kimlik Doğrulama Kullan';

  @override
  String get loginWithPassword => 'Şifre ile Giriş Yap';

  @override
  String get clickToVerification => 'Doğrulamayı başlatmak için tıklayın';

  @override
  String get resetWallet => 'Cüzdanı Sıfırla';

  @override
  String get biometricAuth => 'Biyometrik Kimlik Doğrulama';

  @override
  String get tapToVerify => 'Doğrulamak için dokunun';

  @override
  String get zkAppTipTitle => 'Üçüncü taraf bir zkApp\'i ziyaret ediyorsunuz';

  @override
  String get zkAppTipContent =>
      'Bu zkApp\'e girerken üçüncü taraf zkApp Kullanıcı Sözleşmesine tabisiniz.';

  @override
  String get passwordVerification => 'Şifre Doğrulama';

  @override
  String get pwdVerificationTip => 'En az bir seçenek seçilmelidir.';

  @override
  String get selectAsset => 'Varlık Seç';

  @override
  String tokenPendingTip(int count) {
    return 'Şu anda <light>$count</light> devam eden işlem var, iptal edin veya mevcut işlemi sürdürün.';
  }

  @override
  String get pendingTx => 'Bekleyen İşlem';

  @override
  String get signed => 'İMZALI';

  @override
  String get backToAppTitle => 'Uygulamaya geri dön';

  @override
  String get backToAppDesc =>
      'Hizmetlerini kullanmaya devam etmek için lütfen uygulamaya geri dönün.';

  @override
  String get walletConnectTitle => 'WalletConnect';

  @override
  String get noWalletConnectSession => 'Oturum yok';

  @override
  String get preferences => 'Tercihler';

  @override
  String get response => 'Yanıt';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get scanTip => 'Adres QR kodu ve WalletConnect desteği';

  @override
  String get notificationTxSuccess => 'İşlem Onaylandı';

  @override
  String get notificationTxSuccessBody => 'İşleminiz onaylandı.';

  @override
  String get renameWallet => 'Cüzdanı Yeniden Adlandır';

  @override
  String get deleteWallet => 'Cüzdanı Sil';

  @override
  String get deleteWalletWarning =>
      'Bu işlem geri alınamaz. Silmeden önce anımsatıcı ifadenizi yedeklediğinizden emin olun.';

  @override
  String get hdWallet => 'HD Cüzdan';

  @override
  String get walletNamePlaceholder => 'Cüzdan adı girin';

  @override
  String get accounts => 'hesap';

  @override
  String get selectWallet => 'Cüzdan Seç';

  @override
  String get noMnemonicWallet =>
      'Kullanılabilir HD cüzdan yok. Lütfen önce bir cüzdan oluşturun veya içe aktarın.';

  @override
  String get walletDetails => 'Cüzdan Detayları';

  @override
  String get walletNameLabel => 'Cüzdan Adı';

  @override
  String get changeWalletName => 'Cüzdan Adını Değiştir';

  @override
  String get deleteWalletConfirm =>
      'Bu cüzdanı silmek istediğinizden emin misiniz?';

  @override
  String get privateKeyWallet => 'Özel Anahtar';

  @override
  String get keystoreWallet => 'Keystore';

  @override
  String get ledgerWallet => 'Ledger';

  @override
  String get watchWallet => 'Sadece İzleme';

  @override
  String get rename => 'Yeniden Adlandır';

  @override
  String get backupMnemonic => 'Anımsatıcıyı Yedekle';

  @override
  String get addWallet => 'Cüzdan Ekle';

  @override
  String get importWallet => 'Cüzdanı İçe Aktar';

  @override
  String get walletManagement => 'Cüzdan Yönetimi';

  @override
  String get mnemonicPhrase => 'Anımsatıcı İfade';

  @override
  String get mnemonicImportDesc =>
      '12 veya 24 kelimelik anımsatıcı ifade ile içe aktar';

  @override
  String get privateKeyImportDesc => 'Özel anahtar ile içe aktar';

  @override
  String get keystoreImportDesc => 'Keystore dosyası ile içe aktar';

  @override
  String get ledgerImportDesc => 'Bluetooth veya USB ile bağlan';

  @override
  String get getStarted => 'Başlayın';

  @override
  String get ledgerIntroDesc =>
      'Başlamadan önce, Ledger cihazınızda en güncel yazılımın yüklü olduğundan, cihazın kurulduğundan ve Mina uygulamasının yüklendiğinden emin olun.';

  @override
  String get ledgerIntroStep1 => 'Ledger\'ınızı telefona bağlayın.';

  @override
  String get ledgerIntroStep2 =>
      'Ledger cihazınızda Mina uygulamasını açın, <semiBold>Mina is ready</semiBold> yazısını görene kadar bekleyin.';

  @override
  String get hdPathDesc =>
      'Aşağıdaki ayarın ne olduğunu bilmiyorsanız, değiştirmenize gerek yoktur. Ayrıntılı <link>talimatları</link> görüntüleyin.';

  @override
  String get currentEpoch => 'Mevcut Dönem';

  @override
  String get earnOnMina => 'MINA ile Kazan';

  @override
  String get apr => 'Yıllık Getiri';

  @override
  String get lockTime => 'Kilitleme Süresi';

  @override
  String get notLocked => 'Kilitli Değil';

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Aktif Değil';

  @override
  String get unknownNetworkStaking => 'Bilinmeyen ağ, bilgi sağlanamıyor.';

  @override
  String get redelegate => 'Yeniden Delege Et';

  @override
  String get stake => 'Stake';

  @override
  String get stakeInfoBanner =>
      'Mina protokolünde stake, bir delegasyon işlemidir. Varlıklarınız kilitlenmez ve istediğiniz zaman transfer edebilirsiniz.';

  @override
  String get validator => 'Doğrulayıcı';

  @override
  String get fromValidator => 'Mevcut Doğrulayıcı';

  @override
  String get toValidator => 'Yeni Doğrulayıcı';

  @override
  String get currentValidator => 'Mevcut Doğrulayıcı';

  @override
  String get selectValidator => 'Seç';

  @override
  String get epochEstimate => '15 gün (1 dönem) tahmini';

  @override
  String get threeMonthsEstimate => '3 ay tahmini';

  @override
  String get sixMonthsEstimate => '6 ay tahmini';

  @override
  String get staked => 'Stake Edildi';

  @override
  String get networkFee => 'Ağ Ücreti';

  @override
  String get inputFeeError => 'Lütfen geçerli bir ağ ücreti girin';

  @override
  String get inputNonceError => 'Lütfen geçerli bir nonce girin';

  @override
  String get biometricUpdateFailed =>
      'Biyometrik veriler güncellenemedi. Lütfen tekrar deneyin.';

  @override
  String notificationSentTitle(String amount, String symbol) {
    return '$amount $symbol Gönderildi';
  }

  @override
  String notificationSentBody(String address) {
    return '$address adresine';
  }

  @override
  String get notificationSendFailedTitle => 'Gönderim Başarısız';

  @override
  String notificationSendFailedBody(String amount, String symbol) {
    return '$amount $symbol gönderilemedi. Lütfen tekrar deneyin.';
  }

  @override
  String get notificationDelegationSuccessTitle => 'Delegasyon Onaylandı';

  @override
  String notificationDelegationSuccessBody(String address) {
    return '$address adresine delegasyon yapıldı';
  }

  @override
  String get notificationDelegationFailedTitle => 'Delegasyon Başarısız';

  @override
  String get notificationDelegationFailedBody =>
      'Delegasyonunuz başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get notificationZkAppSuccessTitle => 'zkApp İşlemi Onaylandı';

  @override
  String get notificationZkAppSuccessBody => 'zkApp işleminiz onaylandı.';

  @override
  String get notificationZkAppFailedTitle => 'zkApp İşlemi Başarısız';

  @override
  String get notificationZkAppFailedBody =>
      'zkApp işleminiz başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get notificationEnable => 'Bildirimler';
}
