// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knjiga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Knjiga _$KnjigaFromJson(Map<String, dynamic> json) => Knjiga(
      knjigaId: (json['knjigaId'] as num?)?.toInt(),
      naziv: json['naziv'] as String?,
      autoriIds: (json['autoriIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    )
      ..kratkiOpis = json['kratkiOpis'] as String?
      ..godinaIzdanja = (json['godinaIzdanja'] as num?)?.toInt()
      ..slika = json['slika'] as String?
      ..zanrId = (json['zanrId'] as num?)?.toInt()
      ..isDeleted = json['isDeleted'] as bool?
      ..vrijemeBrisanja = json['vrijemeBrisanja'] == null
          ? null
          : DateTime.parse(json['vrijemeBrisanja'] as String)
      ..kolicina = (json['kolicina'] as num?)?.toInt()
      ..dostupna = json['dostupna'] as bool?
      ..knjigaDana = json['knjigaDana'] as bool?
      ..preporuceno = json['preporuceno'] as bool?;

Map<String, dynamic> _$KnjigaToJson(Knjiga instance) => <String, dynamic>{
      'knjigaId': instance.knjigaId,
      'naziv': instance.naziv,
      'kratkiOpis': instance.kratkiOpis,
      'godinaIzdanja': instance.godinaIzdanja,
      'slika': instance.slika,
      'zanrId': instance.zanrId,
      'isDeleted': instance.isDeleted,
      'vrijemeBrisanja': instance.vrijemeBrisanja?.toIso8601String(),
      'kolicina': instance.kolicina,
      'dostupna': instance.dostupna,
      'knjigaDana': instance.knjigaDana,
      'preporuceno': instance.preporuceno,
      'autoriIds': instance.autoriIds,
    };
