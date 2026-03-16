// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get passwordError => 'Неверный пароль';

  @override
  String get createWallet => 'Создать кошелёк';

  @override
  String get restoreWallet => 'Восстановить кошелёк';

  @override
  String get inputPassword => 'Введите пароль';

  @override
  String get createPasswordTip =>
      'Пароль будет использоваться для проверки личности при отправке транзакций в Auro Wallet. Auro Wallet не хранит пароль и не извлекает его для вас. Пожалуйста, храните свой пароль в безопасности.';

  @override
  String get next => 'Далее';

  @override
  String get atLeastOneLowercaseLetter => 'строчная буква';

  @override
  String get atLeastOneUppercaseLetter => 'заглавная буква';

  @override
  String get atLeastOneNumber => 'цифра';

  @override
  String get passwordRequires => '8 символов';

  @override
  String get passwordDifferent => 'Пароли не совпадают';

  @override
  String get backTips_1 =>
      'Создать резервную копию мнемонической фразы сейчас!';

  @override
  String get backTips_2 =>
      'Мнемоническая фраза состоит из 12 английских слов, которые невозможно восстановить, если они утеряны. Убедитесь, что мнемоническая фраза хранится в надежном месте.';

  @override
  String get backTips_3 =>
      'Если доступ к кошельку невозможен из-за потери устройства или по какой-либо другой причине, импорт мнемонической фразы - единственный способ вернуть свои активы.';

  @override
  String get show_seed_content =>
      'Пожалуйста, запишите следующую мнемоническую фразу и сохраните ее в надежном месте.';

  @override
  String get show_seed_button => 'Резервное копирование подтверждено';

  @override
  String get seed_error => 'Неправильная мнемоническая фраза';

  @override
  String get backup_success => 'Поздравляем, вы успешно создали кошелек!';

  @override
  String get backup_success_restore =>
      'Поздравляем, вы успешно восстановили кошелек!';

  @override
  String get inputSeed =>
      'Пожалуйста, введите 12 мнемонических фраз по порядку, без заглавных букв и знаков препинания.';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get wallet => 'Кошелёк';

  @override
  String get staking => 'Стейкинг';

  @override
  String get setting => 'Настройки';

  @override
  String get stakingStatus_1 => 'Делегировано';

  @override
  String get stakingStatus_2 => 'Не делегировано';

  @override
  String get send => 'Отправить';

  @override
  String get receive => 'Получить';

  @override
  String get history => 'ИСТОРИЯ';

  @override
  String get toAddress => 'Кому';

  @override
  String get fromAddress => 'От';

  @override
  String get amount => 'Сумма';

  @override
  String get memo => 'Memo(Опционально)';

  @override
  String get memo2 => 'Мемо';

  @override
  String get fee => 'Комиссия';

  @override
  String get fee_slow => 'Медленно';

  @override
  String get fee_default => 'По умолчанию';

  @override
  String get fee_fast => 'Быстро';

  @override
  String get advanceMode => 'Расширенный';

  @override
  String get sendDetail => 'Детали транзакции';

  @override
  String get sendAddressError =>
      'Пожалуйста, введите корректный адрес кошелька';

  @override
  String get amountError => 'Пожалуйста, введите корректную сумму';

  @override
  String get balanceNotEnough => 'Недостаточный Баланс';

  @override
  String get txHash => 'Хэш транзакции';

  @override
  String get time => 'Время';

  @override
  String get goToExplrer => 'Детали запроса';

  @override
  String get details => 'Детали';

  @override
  String get walletAddress => 'Адрес кошелька';

  @override
  String get copySuccess => 'Скопировано';

  @override
  String get accountManage => 'Управление счётами';

  @override
  String get create => 'Создать';

  @override
  String get import => 'Импортировать';

  @override
  String get importLedger => 'Ledger';

  @override
  String get accountName => 'Название счёта';

  @override
  String get inputAccountName => 'Пожалуйста, введите имя вашего счета';

  @override
  String get importAccount_2 =>
      'Импортированные учетные записи не будут связаны с вашим первоначально созданным в Auro Wallet.';

  @override
  String get importAccount_3 =>
      'Импортированные счета будут отмечены в списке счетов символом [Импортировано].';

  @override
  String get accountInfo => 'Детали счета';

  @override
  String get accountAddress => 'Адрес Счёта';

  @override
  String get exportPrivateKey => 'Экспорт приватного ключа';

  @override
  String get accountDelete => 'Удалить счёт';

  @override
  String get cancel => 'Отмена';

  @override
  String get privateKeyTip_1 =>
      'Приватный ключ состоит из строки символов, владение закрытым ключом равносильно владению активом.';

  @override
  String get privateKeyTip_2 =>
      'После потери закрытого ключа его невозможно восстановить. Пожалуйста, сделайте резервную копию приватного ключа и храните его в безопасном месте.';

  @override
  String get security => 'Безопасность';

  @override
  String get network => 'Сеть';

  @override
  String get language => 'Язык';

  @override
  String get currency => 'Валюта';

  @override
  String get about => 'О проекте';

  @override
  String get restoreSeed => 'Резервная копия мнемонической фразы';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get inputOldPwd => 'Введите <bold>старый</bold> пароль';

  @override
  String get inputNewPwd => 'Введите <bold>новый</bold> пароль';

  @override
  String get inputNewPwdRepeat => 'Повторно введите <bold>новый</bold> пароль';

  @override
  String get pwdChangeSuccess => 'Пароль изменен';

  @override
  String get delete => 'Удалить';

  @override
  String get urlError_1 => 'Недопустимый URL-адрес узла';

  @override
  String get urlError_2 => 'Адрес уже существует';

  @override
  String get urlError_3 => 'Адрес узла уже существует';

  @override
  String get prompt => 'Напоминание';

  @override
  String get deleteAccountTip =>
      'Удаленную учетную запись можно восстановить только с помощью мнемонической фразы или приватного ключа. Убедитесь, что вы создали резервную копию мнемонической фразы и приватного ключа.';

  @override
  String get isee => 'Ок';

  @override
  String get walletHomeTip =>
      'Сеть Mina взимает единовременную комиссию за создание счета в размере 1 MINA для предотвращения спама. Она автоматически вычитается из первой полученной транзакции и не взимается кошельком.';

  @override
  String get startHome => 'Начать';

  @override
  String get walletName => 'Auro Кошелёк';

  @override
  String get privateError => 'Неверный приватный ключ';

  @override
  String get improtRepeat => 'Не импортируйте повторно';

  @override
  String get confirmDeleteNode => 'Вы уверены, что хотите удалите его?';

  @override
  String get backupSuccess => 'Успех';

  @override
  String get walletAbout =>
      'Auro Wallet - это кошелек non-custodial, разработанный сообществом. Прост, удобный и полностью открытый. В настоящее время он поддерживает все функции протокола Mina.';

  @override
  String get copyTipContent =>
      'Копирование приватного ключа может быть рискованным, поскольку буфер обмена легко отслеживается и может быть украден сторонними приложениями.';

  @override
  String get copyTipContent2 =>
      'Перед выполнением этой операции убедитесь в абсолютной безопасности используемой системы и сетевого окружения.';

  @override
  String get copyConfirm => 'Копировать в любом случае';

  @override
  String get copyCancel => 'Прекратить копирование';

  @override
  String get scantopay => 'Сканировать, чтобы заплатить мне';

  @override
  String addressQrTip(String symbol) {
    return 'Отсканируйте QR-код и переведите на него <strongBlack>$symbol</strongBlack>';
  }

  @override
  String get goToExplorer => 'Проверьте историю транзакций';

  @override
  String get homeNoTx => 'Неизвестный узел, не способный предоставить историю.';

  @override
  String get followUs => 'Следуйте за нами';

  @override
  String get createPassword => 'Создать пароль';

  @override
  String get epochInfo => 'Информация об эпохе';

  @override
  String get delegationInfo => 'Делегировании';

  @override
  String get emptyDelegateTitle => 'Вы еще не делегировали';

  @override
  String get emptyDelegateDesc1 =>
      'Делегирование MINA на узел Block Producer может помочь вам получить награды за производство блоков. Производитель блока будет распределять вознаграждение в соответствии с вашей делегированной пропорцией, и процент наград зависит от установления ставок производителем блока.';

  @override
  String get emptyDelegateDesc2 =>
      'Эффективное время делегирования и вознаграждения распределительных правил:';

  @override
  String get emptyDelegateDesc3 => 'Руководство по стейкингу';

  @override
  String get changeNode => 'Изменение';

  @override
  String get stakingProviderName => 'Валидатор';

  @override
  String get goStake => 'Перейти к стейкингу';

  @override
  String get epochEndTime => 'Текущая эпоха заканчивается';

  @override
  String get searchPlaceholder => 'Имя или адрес валидатора';

  @override
  String get inputNodeAddress => 'Пожалуйста, введите адрес узла';

  @override
  String get nodeProviders => 'Валидатор';

  @override
  String get manualAdd => 'Входной адрес узла Валидатор';

  @override
  String get providerAddress => 'BP Адрес';

  @override
  String get copyToClipboard => 'Копировать в буфер обмена';

  @override
  String get loading => 'Загрузить';

  @override
  String get keystoreError => 'Содержимое хранилища ключей или пароль неверны';

  @override
  String get pleaseInputKeyPair => 'Введите содержимое файла Keystore.';

  @override
  String get pleaseInputKeyPairPwd => 'Пароль хранилища ключей';

  @override
  String get pleaseInputPriKey => 'Пожалуйста, введите приватный ключ.';

  @override
  String get privateKey => 'Приватный ключ';

  @override
  String get applied => 'ПРИМЕНЕНО';

  @override
  String get failed => 'НЕ УДАЛОСЬ';

  @override
  String get pending => 'В ОЖИДАНИИ';

  @override
  String get blockProducerName => 'Имя производителя блоков';

  @override
  String get producerName => 'Имя производителя блоков';

  @override
  String get blockProducerAddress => 'Адрес валидатора';

  @override
  String get notValidAddress => 'Не действительный MINA адрес';

  @override
  String get agree => 'Принять';

  @override
  String get userAgree => 'Условия';

  @override
  String get imported => 'Импортировано';

  @override
  String get watchAccount => 'Наблюдаемый счёт';

  @override
  String get watchMode => 'Режим просмотра';

  @override
  String get textWatchModeAddress => 'Введите или вставьте адрес кошелька';

  @override
  String get watchLabel => 'Наблюдать';

  @override
  String get timeout => 'Истекло время ожидания';

  @override
  String get rootTip =>
      'Обнаружено, что система была рутирована или используется симулятор. Дальнейшее использование будет сопряжено с риском!';

  @override
  String get exitConfirm => 'Вы хотите выйти из приложения?';

  @override
  String get unlockBioEnable => 'Биометрическая аутентификация';

  @override
  String get unlockBio => 'Пройдите аутентификацию для разблокировки';

  @override
  String get feeTooLarge => 'Комиссия намного выше средней';

  @override
  String get add => 'Добавить';

  @override
  String get addressbook => 'Адресная книга';

  @override
  String get name => 'Имя';

  @override
  String get address => 'Адрес';

  @override
  String get repeatContact => 'Адрес существует';

  @override
  String get backupInOrder =>
      'Чтобы убедиться, что вы сохранили мнемоническую фразу, введите 12 слов по порядку.';

  @override
  String get refuse => 'Отклонить';

  @override
  String get termsDialogTitle => 'Условия и политика конфиденциальности';

  @override
  String get privacy => 'Политика конфиденциальности';

  @override
  String get scan => 'Сканировать';

  @override
  String get restoreTip =>
      'Если вы хотите импортировать приватный ключ/keystore или подключить Ledger, сначала нужно [Создать кошелек] или [Восстановить кошелек].';

  @override
  String get reset => 'Сброс';

  @override
  String get resetWarnContentTitle =>
      'Вы уверены, что хотите сбросить кошелёк?';

  @override
  String get resetWarnContent =>
      'После сброса существующего кошелька все данные будут потеряны. Для восстановления можно использовать только мнемоническую фразу. Пожалуйста, убедитесь, что вы сделали резервную копию мнемонической фразы перед сбросом кошелька.';

  @override
  String get confirmReset => 'Сброс';

  @override
  String get cancelReset => 'Отменить';

  @override
  String deleteConfirm(String tag) {
    return 'Введите \'$tag\', чтобы навсегда стереть текущий кошелек';
  }

  @override
  String get edit => 'Изменить';

  @override
  String get save => 'Сохранить';

  @override
  String get watchModeWarn2 =>
      'Auro Wallet больше не поддерживает [Наблюдение за счётом] . Вам необходимо <red>удалить все наблюдаемые счета</red>, прежде чем вы сможете продолжить использовать Auro Wallet.';

  @override
  String get deleteWatch => 'Удалить наблюдаемый аккаунт';

  @override
  String get allTransfer => 'Максимум';

  @override
  String get noMoreSupported => 'Больше не поддерживается счет';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPasswordShort => 'Подтвердить пароль';

  @override
  String get share => 'Поделиться';

  @override
  String get copy => 'Копировать';

  @override
  String get mnemonicLost =>
      'Если мнемоническая фраза будет утеряна, мои средства будут потеряны навсегда.';

  @override
  String get protectMnemonic =>
      'Я беру на себя полную ответственность за защиту мнемонической фразы.';

  @override
  String get scam => 'скам';

  @override
  String get hdDerivedPath => 'Путь HD';

  @override
  String get emptyAddress => 'Адреса не сохранены';

  @override
  String get speedUp => 'Ускорить';

  @override
  String get speedUpTitle => 'Ускорить транзакцию';

  @override
  String get cancelTransaction => 'Отменить транзакцию';

  @override
  String get speedUpTip =>
      'Обычно подтверждение транзакции занимает <light>3 минуты</light>. Однако если сеть перегружена, ваша транзакция может занять 3 минуты и более, вы можете ускорить процесс, увеличив комиссию за транзакцию.';

  @override
  String get transactionCancelTip =>
      'Отмените транзакцию, отправив транзакцию с тем же Nonce на свой адрес. Комиссия будет больше, чем текущая комиссия за транзакцию (+0,0001 MINA).';

  @override
  String get currentFee => 'Текущая комиссия';

  @override
  String get stakedBalance => 'Застейкано';

  @override
  String get testnet => 'Тестнет';

  @override
  String get myWallet => 'Мой кошелёк';

  @override
  String get renameAccountName => 'Изменить имя счета';

  @override
  String get accountNameLimit => 'Не более 16 символов';

  @override
  String get github => 'Проверьте на Github';

  @override
  String get noAddress => 'Нет Адреса';

  @override
  String get addaddress => 'Добавить адрес';

  @override
  String get editaddress => 'Изменить адрес';

  @override
  String get deleteaddress => 'Удалить адрес?';

  @override
  String get addNetWork => 'Добавить сеть';

  @override
  String get editNetWork => 'Изменить сеть';

  @override
  String get nodeAddress => 'URL-адрес узла';

  @override
  String get nodeAlert =>
      'Добавьте только пользовательские узлы, которым вы доверяете. Использование неизвестных узлов может быть рискованным.';

  @override
  String get invalidContact => 'Неверный адрес';

  @override
  String get submitNode => 'Добавить/Обновить свой узел в этот список';

  @override
  String get ledgerTip1 => 'Подключите устройство Ledger к телефону.';

  @override
  String get ledgerTip2 =>
      'Откройте приложение Mina на своем устройстве Ledger, пока не увидите <bold>Mina is ready</bold>.';

  @override
  String get ledgerTip3 =>
      'Выберите аппаратный кошелек, который вы хотите использовать с Auro Wallet.';

  @override
  String get connectHardwareWallet => 'Подключить аппаратный кошелек';

  @override
  String get selectHdPath => 'Выберите путь HD';

  @override
  String get ledgerStatus => 'Состояние Ledger';

  @override
  String get ledgerAddressTip1 =>
      'Пожалуйста, продолжайте последующую операцию в соответствии с подсказками аппаратного кошелька Ledger.';

  @override
  String get ledgerAddressTip3 =>
      '<lightred>Не закрывайте это окно.</lightred> После завершения работы с Ledger, страница автоматически перенаправится.';

  @override
  String get waitingLedger => 'Ожидание подтверждения…';

  @override
  String get waitingLedgerSign =>
      'Пожалуйста, подтвердите в аппаратном кошельке Ledger, подпись может занять 1-3 минуты.';

  @override
  String get openMinaApp =>
      'Устройство Ledger подключено, но приложение Mina не открыто. Пожалуйста, откройте приложение Mina в устройстве Ledger.';

  @override
  String get unlockLedger =>
      'Не удалось подключиться. Пожалуйста, убедитесь, что устройство Ledger разблокировано.';

  @override
  String get ledgerReject => 'Отклонено Ledger-ом';

  @override
  String get ledgerSearching => 'Поиск…';

  @override
  String get ledgerSupport =>
      '(<lightred>Поддерживает только Ledger Nano X</lightred>)';

  @override
  String get termsAndPrivacy_line1 =>
      'Эта услуга предоставляется компанией Auro Wallet, пожалуйста, уделите время тому, чтобы внимательно прочитать и понять Правила и условия и Политику конфиденциальности.';

  @override
  String get termsAndPrivacy_line2 =>
      'Пожалуйста, внимательно прочитайте <conditions>Сроки и условия</conditions> и <policy>Политику конфиденциальности</policy>. Если вы все поняли и согласны, пожалуйста, нажмите [Принять], чтобы начать пользоваться кошельком.';

  @override
  String get contributeLanguage => 'Добавить язык';

  @override
  String get available => 'Доступно';

  @override
  String importSameAccount_1(String address) {
    return 'Адрес создаваемой учетной записи: <theme>$address</theme>';
  }

  @override
  String importSameAccount_2(String accountName) {
    return 'Существующий импортированный счет [$accountName] является дубликатом этого адреса. Auro Wallet не поддерживает дублирование адресов счетов. Пожалуйста, перейдите в раздел <acmanage>Управление счетом</acmanage>, чтобы удалить импортированный счет.';
  }

  @override
  String get browser => 'Браузер';

  @override
  String get searchOrInputUrl => 'Поиск или ввод URL-адреса';

  @override
  String get allowSiteAddNode => 'Разрешить этому сайту добавить сеть';

  @override
  String get removeFavorites => 'Удалить из избранного';

  @override
  String get addFavorites => 'Добавить в избранное';

  @override
  String get copyLink => 'Копировать ссылку';

  @override
  String get openInBrowser => 'Открыть в браузере';

  @override
  String get connectionRequest => 'Запрос на подключение';

  @override
  String get connectTip => 'Этот сайт хочет просмотреть ваш счёт';

  @override
  String get trustedSitesTip =>
      'Убедитесь, что вы подключаетесь только к надежным сайтам';

  @override
  String get signatureRequest => 'Запрос на подпись';

  @override
  String get content => 'Содержание';

  @override
  String get transactionFee => 'Комиссия за транзакцию';

  @override
  String get siteSuggested => 'Предложенный сайт';

  @override
  String get rawData => 'Необработанные данные';

  @override
  String get showData => 'Показать данные';

  @override
  String get warning => 'ВНИМАНИЕ';

  @override
  String get warningTip =>
      'Вы взаимодействуете с адресом или контрактом, который был отмечен как мошеннический. Если вы подпишите, можете потерять доступ ко всем вашим NFT и любым средствам или другим активам в вашем кошельке.';

  @override
  String get switchNetwork => 'Переключить сеть';

  @override
  String get allowSwitch => 'Разрешить этому сайту переключать сеть?';

  @override
  String get current => 'Текущий';

  @override
  String get target => 'Цель';

  @override
  String get recently => 'Недавно';

  @override
  String get favorites => 'Избранные';

  @override
  String get browserEmptyTip =>
      'Здесь будут отображаться ваши избранные и история';

  @override
  String get websiteNotFound => 'Сайт не найден';

  @override
  String get ledgerNotSupportSign =>
      'Ledger не поддерживает сообщения с подписью';

  @override
  String get notSupportNow => 'Пока не поддерживается';

  @override
  String get newFee => 'Новая комиссия';

  @override
  String get addAccount => 'Добавить аккаунт';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get hardwareWallet => 'Аппаратный кошелёк';

  @override
  String get showTestnet => 'Показать Тестнеты';

  @override
  String get ledgerConnected => 'Устройство Ledger подключено';

  @override
  String get ledgerNotConnected => 'Устройство Ledger не подключено';

  @override
  String get txType => 'Тип транзакции';

  @override
  String get appConnection => 'Подключения приложений';

  @override
  String get noConnectedApps => 'Нет подключенных приложений';

  @override
  String get txHistoryTip => 'Невозможно предоставить историю транзакций';

  @override
  String get tokens => 'TOKENS';

  @override
  String get assetManagement => 'Управление активами';

  @override
  String newTokenFound(String count) {
    return 'Найдено $count новых токенов';
  }

  @override
  String get ignore => 'Игнорировать';

  @override
  String get balance => 'Баланс';

  @override
  String get updateTokenInfo => 'Обновить информацию о токенах?';

  @override
  String get noTxHistory => 'История транзакций отсутствует';

  @override
  String get buildFailed => 'Сборка не удалась';

  @override
  String get appAccess => 'App Доступ';

  @override
  String get transactions => 'Транзакции';

  @override
  String get unlock => 'Разблокировать';

  @override
  String get useBiometricAuthentication =>
      'Использовать биометрическую аутентификацию';

  @override
  String get loginWithPassword => 'Войти с паролем';

  @override
  String get clickToVerification => 'Нажмите, чтобы начать проверку';

  @override
  String get resetWallet => 'Сброс Кошелька';

  @override
  String get biometricAuth => 'Биометрическая аутентификация';

  @override
  String get tapToVerify => 'Нажмите, чтобы подтвердить';

  @override
  String get zkAppTipTitle => 'Вы посещаете стороннее zkApp';

  @override
  String get zkAppTipContent =>
      'При входе в это zkApp вы подчиняетесь Пользовательскому соглашению стороннего zkApp.';

  @override
  String get passwordVerification => 'Проверка пароля';

  @override
  String get pwdVerificationTip => 'Необходимо выбрать хотя бы один вариант.';

  @override
  String get selectAsset => 'Выбрать актив';

  @override
  String tokenPendingTip(int count) {
    return 'В настоящее время есть <light>$count</light> активных транзакций, отменить или продолжить текущую операцию.';
  }

  @override
  String get pendingTx => 'Ожидаемая транзакция';

  @override
  String get signed => 'ПОДПИСАНО';

  @override
  String get backToAppTitle => 'Назад в приложение';

  @override
  String get backToAppDesc =>
      'Вернитесь в приложение, чтобы продолжить пользоваться его услугами.';

  @override
  String get walletConnectTitle => 'WalletConnect';

  @override
  String get noWalletConnectSession => 'Нет сессий';

  @override
  String get preferences => 'Настройки';

  @override
  String get response => 'Ответ';

  @override
  String get retry => 'Повторить';

  @override
  String get scanTip => 'Поддержка QR-кода адреса и WalletConnect';

  @override
  String get notificationTxSuccess => 'Транзакция успешна';

  @override
  String get notificationTxFailed => 'Транзакция не удалась';

  @override
  String get notificationTxSuccessBody => 'Ваша транзакция подтверждена.';

  @override
  String notificationTxSuccessBodyWithAmount(String amount, String symbol) {
    return 'Ваша транзакция на $amount $symbol подтверждена.';
  }

  @override
  String get notificationTxFailedBody =>
      'Ваша транзакция не удалась. Пожалуйста, попробуйте снова.';

  @override
  String get renameWallet => 'Переименовать кошелек';

  @override
  String get deleteWallet => 'Удалить кошелек';

  @override
  String get deleteWalletWarning =>
      'Это действие нельзя отменить. Убедитесь, что вы сделали резервную копию мнемонической фразы перед удалением.';

  @override
  String get hdWallet => 'HD Кошелек';

  @override
  String get walletNamePlaceholder => 'Введите название кошелька';

  @override
  String get accounts => 'аккаунтов';

  @override
  String get selectWallet => 'Выбрать кошелек';

  @override
  String get noMnemonicWallet =>
      'Нет доступного HD кошелька. Сначала создайте или импортируйте кошелек.';

  @override
  String get walletDetails => 'Детали кошелька';

  @override
  String get walletNameLabel => 'Название кошелька';

  @override
  String get changeWalletName => 'Изменить название кошелька';

  @override
  String get seedPhrase => 'Мнемоническая фраза';

  @override
  String get deleteWalletConfirm =>
      'Вы уверены, что хотите удалить этот кошелек?';

  @override
  String get walletDeleted => 'Кошелек успешно удален';

  @override
  String get walletRenamed => 'Кошелек успешно переименован';

  @override
  String get privateKeyWallet => 'Приватный ключ';

  @override
  String get keystoreWallet => 'Keystore';

  @override
  String get ledgerWallet => 'Ledger';

  @override
  String get watchWallet => 'Только просмотр';

  @override
  String get rename => 'Переименовать';

  @override
  String get backupMnemonic => 'Резервная копия мнемоники';

  @override
  String get addWallet => 'Добавить кошелек';

  @override
  String get importWallet => 'Импортировать кошелек';

  @override
  String get walletManagement => 'Управление кошельками';

  @override
  String get mnemonicPhrase => 'Мнемоническая фраза';

  @override
  String get mnemonicImportDesc =>
      'Импорт с помощью мнемонической фразы из 12 или 24 слов';

  @override
  String get privateKeyImportDesc => 'Импорт с помощью приватного ключа';

  @override
  String get keystoreImportDesc => 'Импорт с помощью файла Keystore';

  @override
  String get ledgerImportDesc => 'Подключение через Bluetooth или USB';

  @override
  String get getStarted => 'Начало работы';

  @override
  String get ledgerIntroDesc =>
      'Перед началом убедитесь, что на вашем Ledger установлена последняя прошивка, устройство настроено и приложение Mina установлено.';

  @override
  String get ledgerIntroStep1 => 'Подключите Ledger к телефону.';

  @override
  String get ledgerIntroStep2 =>
      'Откройте приложение Mina на Ledger, пока не увидите <bold>Mina is ready</bold>.';

  @override
  String get hdPathDesc =>
      'Если вы не знаете, что означает этот параметр, менять его не нужно. Подробные <link>инструкции</link>.';
}
