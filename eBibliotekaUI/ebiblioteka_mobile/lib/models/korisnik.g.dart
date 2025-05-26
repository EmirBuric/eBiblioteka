// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korisnik.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Korisnik _$KorisnikFromJson(Map<String, dynamic> json) => Korisnik(
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      ime: json['ime'] as String?,
      prezime: json['prezime'] as String?,
      email: json['email'] as String?,
      telefon: json['telefon'] as String?,
      korisnickoIme: json['korisnickoIme'] as String?,
      korisnikUlogas: (json['korisnikUlogas'] as List<dynamic>?)
          ?.map((e) => KorisnikUloga.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$KorisnikToJson(Korisnik instance) => <String, dynamic>{
      'korisnikId': instance.korisnikId,
      'ime': instance.ime,
      'prezime': instance.prezime,
      'email': instance.email,
      'telefon': instance.telefon,
      'korisnickoIme': instance.korisnickoIme,
      'korisnikUlogas': instance.korisnikUlogas,
    };
