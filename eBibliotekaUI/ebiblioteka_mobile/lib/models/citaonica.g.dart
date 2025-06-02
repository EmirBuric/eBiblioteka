// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citaonica.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Citaonica _$CitaonicaFromJson(Map<String, dynamic> json) => Citaonica(
      citaonicaId: (json['citaonicaId'] as num?)?.toInt(),
      naziv: json['naziv'] as String?,
    );

Map<String, dynamic> _$CitaonicaToJson(Citaonica instance) => <String, dynamic>{
      'citaonicaId': instance.citaonicaId,
      'naziv': instance.naziv,
    };
