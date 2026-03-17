// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get passwordError => 'Невірний пароль';

  @override
  String get createWallet => 'Створити гаманець';

  @override
  String get restoreWallet => 'Відновити гаманець';

  @override
  String get inputPassword => 'Введіть пароль';

  @override
  String get createPasswordTip =>
      'Пароль використовуватиметься для перевірки особи для надсилання транзакцій у Auro Wallet. Auro Wallet не зберігатиме сам пароль і не відновлюватиме його для вас. Будь ласка, бережіть свій пароль.';

  @override
  String get next => 'Далі';

  @override
  String get atLeastOneLowercaseLetter => 'мала літера';

  @override
  String get atLeastOneUppercaseLetter => 'прописна літера';

  @override
  String get atLeastOneNumber => 'номер';

  @override
  String get passwordRequires => '8 символів';

  @override
  String get passwordDifferent => 'Паролі не збігаються';

  @override
  String get backTips_1 =>
      'Зробіть резервну копію вашої мнемонічної фрази зараз!';

  @override
  String get backTips_2 =>
      'Мнемонічна фраза складається з 12 англійських слів, які неможливо відновити, якщо вони загублені. Переконайтеся, що мнемонічна фраза зберігається в надійному місці.';

  @override
  String get backTips_3 =>
      'Якщо до гаманця неможливо отримати доступ через втрату пристрою або з будь-якої іншої причини, імпортування мнемонічної фрази є єдиним способом відновити ваші активи.';

  @override
  String get show_seed_content =>
      'Будь ласка, запишіть наведену нижче мнемонічну фразу та збережіть її в надійному місці.';

  @override
  String get show_seed_button => 'Підтверджена резервна копія';

  @override
  String get seed_error => 'Неправильна мнемонічна фраза';

  @override
  String get backup_success => 'Вітаємо! Ви успішно створили гаманець!';

  @override
  String get backup_success_restore =>
      'Вітаємо, ви успішно відновили гаманець!';

  @override
  String get inputSeed =>
      'Будь ласка, введіть по порядку 12 мнемонічних фраз, без великих літер, розділових знаків.';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get wallet => 'Гаманець';

  @override
  String get staking => 'Ставка';

  @override
  String get setting => 'Налаштування';

  @override
  String get stakingStatus_1 => 'Делегований';

  @override
  String get stakingStatus_2 => 'Неделегований';

  @override
  String get send => 'Надіслати';

  @override
  String get receive => 'Отримати';

  @override
  String get history => 'ІСТОРІЯ';

  @override
  String get toAddress => 'До';

  @override
  String get fromAddress => 'Від';

  @override
  String get amount => 'Сума';

  @override
  String get memo => 'Пам\'ятка (необов\'язково)';

  @override
  String get memo2 => 'Пам\'ятка';

  @override
  String get fee => 'Комісія';

  @override
  String get fee_slow => 'Повільно';

  @override
  String get fee_default => 'Стандартно';

  @override
  String get fee_fast => 'Швидко';

  @override
  String get advanceMode => 'Просунутий';

  @override
  String get sendDetail => 'Деталі транзакції';

  @override
  String get sendAddressError => 'Введіть дійсну адресу гаманця';

  @override
  String get amountError => 'Введіть дійсну суму';

  @override
  String get balanceNotEnough => 'Недостатній баланс';

  @override
  String get txHash => 'Хеш транзакції';

  @override
  String get time => 'Час';

  @override
  String get goToExplrer => 'Деталі запиту';

  @override
  String get details => 'Подробиці';

  @override
  String get walletAddress => 'Адреса гаманця';

  @override
  String get copySuccess => 'Скопійовано';

  @override
  String get accountManage => 'Управління рахунками';

  @override
  String get create => 'Створити';

  @override
  String get import => 'Імпорт';

  @override
  String get importLedger => 'Ledger';

  @override
  String get accountName => 'Ім\'я облікового запису';

  @override
  String get inputAccountName => 'Введіть назву свого облікового запису';

  @override
  String get importAccount_2 =>
      'Імпортовані облікові записи не будуть пов’язані з вашим початково створеним гаманцем Auro.';

  @override
  String get importAccount_3 =>
      'Імпортовані облікові записи будуть позначені [Імпортовані] у списку облікових записів.';

  @override
  String get accountInfo => 'Реквізити облікового запису';

  @override
  String get accountAddress => 'Адреса рахунку';

  @override
  String get exportPrivateKey => 'Експорт закритого ключа';

  @override
  String get accountDelete => 'Видалити аккаунт';

  @override
  String get cancel => 'Скасувати';

  @override
  String get privateKeyTip_1 =>
      'Закритий ключ складається з рядка символів, і володіння закритим ключем еквівалентно володінню правом власності на актив.';

  @override
  String get privateKeyTip_2 =>
      'Після втрати закритого ключа його неможливо відновити. Обов’язково створіть резервну копію закритого ключа та зберігайте його в безпечному місці.';

  @override
  String get security => 'Безпека';

  @override
  String get network => 'Мережа';

  @override
  String get language => 'Мова';

  @override
  String get currency => 'Валюта';

  @override
  String get about => 'Про';

  @override
  String get restoreSeed => 'Резервна мнемонічна фраза';

  @override
  String get changePassword => 'Змінити пароль';

  @override
  String get inputOldPwd => 'Будь ласка, введіть <bold>старий</bold> пароль';

  @override
  String get inputNewPwd => 'Будь ласка, введіть <bold>новий</bold> пароль';

  @override
  String get inputNewPwdRepeat => 'Повторно введіть <bold>новий</bold> пароль';

  @override
  String get pwdChangeSuccess => 'Пароль змінено';

  @override
  String get delete => 'Видалити';

  @override
  String get urlError_1 => 'Недійсна URL-адреса вузла';

  @override
  String get urlError_2 => 'Адреса вже існує';

  @override
  String get urlError_3 => 'Адреса вузла вже існує';

  @override
  String get prompt => 'Нагадування';

  @override
  String get deleteAccountTip =>
      'Видалений обліковий запис можна відновити лише за допомогою мнемонічної фрази або закритого ключа. Переконайтеся, що ви створили резервну копію мнемонічної фрази та закритого ключа.';

  @override
  String get isee => 'Гаразд';

  @override
  String get walletHomeTip =>
      'Мережа Mina стягує одноразову плату за створення облікового запису в розмірі 1 MINA для захисту від спаму. Його буде автоматично вираховано з першої отриманої транзакції.';

  @override
  String get startHome => 'Старт';

  @override
  String get walletName => 'Гаманець Auro';

  @override
  String get privateError => 'Приватний ключ неправильний';

  @override
  String get improtRepeat => 'Не імпортуйте повторно';

  @override
  String get confirmDeleteNode => 'Ви впевнені, що хочете його видалити?';

  @override
  String get backupSuccess => 'Успіх';

  @override
  String get walletAbout =>
      'Гаманець Auro Wallet — це гаманець, розроблений спільнотою. Він простий, зручний і повністю відкритий. Наразі він підтримує всі функції протоколу Mina.';

  @override
  String get copyTipContent =>
      'Копіювання закритого ключа є ризикованим, а буфер обміну легко відслідковується та викрадається програмами сторонніх розробників.';

  @override
  String get copyTipContent2 =>
      'Перш ніж виконувати цю операцію, переконайтеся, що система та мережеве середовище, які ви використовуєте, є абсолютно безпечними.';

  @override
  String get copyConfirm => 'Все одно копіювати';

  @override
  String get copyCancel => 'Зупинити копіювання';

  @override
  String get scantopay => 'Скануйте, щоб заплатити мені';

  @override
  String addressQrTip(String symbol) {
    return 'Відскануйте QR-код і перенесіть на нього <strongBlack>$symbol</strongBlack>';
  }

  @override
  String get goToExplorer => 'Перевірте більше історії транзакцій';

  @override
  String get homeNoTx => 'Невідомий вузол, неможливо надати історію.';

  @override
  String get followUs => 'Слідуй за нами';

  @override
  String get createPassword => 'Створити пароль';

  @override
  String get epochInfo => 'Інформація про епоху';

  @override
  String get delegationInfo => 'Делегування';

  @override
  String get emptyDelegateTitle => 'Ви ще не делегували';

  @override
  String get emptyDelegateDesc1 =>
      'Делегування MINA вузлу Виробника Блоків може допомогти вам отримати винагороду за створення блоків. Виробник Блоків розподілить винагороди відповідно до делегованої вами пропорції, а відсоток винагород залежить від ставки, встановленої виробником блоків.';

  @override
  String get emptyDelegateDesc2 =>
      'Ефективний час делегування та правила розподілу винагород:';

  @override
  String get emptyDelegateDesc3 => 'Керівництво по ставці';

  @override
  String get changeNode => 'Зміна';

  @override
  String get stakingProviderName => 'Виробник Блоків';

  @override
  String get goStake => 'Перейти до ставки';

  @override
  String get epochEndTime => 'Поточна епоха закінчується в';

  @override
  String get searchPlaceholder => 'Назва або адреса виробника блоків';

  @override
  String get inputNodeAddress => 'Введіть адресу постачальника вузла';

  @override
  String get nodeProviders => 'Виробник блоків';

  @override
  String get manualAdd => 'Введіть адресу вузла Виробник блоків';

  @override
  String get providerAddress => 'Адреса BP';

  @override
  String get copyToClipboard => 'Копіювати в буфер обміну';

  @override
  String get loading => 'Завантаження';

  @override
  String get keystoreError => 'Вміст сховища ключів або пароль неправильні';

  @override
  String get pleaseInputKeyPair => 'Будь ласка, введіть вміст файлу Keystore.';

  @override
  String get pleaseInputKeyPairPwd => 'Пароль сховища ключів';

  @override
  String get pleaseInputPriKey => 'Введіть закритий ключ.';

  @override
  String get privateKey => 'Приватний ключ';

  @override
  String get applied => 'ПРИКЛАДНА';

  @override
  String get failed => 'ПОМИЛКА';

  @override
  String get pending => 'В ОЧІКУВАННІ';

  @override
  String get blockProducerName => 'Назва виробника блоку';

  @override
  String get producerName => 'Назва Виробник блоків';

  @override
  String get blockProducerAddress => 'Адреса виробника блоків';

  @override
  String get notValidAddress => 'Недійсна адреса MINA';

  @override
  String get agree => 'Погодьтеся';

  @override
  String get userAgree => 'Правила та умови';

  @override
  String get imported => 'Імпортовано';

  @override
  String get watchAccount => 'Спостерігати за рахунком';

  @override
  String get watchMode => 'Режим перегляду';

  @override
  String get textWatchModeAddress => 'Введіть або вставте адресу гаманця';

  @override
  String get watchLabel => 'Дивитися';

  @override
  String get timeout => 'Час очікування запиту минув';

  @override
  String get rootTip =>
      'Виявлено, що система була рутована або використовувала симулятор. Подальше використання, це буде ризик!';

  @override
  String get exitConfirm => 'Ви хочете вийти з програми?';

  @override
  String get unlockBioEnable => 'Біометрична автентифікація';

  @override
  String get unlockBio => 'Щоб розблокувати, пройдіть автентифікацію';

  @override
  String get feeTooLarge => 'Комісії значно вищі за середні';

  @override
  String get add => 'Додати';

  @override
  String get addressbook => 'Адресна книга';

  @override
  String get name => 'Ім\'я';

  @override
  String get address => 'Адреса';

  @override
  String get repeatContact => 'Адреса існує';

  @override
  String get backupInOrder =>
      'Щоб переконатися, що ви зробили резервну копію мнемонічної фрази, торкніться 12 слів по порядку.';

  @override
  String get refuse => 'Відмовитися';

  @override
  String get termsDialogTitle => 'Умови та політика конфіденційності';

  @override
  String get privacy => 'Політика конфіденційності';

  @override
  String get scan => 'Сканувати';

  @override
  String get restoreTip =>
      'Якщо ви хочете імпортувати приватний ключ/сховище ключів або підключити Ledger, спочатку потрібно [Створити гаманець] або [Відновити гаманець].';

  @override
  String get reset => 'Скинути';

  @override
  String get resetWarnContentTitle =>
      'Ви впевнені, що бажаєте скинути налаштування гаманця?';

  @override
  String get resetWarnContent =>
      'Після скидання наявного гаманця всі дані буде втрачено. Для відновлення можна використовувати лише мнемографічну фразу. Будь ласка, переконайтеся, що ви створили резервну копію мнемонічної фрази перед скиданням гаманця.';

  @override
  String get confirmReset => 'Скинути';

  @override
  String get cancelReset => 'Скасувати';

  @override
  String deleteConfirm(String tag) {
    return 'Введіть «$tag», щоб назавжди стерти поточний гаманець';
  }

  @override
  String get edit => 'Редагувати';

  @override
  String get save => 'Зберегти';

  @override
  String get watchModeWarn2 =>
      'Auro Wallet більше не підтримує [Обліковий запис годинника], вам потрібно <red>видалити всі облікові записи годинника</red>, перш ніж ви зможете продовжити використання.';

  @override
  String get deleteWatch => 'Видалити обліковий запис годинника';

  @override
  String get allTransfer => 'Макс';

  @override
  String get noMoreSupported => 'Обліковий запис більше не підтримується';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPasswordShort => 'Підтвердьте пароль';

  @override
  String get share => 'Поділіться';

  @override
  String get copy => 'Копія';

  @override
  String get mnemonicLost =>
      'Якщо мнемонічна фраза втрачена, мої кошти будуть втрачені назавжди.';

  @override
  String get protectMnemonic =>
      'Я беру на себе повну відповідальність за захист мнемонічної фрази.';

  @override
  String get scam => 'афера';

  @override
  String get hdDerivedPath => 'Шлях HD';

  @override
  String get emptyAddress => 'Немає збережених адрес';

  @override
  String get speedUp => 'Прискоритись';

  @override
  String get speedUpTitle => 'Прискорити транзакцію';

  @override
  String get cancelTransaction => 'Скасувати транзакцію';

  @override
  String get speedUpTip =>
      'Зазвичай для підтвердження транзакції потрібно <light>3 хвилини</light>. Однак, якщо мережа перевантажена і ваша транзакція може тривати довше, ніж 3 хвилини або більше, ви можете пришвидшити процес транзакції, збільшивши комісію за транзакцію.';

  @override
  String get transactionCancelTip =>
      'Скасуйте транзакцію, надіславши транзакцію з тим самим Nonce на свою адресу. Комісія буде більшою, ніж поточна комісія за транзакцію (0,0001 MINA).';

  @override
  String get currentFee => 'Поточна комісія';

  @override
  String get stakedBalance => 'Ставили';

  @override
  String get testnet => 'Тест';

  @override
  String get myWallet => 'Мій гаманець';

  @override
  String get renameAccountName => 'Змінити назву облікового запису';

  @override
  String get accountNameLimit => 'Не більше 16 символів';

  @override
  String get github => 'Подивіться на Github';

  @override
  String get noAddress => 'Немає адреси';

  @override
  String get addaddress => 'Додати адресу';

  @override
  String get editaddress => 'Редагувати адресу';

  @override
  String get deleteaddress => 'Видалити адресу?';

  @override
  String get addNetWork => 'Додати мережу';

  @override
  String get editNetWork => 'Редагувати мережу';

  @override
  String get nodeAddress => 'URL вузла';

  @override
  String get nodeAlert =>
      'Додавайте лише спеціальні вузли, яким довіряєте. Використання невідомих вузлів може бути ризикованим.';

  @override
  String get invalidContact => 'Недійсна адреса';

  @override
  String get submitNode => 'Надішліть/оновіть свій вузол до цього списку';

  @override
  String get ledgerTip1 => 'Підключіть Ledger до телефону.';

  @override
  String get ledgerTip2 =>
      'Відкрийте програму Mina на своєму пристрої Ledger, доки не побачите <bold>Mina готова</bold>.';

  @override
  String get ledgerTip3 =>
      'Виберіть апаратний гаманець, який ви хочете використовувати з Auro Wallet.';

  @override
  String get connectHardwareWallet => 'Підключіть апаратний гаманець';

  @override
  String get selectHdPath => 'Виберіть HD шлях';

  @override
  String get ledgerStatus => 'Статус Ledger';

  @override
  String get ledgerAddressTip1 =>
      'Продовжуйте подальшу операцію згідно з підказкою апаратного гаманця Ledger.';

  @override
  String get ledgerAddressTip3 =>
      '<lightred>Не закривайте це вікно.</lightred> Щойно Ledger буде завершено, сторінка буде автоматично переспрямована.';

  @override
  String get waitingLedger => 'Очікування підтвердження…';

  @override
  String get waitingLedgerSign =>
      'Підтвердьте в апаратному гаманці Ledger, підпис може зайняти 1-3 хвилини.';

  @override
  String get openMinaApp =>
      'Пристрій Ledger підключено, але додаток Mina не відкрито. Відкрийте додаток Mina в Ledger.';

  @override
  String get unlockLedger =>
      'Не вдалося підключитися. Переконайтеся, що ваш пристрій Ledger розблоковано.';

  @override
  String get ledgerReject => 'Відхилено Ledger';

  @override
  String get ledgerSearching => 'Пошук…';

  @override
  String get ledgerSupport =>
      '(<lightred>підтримує лише Ledger Nano X</lightred>)';

  @override
  String get termsAndPrivacy_line1 =>
      'Цю послугу надає Auro Wallet. Будь ласка, знайдіть час, щоб уважно прочитати та зрозуміти Умови та Політику конфіденційності.';

  @override
  String get termsAndPrivacy_line2 =>
      'Уважно прочитайте <conditions>Загальні положення та умови</conditions> та <policy>Політику конфіденційності</policy>. Якщо ви повністю розумієте та погоджуєтеся, натисніть [Agree], щоб почати користуватися цією послугою гаманця.';

  @override
  String get contributeLanguage => 'Додайте мову';

  @override
  String get available => 'В наявності';

  @override
  String importSameAccount_1(String address) {
    return 'Адреса облікового запису, який буде створено: <theme>$address</theme>';
  }

  @override
  String importSameAccount_2(String accountName) {
    return 'Існуючий імпортований обліковий запис [$accountName] є дублікатом цієї адреси. Auro Wallet не підтримує створення дублікатів адрес облікових записів. Перейдіть до <acmanage>Керування обліковим записом</acmanage>, щоб видалити імпортований обліковий запис.';
  }

  @override
  String get browser => 'Браузер';

  @override
  String get searchOrInputUrl => 'Пошук або введення URL адреси';

  @override
  String get allowSiteAddNode => 'Дозволити цьому сайту додати мережу';

  @override
  String get removeFavorites => 'Видалити із обраного';

  @override
  String get addFavorites => 'Додати в обране';

  @override
  String get copyLink => 'Копіювати посилання';

  @override
  String get openInBrowser => 'Відкрити в браузері';

  @override
  String get connectionRequest => 'Запит на підключення';

  @override
  String get connectTip => 'Цей сайт хоче переглядати ваш рахунок';

  @override
  String get trustedSitesTip =>
      'Переконайтеся, що ви підключаєтеся лише до надійних сайтів';

  @override
  String get signatureRequest => 'Запит на підпис';

  @override
  String get content => 'Зміст';

  @override
  String get transactionFee => 'Комісія за транзакцію';

  @override
  String get siteSuggested => 'Запропонований сайт';

  @override
  String get rawData => 'Необроблені дані';

  @override
  String get showData => 'Показати дані';

  @override
  String get warning => 'УВАГА';

  @override
  String get warningTip =>
      'Ви маєте справу з адресою або контрактом, яка(який) помічено як scam. Якщо ви підпишите, ви можете втратити доступ до всіх ваших NFTs та інших коштів у вашому гаманці.';

  @override
  String get switchNetwork => 'Перемкнути мережу';

  @override
  String get allowSwitch => 'Дозволити цьому сайту змінювати мережу?';

  @override
  String get current => 'Поточний';

  @override
  String get target => 'Мета';

  @override
  String get recently => 'Нещодавно';

  @override
  String get favorites => 'Обране';

  @override
  String get browserEmptyTip => 'Тут відображатимуться ваше обране та історія';

  @override
  String get websiteNotFound => 'Сайт не знайдено';

  @override
  String get ledgerNotSupportSign =>
      'Ledger не підтримує підписані повідомлення';

  @override
  String get notSupportNow => 'Поки що не підтримується';

  @override
  String get newFee => 'Нова комісія';

  @override
  String get addAccount => 'Додати акаунт';

  @override
  String get createAccount => 'Створити акаунт';

  @override
  String get hardwareWallet => 'Апаратний гаманець';

  @override
  String get showTestnet => 'Показати тестову мережу';

  @override
  String get ledgerConnected => 'Пристрій Ledger підключено';

  @override
  String get ledgerNotConnected => 'Пристрій Ledger не підключено';

  @override
  String get txType => 'Тип транзакції';

  @override
  String get appConnection => 'Підключення програми';

  @override
  String get noConnectedApps => 'Немає підключених програм';

  @override
  String get txHistoryTip => 'Не вдалося надати історію транзакцій';

  @override
  String get tokens => 'TOKENS';

  @override
  String get assetManagement => 'Управління активами';

  @override
  String newTokenFound(String count) {
    return 'Знайдено $count нових токенів';
  }

  @override
  String get ignore => 'Ігнорувати';

  @override
  String get balance => 'Баланс';

  @override
  String get updateTokenInfo => 'Оновити інформацію про токен?';

  @override
  String get noTxHistory => 'Історія транзакцій відсутня';

  @override
  String get buildFailed => 'Пакування не вдалося';

  @override
  String get appAccess => 'App доступ';

  @override
  String get transactions => 'Транзакції';

  @override
  String get unlock => 'Розблокувати';

  @override
  String get useBiometricAuthentication =>
      'Використовувати біометричну автентифікацію';

  @override
  String get loginWithPassword => 'Увійти за допомогою пароля';

  @override
  String get clickToVerification => 'Натисніть, щоб розпочати перевірку';

  @override
  String get resetWallet => 'Скинути гаманець';

  @override
  String get biometricAuth => 'Біометрична автентифікація';

  @override
  String get tapToVerify => 'Натисніть, щоб підтвердити';

  @override
  String get zkAppTipTitle => 'Ви відвідуєте сторонній zkApp';

  @override
  String get zkAppTipContent =>
      'Входячи до цього zkApp, ви підпорядковуєтесь Угоді користувача стороннього zkApp.';

  @override
  String get passwordVerification => 'Перевірка пароля';

  @override
  String get pwdVerificationTip => 'Необхідно вибрати щонайменше одну опцію.';

  @override
  String get selectAsset => 'Вибрати актив';

  @override
  String tokenPendingTip(int count) {
    return 'Зараз є <light>$count</light> транзакцій, що виконуються, скасувати чи продовжити поточну операцію.';
  }

  @override
  String get pendingTx => 'Очікувана транзакція';

  @override
  String get signed => 'ПІДПИСАНО';

  @override
  String get backToAppTitle => 'Повернутися до програми';

  @override
  String get backToAppDesc =>
      'Будь ласка, поверніться до програми, щоб продовжити користуватися її послугами.';

  @override
  String get walletConnectTitle => 'WalletConnect';

  @override
  String get noWalletConnectSession => 'Немає сесій';

  @override
  String get preferences => 'Налаштування';

  @override
  String get response => 'Відповідь';

  @override
  String get retry => 'Повторити';

  @override
  String get scanTip => 'Підтримка QR-коду адреси та WalletConnect';

  @override
  String get notificationTxSuccess => 'Транзакція успішна';

  @override
  String get notificationTxFailed => 'Транзакція не вдалася';

  @override
  String get notificationTxSuccessBody => 'Вашу транзакцію підтверджено.';

  @override
  String notificationTxSuccessBodyWithAmount(String amount, String symbol) {
    return 'Вашу транзакцію на $amount $symbol підтверджено.';
  }

  @override
  String get notificationTxFailedBody =>
      'Ваша транзакція не вдалася. Будь ласка, спробуйте ще раз.';

  @override
  String get renameWallet => 'Перейменувати гаманець';

  @override
  String get deleteWallet => 'Видалити гаманець';

  @override
  String get deleteWalletWarning =>
      'Цю дію неможливо скасувати. Переконайтеся, що ви зберегли мнемонічну фразу перед видаленням.';

  @override
  String get hdWallet => 'HD Гаманець';

  @override
  String get walletNamePlaceholder => 'Введіть назву гаманця';

  @override
  String get accounts => 'акаунтів';

  @override
  String get selectWallet => 'Вибрати гаманець';

  @override
  String get noMnemonicWallet =>
      'Немає доступного HD гаманця. Спочатку створіть або імпортуйте гаманець.';

  @override
  String get walletDetails => 'Деталі гаманця';

  @override
  String get walletNameLabel => 'Назва гаманця';

  @override
  String get changeWalletName => 'Змінити назву гаманця';

  @override
  String get seedPhrase => 'Мнемонічна фраза';

  @override
  String get deleteWalletConfirm =>
      'Ви впевнені, що хочете видалити цей гаманець?';

  @override
  String get walletDeleted => 'Гаманець успішно видалено';

  @override
  String get walletRenamed => 'Гаманець успішно перейменовано';

  @override
  String get privateKeyWallet => 'Приватний ключ';

  @override
  String get keystoreWallet => 'Keystore';

  @override
  String get ledgerWallet => 'Ledger';

  @override
  String get watchWallet => 'Тільки перегляд';

  @override
  String get rename => 'Перейменувати';

  @override
  String get backupMnemonic => 'Резервна копія мнемоніки';

  @override
  String get addWallet => 'Додати гаманець';

  @override
  String get importWallet => 'Імпортувати гаманець';

  @override
  String get walletManagement => 'Керування гаманцями';

  @override
  String get mnemonicPhrase => 'Мнемонічна фраза';

  @override
  String get mnemonicImportDesc =>
      'Імпорт за допомогою мнемонічної фрази з 12 або 24 слів';

  @override
  String get privateKeyImportDesc => 'Імпорт за допомогою приватного ключа';

  @override
  String get keystoreImportDesc => 'Імпорт за допомогою файлу Keystore';

  @override
  String get ledgerImportDesc => 'Підключення через Bluetooth або USB';

  @override
  String get getStarted => 'Початок роботи';

  @override
  String get ledgerIntroDesc =>
      'Перед початком переконайтеся, що на вашому Ledger встановлено останню прошивку, пристрій налаштовано та додаток Mina встановлено.';

  @override
  String get ledgerIntroStep1 => 'Підключіть Ledger до телефону.';

  @override
  String get ledgerIntroStep2 =>
      'Відкрийте додаток Mina на Ledger, поки не побачите <bold>Mina is ready</bold>.';

  @override
  String get hdPathDesc =>
      'Якщо ви не знаєте, що означає цей параметр, змінювати його не потрібно. Детальні <link>інструкції</link>.';

  @override
  String get currentEpoch => 'Поточна епоха';

  @override
  String get earnOnMina => 'Заробіток на MINA';

  @override
  String get apr => 'Річна дохідність';

  @override
  String get lockTime => 'Час блокування';

  @override
  String get notLocked => 'Не заблоковано';

  @override
  String get active => 'Активно';

  @override
  String get inactive => 'Неактивно';

  @override
  String get unknownNetworkStaking =>
      'Невідома мережа, неможливо надати інформацію.';

  @override
  String get redelegate => 'Переделегувати';

  @override
  String get stake => 'Стейкінг';

  @override
  String get stakeInfoBanner =>
      'У протоколі Mina стейкінг — це операція делегування. Ваші активи не будуть заблоковані, і ви можете переказати їх у будь-який час.';

  @override
  String get validator => 'Валідатор';

  @override
  String get fromValidator => 'Від валідатора';

  @override
  String get toValidator => 'До валідатора';

  @override
  String get currentValidator => 'Поточний валідатор';

  @override
  String get selectValidator => 'Вибрати';

  @override
  String get epochEstimate => '15 днів (1 епоха) прогноз';

  @override
  String get threeMonthsEstimate => '3 місяці прогноз';

  @override
  String get sixMonthsEstimate => '6 місяців прогноз';

  @override
  String get staked => 'Застейкано';
}
