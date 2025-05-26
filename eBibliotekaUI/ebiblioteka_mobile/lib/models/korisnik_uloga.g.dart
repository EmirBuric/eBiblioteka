// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korisnik_uloga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KorisnikUloga _$KorisnikUlogaFromJson(Map<String, dynamic> json) =>
    KorisnikUloga(
      korisnikUlogaId: (json['korisnikUlogaId'] as num?)?.toInt(),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      ulogaId: (json['ulogaId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$KorisnikUlogaToJson(KorisnikUloga instance) =>
    <String, dynamic>{
      'korisnikUlogaId': instance.korisnikUlogaId,
      'korisnikId': instance.korisnikId,
      'ulogaId': instance.ulogaId,
    };
