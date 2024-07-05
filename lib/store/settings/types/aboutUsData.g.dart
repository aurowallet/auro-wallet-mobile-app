// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aboutUsData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AboutUsData _$AboutUsDataFromJson(Map<String, dynamic> json) => AboutUsData(
      changelog: json['changelog_app'] as String,
      gitReponame: json['gitReponame_app'] as String,
      followus: (json['followus'] as List<dynamic>)
          .map((e) => e == null
              ? null
              : FollowUsData.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..stakingGuideCN = json['staking_guide_cn'] as String
      ..termsAndContionsEN = json['terms_and_contions'] as String
      ..privacyPolicyEN = json['privacy_policy'] as String
      ..termsAndContionsZH = json['terms_and_contions_cn'] as String
      ..privacyPolicyZH = json['privacy_policy_cn'] as String
      ..stakingGuide = json['staking_guide'] as String
      ..graphqlApi = json['graphql_api'] as String?;

Map<String, dynamic> _$AboutUsDataToJson(AboutUsData instance) =>
    <String, dynamic>{
      'changelog_app': instance.changelog,
      'gitReponame_app': instance.gitReponame,
      'staking_guide_cn': instance.stakingGuideCN,
      'terms_and_contions': instance.termsAndContionsEN,
      'privacy_policy': instance.privacyPolicyEN,
      'terms_and_contions_cn': instance.termsAndContionsZH,
      'privacy_policy_cn': instance.privacyPolicyZH,
      'staking_guide': instance.stakingGuide,
      'graphql_api': instance.graphqlApi,
      'followus': instance.followus.map((e) => e?.toJson()).toList(),
    };
