// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korisnik_izabrana_knjiga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KorisnikIzabranaKnjiga _$KorisnikIzabranaKnjigaFromJson(
        Map<String, dynamic> json) =>
    KorisnikIzabranaKnjiga(
      korisnikIzabranaKnjigaId:
          (json['korisnikIzabranaKnjigaId'] as num?)?.toInt(),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      knjigaId: (json['knjigaId'] as num?)?.toInt(),
      datumRezervacije: json['datumRezervacije'] == null
          ? null
          : DateTime.parse(json['datumRezervacije'] as String),
      datumVracanja: json['datumVracanja'] == null
          ? null
          : DateTime.parse(json['datumVracanja'] as String),
      isChecked: json['isChecked'] as bool?,
    )..knjiga = json['knjiga'] == null
        ? null
        : Knjiga.fromJson(json['knjiga'] as Map<String, dynamic>);

Map<String, dynamic> _$KorisnikIzabranaKnjigaToJson(
        KorisnikIzabranaKnjiga instance) =>
    <String, dynamic>{
      'korisnikIzabranaKnjigaId': instance.korisnikIzabranaKnjigaId,
      'korisnikId': instance.korisnikId,
      'knjigaId': instance.knjigaId,
      'datumRezervacije': instance.datumRezervacije?.toIso8601String(),
      'datumVracanja': instance.datumVracanja?.toIso8601String(),
      'isChecked': instance.isChecked,
      'knjiga': instance.knjiga,
    };
