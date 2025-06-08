// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rezervacija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rezervacija _$RezervacijaFromJson(Map<String, dynamic> json) => Rezervacija(
      rezervacijaId: (json['rezervacijaId'] as num?)?.toInt(),
      knjigaId: (json['knjigaId'] as num?)?.toInt(),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      datumRezervacije: json['datumRezervacije'] == null
          ? null
          : DateTime.parse(json['datumRezervacije'] as String),
      datumVracanja: json['datumVracanja'] == null
          ? null
          : DateTime.parse(json['datumVracanja'] as String),
      odobrena: json['odobrena'] as bool?,
      knjiga: json['knjiga'] == null
          ? null
          : Knjiga.fromJson(json['knjiga'] as Map<String, dynamic>),
      korisnik: json['korisnik'] == null
          ? null
          : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RezervacijaToJson(Rezervacija instance) =>
    <String, dynamic>{
      'rezervacijaId': instance.rezervacijaId,
      'knjigaId': instance.knjigaId,
      'korisnikId': instance.korisnikId,
      'datumRezervacije': instance.datumRezervacije?.toIso8601String(),
      'datumVracanja': instance.datumVracanja?.toIso8601String(),
      'odobrena': instance.odobrena,
      'knjiga': instance.knjiga,
      'korisnik': instance.korisnik,
    };
