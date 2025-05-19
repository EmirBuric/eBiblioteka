// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clanarina.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Clanarina _$ClanarinaFromJson(Map<String, dynamic> json) => Clanarina(
      clanarinaId: (json['clanarinaId'] as num?)?.toInt(),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      tipClanarineId: (json['tipClanarineId'] as num?)?.toInt(),
      statusClanarine: json['statusClanarine'] as String?,
      datumUplate: json['datumUplate'] == null
          ? null
          : DateTime.parse(json['datumUplate'] as String),
      datumIsteka: json['datumIsteka'] == null
          ? null
          : DateTime.parse(json['datumIsteka'] as String),
    );

Map<String, dynamic> _$ClanarinaToJson(Clanarina instance) => <String, dynamic>{
      'clanarinaId': instance.clanarinaId,
      'statusClanarine': instance.statusClanarine,
      'datumUplate': instance.datumUplate?.toIso8601String(),
      'datumIsteka': instance.datumIsteka?.toIso8601String(),
      'korisnikId': instance.korisnikId,
      'tipClanarineId': instance.tipClanarineId,
    };
