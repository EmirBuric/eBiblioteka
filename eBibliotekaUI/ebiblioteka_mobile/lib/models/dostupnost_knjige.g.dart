// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dostupnost_knjige.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DostupnostKnjige _$DostupnostKnjigeFromJson(Map<String, dynamic> json) =>
    DostupnostKnjige(
      knjigaId: (json['knjigaId'] as num?)?.toInt(),
      dostupnost: (json['dostupnost'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(DateTime.parse(k), e as bool),
      ),
    );

Map<String, dynamic> _$DostupnostKnjigeToJson(DostupnostKnjige instance) =>
    <String, dynamic>{
      'knjigaId': instance.knjigaId,
      'dostupnost':
          instance.dostupnost?.map((k, e) => MapEntry(k.toIso8601String(), e)),
    };
