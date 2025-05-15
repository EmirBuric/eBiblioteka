// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zanr.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Zanr _$ZanrFromJson(Map<String, dynamic> json) => Zanr(
      zanrId: (json['zanrId'] as num?)?.toInt(),
      naziv: json['naziv'] as String?,
    );

Map<String, dynamic> _$ZanrToJson(Zanr instance) => <String, dynamic>{
      'zanrId': instance.zanrId,
      'naziv': instance.naziv,
    };
