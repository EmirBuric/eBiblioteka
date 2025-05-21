// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recenzija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recenzija _$RecenzijaFromJson(Map<String, dynamic> json) => Recenzija(
      recenzijaId: (json['recenzijaId'] as num?)?.toInt(),
      knjigaId: (json['knjigaId'] as num?)?.toInt(),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      opis: json['opis'] as String?,
      ocjena: (json['ocjena'] as num?)?.toInt(),
      datumRecenzije: json['datumRecenzije'] == null
          ? null
          : DateTime.parse(json['datumRecenzije'] as String),
      odobrena: json['odobrena'] as bool?,
    )
      ..knjiga = json['knjiga'] == null
          ? null
          : Knjiga.fromJson(json['knjiga'] as Map<String, dynamic>)
      ..korisnik = json['korisnik'] == null
          ? null
          : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>);

Map<String, dynamic> _$RecenzijaToJson(Recenzija instance) => <String, dynamic>{
      'recenzijaId': instance.recenzijaId,
      'knjigaId': instance.knjigaId,
      'korisnikId': instance.korisnikId,
      'opis': instance.opis,
      'ocjena': instance.ocjena,
      'datumRecenzije': instance.datumRecenzije?.toIso8601String(),
      'odobrena': instance.odobrena,
      'knjiga': instance.knjiga,
      'korisnik': instance.korisnik,
    };
