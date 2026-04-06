// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get passwordError => '密码错误';

  @override
  String get createWallet => '创建钱包';

  @override
  String get restoreWallet => '恢复钱包';

  @override
  String get inputPassword => '输入密码';

  @override
  String get createPasswordTip =>
      '密码将用于在 Auro 钱包中发送交易和身份验证。Auro 钱包不保存密码，也无法帮您找回。请妥善保管。';

  @override
  String get next => '下一步';

  @override
  String get atLeastOneLowercaseLetter => '小写字母';

  @override
  String get atLeastOneUppercaseLetter => '大写字母';

  @override
  String get atLeastOneNumber => '数字';

  @override
  String get passwordRequires => '8个字符';

  @override
  String get passwordDifferent => '密码不匹配';

  @override
  String get backTips_1 => '现在开始备份助记词！';

  @override
  String get backTips_2 => '助记词由12个英文单词组成，丢失无法找回。请确认保存好助记词，并将其放在安全的地方。';

  @override
  String get backTips_3 => '当发生设备丢失或者其它原因无法访问钱包时，使用助记词是找回资产的唯一方法。';

  @override
  String get show_seed_content => '请抄写以下助记词并将其保存在安全的地方。';

  @override
  String get show_seed_button => '我已保存';

  @override
  String get seed_error => '助记词输入错误';

  @override
  String get backup_success => '恭喜您，已经成功创建钱包！';

  @override
  String get backup_success_restore => '恭喜您，已经成功导入钱包！';

  @override
  String get inputSeed => '请按顺序输入12或24位助记词，没有大写和标点符号。';

  @override
  String get confirm => '确定';

  @override
  String get wallet => '钱包';

  @override
  String get staking => '委托';

  @override
  String get setting => '设置';

  @override
  String get stakingStatus_1 => '已委托';

  @override
  String get stakingStatus_2 => '未委托';

  @override
  String get send => '发送';

  @override
  String get receive => '接收';

  @override
  String get history => '交易记录';

  @override
  String get toAddress => '接收';

  @override
  String get fromAddress => '发送';

  @override
  String get amount => '金额';

  @override
  String get memo => '备注(选填)';

  @override
  String get memo2 => '备注';

  @override
  String get fee => '交易费';

  @override
  String get fee_slow => '慢';

  @override
  String get fee_default => '默认';

  @override
  String get fee_fast => '快';

  @override
  String get advanceMode => '高级';

  @override
  String get sendDetail => '交易详情';

  @override
  String get sendAddressError => '请输入有效地址';

  @override
  String get amountError => '输入的金额格式有误';

  @override
  String get balanceNotEnough => '账户余额不足';

  @override
  String get txHash => '交易哈希';

  @override
  String get time => '时间';

  @override
  String get goToExplrer => '查看详情';

  @override
  String get details => '详情';

  @override
  String get walletAddress => '钱包地址';

  @override
  String get copySuccess => '已复制';

  @override
  String get accountManage => '账户管理';

  @override
  String get create => '创建';

  @override
  String get import => '导入';

  @override
  String get importLedger => 'Ledger';

  @override
  String get accountName => '账户名称';

  @override
  String get inputAccountName => '请输入您的账户名称';

  @override
  String get importAccount_2 => '导入的账号不会与最初创建的 Auro Wallet进行关联。';

  @override
  String get importAccount_3 => '导入的账户在账户列表页有【导入】标识。';

  @override
  String get accountInfo => '账户信息';

  @override
  String get accountAddress => '账户地址';

  @override
  String get exportPrivateKey => '导出私钥';

  @override
  String get accountDelete => '删除账户';

  @override
  String get cancel => '取消';

  @override
  String get privateKeyTip_1 => '私钥由一串字符组成，拥有私钥等于拥有账户资产所有权。';

  @override
  String get privateKeyTip_2 => '私钥丢失，无法找回，请务必备份好私钥，并将其保管至安全的地方。';

  @override
  String get security => '安全';

  @override
  String get network => '网络';

  @override
  String get language => '语言';

  @override
  String get currency => '法币类型';

  @override
  String get about => '关于我们';

  @override
  String get restoreSeed => '备份助记词';

  @override
  String get changePassword => '更改密码';

  @override
  String get inputOldPwd => '请输入<bold>旧</bold>密码';

  @override
  String get inputNewPwd => '请输入<bold>新</bold>密码';

  @override
  String get inputNewPwdRepeat => '请重复输入<bold>新</bold>密码';

  @override
  String get pwdChangeSuccess => '密码修改成功';

  @override
  String get delete => '删除';

  @override
  String get urlError_1 => '无效的节点地址';

  @override
  String get urlError_2 => '地址已存在';

  @override
  String get urlError_3 => '节点地址已存在';

  @override
  String get prompt => '提示';

  @override
  String get deleteAccountTip => '删除的账户只能通过助记词或者私钥恢复，请确认您已经备份好助记词或者私钥。';

  @override
  String get isee => '我知道了';

  @override
  String get walletHomeTip =>
      '为了防止垃圾信息， Mina 网络一次性收取 1 MINA 的帐户创建费，它将自动从收到的第一个交易中扣除。';

  @override
  String get startHome => '开始';

  @override
  String get walletName => 'Auro Wallet';

  @override
  String get privateError => '私钥错误';

  @override
  String get improtRepeat => '请勿重复导入';

  @override
  String get confirmDeleteNode => '确认删除？';

  @override
  String get backupSuccess => '成功';

  @override
  String get walletAbout =>
      'Auro 钱包是一款由社区开发的非托管钱包。它简单，易用，并且完全开源。支持 Mina 的所有功能。';

  @override
  String get copyTipContent => '复制私钥存在风险，剪切板容易被第三方应用监听并盗取。';

  @override
  String get copyTipContent2 => '请确保您所使用的系统及网络环境绝对安全再执行些操作。';

  @override
  String get copyConfirm => '仍要复制';

  @override
  String get copyCancel => '不再复制';

  @override
  String get scantopay => '扫码支付';

  @override
  String addressQrTip(String symbol) {
    return '扫描二维码，转入 <strongBlack>$symbol</strongBlack>';
  }

  @override
  String get goToExplorer => '去浏览器查看交易记录';

  @override
  String get homeNoTx => '未知类型节点，无法提供相关记录。';

  @override
  String get followUs => '关注我们';

  @override
  String get createPassword => '创建密码';

  @override
  String get epochInfo => 'Epoch 信息';

  @override
  String get delegationInfo => '委托信息';

  @override
  String get emptyDelegateTitle => '您还没有委托';

  @override
  String get emptyDelegateDesc1 =>
      '将 MINA 委托给网络中的出块节点可以帮助您获得出块收益，出块节点将根据您的委托比重进行分配收益，收益百分比取决于出块节点的费率设置。';

  @override
  String get emptyDelegateDesc2 => '委托生效时间和奖励机制请访问:';

  @override
  String get emptyDelegateDesc3 => '委托教程';

  @override
  String get changeNode => '更改';

  @override
  String get stakingProviderName => '出块节点';

  @override
  String get goStake => '前往委托';

  @override
  String get epochEndTime => '当前 Epoch 剩余时间';

  @override
  String get searchPlaceholder => '出块节点名称或地址';

  @override
  String get inputNodeAddress => '请输入委托节点地址';

  @override
  String get nodeProviders => '出块节点';

  @override
  String get manualAdd => '输入出块节点地址';

  @override
  String get providerAddress => '节点地址';

  @override
  String get copyToClipboard => '复制到剪切板';

  @override
  String get loading => '加载中';

  @override
  String get keystoreError => 'Keystore 内容错误或密码不正确';

  @override
  String get pleaseInputKeyPair => '请将 Keystore 文件的内容输入在下方。';

  @override
  String get pleaseInputKeyPairPwd => '输入 Keystore 密码';

  @override
  String get pleaseInputPriKey => '请输入私钥。';

  @override
  String get privateKey => '私钥';

  @override
  String get applied => '完成';

  @override
  String get failed => '失败';

  @override
  String get pending => '等待';

  @override
  String get blockProducerName => '出块节点名称';

  @override
  String get producerName => '出块节点名称';

  @override
  String get blockProducerAddress => '出块节点地址';

  @override
  String get notValidAddress => '无效的 MINA 地址';

  @override
  String get agree => '同意';

  @override
  String get userAgree => '使用条款';

  @override
  String get imported => '导入';

  @override
  String get watchAccount => '观察账户';

  @override
  String get watchMode => '观察模式';

  @override
  String get textWatchModeAddress => '输入或粘贴钱包地址';

  @override
  String get watchLabel => '观察';

  @override
  String get timeout => '请求超时';

  @override
  String get rootTip => '检测到系统已经 Root 或者使用模拟器. 继续使用将存在风险！';

  @override
  String get exitConfirm => '确定要退出 App 吗？';

  @override
  String get unlockBioEnable => '生物识别';

  @override
  String get unlockBio => '验证以解锁';

  @override
  String get feeTooLarge => '交易费用远高于平均值';

  @override
  String get add => '添加';

  @override
  String get addressbook => '地址簿';

  @override
  String get name => '名称';

  @override
  String get address => '地址';

  @override
  String get repeatContact => '地址已存在';

  @override
  String get backupInOrder => '为了确保您已经成功备份助记词，请按顺序选择12个单词。';

  @override
  String get refuse => '拒绝';

  @override
  String get termsDialogTitle => '使用条款及隐私政策';

  @override
  String get privacy => '隐私协议';

  @override
  String get scan => '扫描';

  @override
  String get restoreTip =>
      '提示: 若要导入私钥匙 / Keystore 或连接 Ledger，需先[创建钱包]或者[恢复钱包]。';

  @override
  String get reset => '重置';

  @override
  String get resetWarnContentTitle => '确定要重置钱包吗？';

  @override
  String get resetWarnContent =>
      '重置后，现有钱包的数据将会全部丢失，只能使用助记词恢复。请确保您已经备份好助记词后再重置钱包。';

  @override
  String get confirmReset => '重置';

  @override
  String get cancelReset => '取消';

  @override
  String deleteConfirm(String tag) {
    return '请输入“$tag”确定重置钱包';
  }

  @override
  String get edit => '编辑';

  @override
  String get save => '保存';

  @override
  String get watchModeWarn2 =>
      'Auro Wallet 已经不再支持【观察钱包】功能，您需要<red>删除所有观察钱包</red>之后才可以继续使用。';

  @override
  String get deleteWatch => '删除观察钱包';

  @override
  String get allTransfer => '全部';

  @override
  String get noMoreSupported => '不再支持的账户';

  @override
  String get password => '密码';

  @override
  String get confirmPasswordShort => '确认密码';

  @override
  String get share => '分享';

  @override
  String get copy => '复制';

  @override
  String get mnemonicLost => '如果助记词丢失，我的资产将永久丢失。';

  @override
  String get protectMnemonic => '我对助记词的安全保存负全部责任。';

  @override
  String get scam => '风险';

  @override
  String get hdDerivedPath => 'HD 路径';

  @override
  String get emptyAddress => '没有保存的地址';

  @override
  String get speedUp => '加速';

  @override
  String get speedUpTitle => '加速交易';

  @override
  String get cancelTransaction => '取消交易';

  @override
  String get speedUpTip =>
      '通常情况下，一笔交易需要<light>3分钟</light>才能确认。 但是，当网络拥堵时，您的交易可能需要花费大于3分钟或者更久的时间，您可以通过提高交易费用来加快交易过程。';

  @override
  String get transactionCancelTip =>
      '通过给自己的地址发送一笔相同 Nonce 的交易来取消之前的交易。 该费用将高于当前的交易费用（+0.0001 MINA）。';

  @override
  String get currentFee => '当前交易费';

  @override
  String get stakedBalance => '已委托';

  @override
  String get testnet => '测试网';

  @override
  String get myWallet => '我的钱包';

  @override
  String get renameAccountName => '更改账户名';

  @override
  String get accountNameLimit => '不超过16个字符';

  @override
  String get github => '查看 Github';

  @override
  String get noAddress => '没有地址';

  @override
  String get addaddress => '添加地址';

  @override
  String get editaddress => '编辑地址';

  @override
  String get deleteaddress => '删除地址？';

  @override
  String get addNetWork => '添加网络';

  @override
  String get editNetWork => '编辑节点';

  @override
  String get nodeAddress => '节点地址';

  @override
  String get nodeAlert => '请务必只添加受您信任的节点。使用未知节点会有一定风险。';

  @override
  String get invalidContact => '地址格式错误';

  @override
  String get submitNode => '提交/更新节点到这个列表';

  @override
  String get ledgerTip1 => '将 Ledger 与手机连接。';

  @override
  String get ledgerTip2 =>
      '在 Ledger 中打开 Mina 应用，直到看到 <bold>Mina is ready</bold>。';

  @override
  String get ledgerTip3 => '选择您想要使用的硬件钱包。';

  @override
  String get connectHardwareWallet => '连接硬件钱包';

  @override
  String get selectHdPath => '选择 HD 派生路径';

  @override
  String get ledgerStatus => 'Ledger 状态';

  @override
  String get ledgerAddressTip1 => '请根据 Ledger 硬件钱包中的提示进行以下操作。';

  @override
  String get ledgerAddressTip3 =>
      '<lightred>不要关闭本窗口。</lightred>Ledger 完成后，页面将自动跳转。';

  @override
  String get waitingLedger => '等待确认…';

  @override
  String get waitingLedgerSign => '请在 Ledger 硬件钱包中进行确认，签名可能会需要1-3分钟的时间。';

  @override
  String get openMinaApp => 'Ledger 已连接，但是 Mina 应用没有打开，请在 Ledger 中打开 Mina 应用。';

  @override
  String get unlockLedger => '连接失败，请确保您的 Ledger 设备处于解锁状态。';

  @override
  String get ledgerReject => 'Ledger 已拒绝';

  @override
  String get ledgerSearching => '搜索…';

  @override
  String get ledgerSupport => '(<lightred>仅支持 Ledger Nano X</lightred>)';

  @override
  String get termsAndPrivacy_line1 =>
      '使用 Auro 钱包提供的服务，您需要阅读并充分理解使用条款和隐私政策相关的内容。';

  @override
  String get termsAndPrivacy_line2 =>
      '您可以阅读<conditions>《使用条款》</conditions>和<policy>《隐私政策》</policy>了解详细信息，如果您同意，请点击【同意】开始使用钱包服务。';

  @override
  String get contributeLanguage => '贡献语言';

  @override
  String get available => '可用';

  @override
  String importSameAccount_1(String address) {
    return '即将创建的账户地址为：<theme>$address</theme>';
  }

  @override
  String importSameAccount_2(String accountName) {
    return '已存在导入账户【$accountName】与此地址重复，Auro 钱包不支持账户地址重复创建，请前往<acmanage>账户管理页</acmanage>将已导入的账户删除。';
  }

  @override
  String get browser => '浏览';

  @override
  String get searchOrInputUrl => '搜索或输入网址';

  @override
  String get allowSiteAddNode => '允许此网站添加网络';

  @override
  String get removeFavorites => '从收藏中删除';

  @override
  String get addFavorites => '添加到收藏';

  @override
  String get copyLink => '复制链接';

  @override
  String get openInBrowser => '从浏览器打开';

  @override
  String get connectionRequest => '连接请求';

  @override
  String get connectTip => '这个网站请求查看账户';

  @override
  String get trustedSitesTip => '请确保只与您信任的网站进行连接';

  @override
  String get signatureRequest => '签名请求';

  @override
  String get content => '内容';

  @override
  String get transactionFee => '交易费';

  @override
  String get siteSuggested => '网站建议';

  @override
  String get rawData => '原始数据';

  @override
  String get showData => '展示数据';

  @override
  String get warning => '警告';

  @override
  String get warningTip =>
      '您正在与已被标记为诈骗的地址进行交互。 如果您签名，您可能无法访问您的所有 NFT 以及钱包中的任何资金或其他资产。';

  @override
  String get switchNetwork => '切换网络';

  @override
  String get allowSwitch => '允许此网站切换网络？';

  @override
  String get current => '当前网络';

  @override
  String get target => '目标网络';

  @override
  String get recently => '最近访问';

  @override
  String get favorites => '收藏';

  @override
  String get browserEmptyTip => '您的收藏和历史纪录会显示在这里';

  @override
  String get websiteNotFound => '未找到网址';

  @override
  String get ledgerNotSupportSign => 'Ledger 不支持签名消息';

  @override
  String get notSupportNow => '暂不支持';

  @override
  String get newFee => '新交易费';

  @override
  String get addAccount => '添加账户';

  @override
  String get createAccount => '创建账户';

  @override
  String get hardwareWallet => '硬件钱包';

  @override
  String get showTestnet => '显示测试网';

  @override
  String get ledgerConnected => 'Ledger 已连接';

  @override
  String get ledgerNotConnected => 'Ledger 未连接';

  @override
  String get txType => '交易类型';

  @override
  String get appConnection => '已连接应用';

  @override
  String get noConnectedApps => '没有已连接的应用';

  @override
  String get txHistoryTip => '无法提供交易记录';

  @override
  String get tokens => 'TOKENS';

  @override
  String get assetManagement => '资产管理';

  @override
  String newTokenFound(String count) {
    return '发现了$count个新代币';
  }

  @override
  String get ignore => '忽略';

  @override
  String get balance => '余额';

  @override
  String get updateTokenInfo => '更新您的代币信息？';

  @override
  String get noTxHistory => '没有交易历史';

  @override
  String get buildFailed => '打包失败';

  @override
  String get appAccess => 'App 访问';

  @override
  String get transactions => '交易';

  @override
  String get unlock => '解锁';

  @override
  String get useBiometricAuthentication => '使用生物识别';

  @override
  String get loginWithPassword => '使用密码登录';

  @override
  String get clickToVerification => '点击开始验证';

  @override
  String get resetWallet => '重置钱包';

  @override
  String get biometricAuth => '生物识别认证';

  @override
  String get tapToVerify => '点击验证';

  @override
  String get zkAppTipTitle => '您正在访问第三方zkApp';

  @override
  String get zkAppTipContent => '进入此zkApp时，您需遵守第三方zkApp的用户协议。';

  @override
  String get passwordVerification => '密码验证';

  @override
  String get pwdVerificationTip => '至少选择一个选项。';

  @override
  String get selectAsset => '选择资产';

  @override
  String tokenPendingTip(int count) {
    return '当前有<light>$count</light>笔正在进行的交易，取消或继续当前操作';
  }

  @override
  String get pendingTx => '待处理的交易';

  @override
  String get signed => '已签名';

  @override
  String get backToAppTitle => '返回应用程序';

  @override
  String get backToAppDesc => '请返回应用程序继续使用服务。';

  @override
  String get walletConnectTitle => 'WalletConnect';

  @override
  String get noWalletConnectSession => '无会话';

  @override
  String get preferences => '偏好';

  @override
  String get response => '响应';

  @override
  String get retry => '重试';

  @override
  String get scanTip => '支持地址二维码和 WalletConnect';

  @override
  String get notificationTxSuccess => '交易已确认';

  @override
  String get notificationTxFailed => '交易失败';

  @override
  String get notificationTxSuccessBody => '您的交易已确认。';

  @override
  String notificationTxSuccessBodyWithAmount(String amount, String symbol) {
    return '您的 $amount $symbol 交易已确认。';
  }

  @override
  String get notificationTxFailedBody => '您的交易失败，请重试。';

  @override
  String notificationSentTitle(String amount, String symbol) {
    return '已发送 $amount $symbol';
  }

  @override
  String notificationSentBody(String address) {
    return '至 $address';
  }

  @override
  String get notificationSendFailedTitle => '发送失败';

  @override
  String notificationSendFailedBody(String amount, String symbol) {
    return '$amount $symbol 发送失败，请重试。';
  }

  @override
  String get notificationDelegationSuccessTitle => '质押已确认';

  @override
  String notificationDelegationSuccessBody(String address) {
    return '已质押至 $address';
  }

  @override
  String get notificationDelegationFailedTitle => '质押失败';

  @override
  String get notificationDelegationFailedBody => '您的质押交易失败，请重试。';

  @override
  String get notificationZkAppSuccessTitle => 'zkApp 交易已确认';

  @override
  String get notificationZkAppSuccessBody => '您的 zkApp 交易已确认。';

  @override
  String get notificationZkAppFailedTitle => 'zkApp 交易失败';

  @override
  String get notificationZkAppFailedBody => '您的 zkApp 交易失败，请重试。';

  @override
  String get renameWallet => '重命名钱包';

  @override
  String get deleteWallet => '删除钱包';

  @override
  String get deleteWalletWarning => '此操作无法撤销。请确保在删除前已备份助记词。';

  @override
  String get hdWallet => 'HD 钱包';

  @override
  String get walletNamePlaceholder => '输入钱包名称';

  @override
  String get accounts => '个账户';

  @override
  String get selectWallet => '选择钱包';

  @override
  String get noMnemonicWallet => '没有可用的 HD 钱包。请先创建或导入钱包。';

  @override
  String get walletDetails => '钱包详情';

  @override
  String get walletNameLabel => '钱包名称';

  @override
  String get changeWalletName => '修改钱包名称';

  @override
  String get seedPhrase => '助记词';

  @override
  String get deleteWalletConfirm => '确定要删除此钱包吗？';

  @override
  String get walletDeleted => '钱包删除成功';

  @override
  String get walletRenamed => '钱包重命名成功';

  @override
  String get privateKeyWallet => '私钥';

  @override
  String get keystoreWallet => 'Keystore';

  @override
  String get ledgerWallet => 'Ledger';

  @override
  String get watchWallet => '观察钱包';

  @override
  String get rename => '重命名';

  @override
  String get backupMnemonic => '备份助记词';

  @override
  String get addWallet => '添加钱包';

  @override
  String get importWallet => '导入钱包';

  @override
  String get walletManagement => '钱包管理';

  @override
  String get mnemonicPhrase => '助记词';

  @override
  String get mnemonicImportDesc => '使用12或24位助记词导入';

  @override
  String get privateKeyImportDesc => '使用私钥导入';

  @override
  String get keystoreImportDesc => '使用 Keystore 文件导入';

  @override
  String get ledgerImportDesc => '通过蓝牙或USB连接';

  @override
  String get getStarted => '开始使用';

  @override
  String get ledgerIntroDesc =>
      '开始之前，请确保您的 Ledger 设备已更新到最新固件且已完成设置，并且已在 Ledger 设备中安装了 Mina 应用。';

  @override
  String get ledgerIntroStep1 => '将 Ledger 与手机连接。';

  @override
  String get ledgerIntroStep2 =>
      '在 Ledger 中打开 Mina 应用，直到看到 <bold>Mina is ready</bold>。';

  @override
  String get hdPathDesc => '如果您不了解以下设置，无需修改。查看详细<link>说明</link>。';

  @override
  String get currentEpoch => '当前 Epoch';

  @override
  String get earnOnMina => '赚取 MINA';

  @override
  String get apr => '年化收益率';

  @override
  String get lockTime => '锁定时间';

  @override
  String get notLocked => '未锁定';

  @override
  String get active => '已委托';

  @override
  String get inactive => '未委托';

  @override
  String get unknownNetworkStaking => '未知网络，无法提供信息。';

  @override
  String get redelegate => '更换验证人';

  @override
  String get stake => '质押';

  @override
  String get stakeInfoBanner => '在 Mina 协议中，质押是一种委托操作，您的资产不会被锁定，您可以随时转移它们。';

  @override
  String get validator => '验证人';

  @override
  String get fromValidator => '当前验证人';

  @override
  String get toValidator => '新验证人';

  @override
  String get currentValidator => '当前验证人';

  @override
  String get selectValidator => '选择';

  @override
  String get epochEstimate => '15天 (1 epoch) 预估';

  @override
  String get threeMonthsEstimate => '3个月预估';

  @override
  String get sixMonthsEstimate => '6个月预估';

  @override
  String get staked => '已质押';

  @override
  String get networkFee => '网络费用';

  @override
  String get inputFeeError => '请输入有效的网络费用';

  @override
  String get inputNonceError => '请输入有效的nonce';

  @override
  String get biometricUpdateFailed => '生物识别数据更新失败，请重试。';

  @override
  String get notificationEnable => '交易通知';
}
