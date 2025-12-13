// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'izvjestaj_tip_clanarine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TipIzvjestaj _$TipIzvjestajFromJson(Map<String, dynamic> json) => TipIzvjestaj(
      tipClanarineId: (json['tipClanarineId'] as num?)?.toInt(),
      brojPoTipu: (json['brojPoTipu'] as num?)?.toInt(),
      zaradaPoTipu: (json['zaradaPoTipu'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TipIzvjestajToJson(TipIzvjestaj instance) =>
    <String, dynamic>{
      'tipClanarineId': instance.tipClanarineId,
      'brojPoTipu': instance.brojPoTipu,
      'zaradaPoTipu': instance.zaradaPoTipu,
    };
