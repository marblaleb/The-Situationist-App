// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'tokenType': instance.tokenType,
      'expiresIn': instance.expiresIn,
      'user': instance.user,
    };

_$AuthUserModelImpl _$$AuthUserModelImplFromJson(Map<String, dynamic> json) =>
    _$AuthUserModelImpl(
      userId: json['userId'] as String,
      email: json['email'] as String,
      provider: json['provider'] as String,
      username: json['username'] as String? ?? '',
    );

Map<String, dynamic> _$$AuthUserModelImplToJson(_$AuthUserModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'provider': instance.provider,
      'username': instance.username,
    };
