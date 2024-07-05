import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/contactData.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/settings/types/followUsData.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:mobx/mobx.dart';

part 'aboutUsData.g.dart';


@JsonSerializable(explicitToJson: true)
class AboutUsData {
  AboutUsData(
      {required this.changelog,
      required this.gitReponame,
      required this.followus});

  factory AboutUsData.fromJson(Map<String, dynamic> json) =>
      _$AboutUsDataFromJson(json);

  Map<String, dynamic> toJson() => _$AboutUsDataToJson(this);
  @JsonKey(name: 'changelog_app')
  String changelog = '';

  @JsonKey(name: 'gitReponame_app')
  String gitReponame = '';

  @JsonKey(name: 'staking_guide_cn')
  String stakingGuideCN = '';

  @JsonKey(name: 'terms_and_contions')
  String termsAndContionsEN = '';

  @JsonKey(name: 'privacy_policy')
  String privacyPolicyEN = '';

  @JsonKey(name: 'terms_and_contions_cn')
  String termsAndContionsZH = '';

  @JsonKey(name: 'privacy_policy_cn')
  String privacyPolicyZH = '';

  @JsonKey(name: 'staking_guide')
  String stakingGuide = '';

  @JsonKey(name: 'graphql_api')
  String? graphqlApi = '';

  List<FollowUsData?> followus = [];

  FollowUsData? get wechat {
    return followus.firstWhere((element) => element!.name == 'wechat',
        orElse: () => null);
  }

  FollowUsData? get telegram {
    return followus.firstWhere((element) => element!.name == 'telegram',
        orElse: () => null);
  }

  FollowUsData? get twitter {
    return followus.firstWhere((element) => element!.name == 'twitter',
        orElse: () => null);
  }

  FollowUsData? get website {
    return followus.firstWhere((element) => element!.name == 'website',
        orElse: () => null);
  }
}