// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'izvjestaj_clanarina.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClanarinaIzvjestaj _$ClanarinaIzvjestajFromJson(Map<String, dynamic> json) =>
    ClanarinaIzvjestaj(
      ukupnaZarada: (json['ukupnaZarada'] as num?)?.toDouble(),
      tipIzvjestaji: (json['tipIzvjestaji'] as List<dynamic>?)
          ?.map((e) => TipIzvjestaj.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClanarinaIzvjestajToJson(ClanarinaIzvjestaj instance) =>
    <String, dynamic>{
      'ukupnaZarada': instance.ukupnaZarada,
      'tipIzvjestaji': instance.tipIzvjestaji,
    };
