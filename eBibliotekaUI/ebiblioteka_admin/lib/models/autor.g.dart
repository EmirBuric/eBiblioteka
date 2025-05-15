// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Autor _$AutorFromJson(Map<String, dynamic> json) => Autor(
      autorId: (json['autorId'] as num?)?.toInt(),
      ime: json['ime'] as String?,
      prezime: json['prezime'] as String?,
    )
      ..datumRodjenja = json['datumRodjenja'] == null
          ? null
          : DateTime.parse(json['datumRodjenja'] as String)
      ..biografija = json['biografija'] as String?;

Map<String, dynamic> _$AutorToJson(Autor instance) => <String, dynamic>{
      'autorId': instance.autorId,
      'ime': instance.ime,
      'prezime': instance.prezime,
      'datumRodjenja': instance.datumRodjenja?.toIso8601String(),
      'biografija': instance.biografija,
    };
