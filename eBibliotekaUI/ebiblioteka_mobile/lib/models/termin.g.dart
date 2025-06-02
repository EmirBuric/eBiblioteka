// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'termin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Termin _$TerminFromJson(Map<String, dynamic> json) => Termin(
      terminId: (json['terminId'] as num?)?.toInt(),
      citaonicaId: (json['citaonicaId'] as num?)?.toInt(),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      datum: json['datum'] == null
          ? null
          : DateTime.parse(json['datum'] as String),
      start: _$JsonConverterFromJson<String, TimeOfDay>(
          json['start'], const TimeOfDayConverter().fromJson),
      kraj: _$JsonConverterFromJson<String, TimeOfDay>(
          json['kraj'], const TimeOfDayConverter().fromJson),
      jeRezervisan: json['jeRezervisan'] as bool?,
      jeProsao: json['jeProsao'] as bool?,
    )..korisnik = json['korisnik'] == null
        ? null
        : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>);

Map<String, dynamic> _$TerminToJson(Termin instance) => <String, dynamic>{
      'terminId': instance.terminId,
      'citaonicaId': instance.citaonicaId,
      'korisnikId': instance.korisnikId,
      'datum': instance.datum?.toIso8601String(),
      'start': _$JsonConverterToJson<String, TimeOfDay>(
          instance.start, const TimeOfDayConverter().toJson),
      'kraj': _$JsonConverterToJson<String, TimeOfDay>(
          instance.kraj, const TimeOfDayConverter().toJson),
      'jeRezervisan': instance.jeRezervisan,
      'jeProsao': instance.jeProsao,
      'korisnik': instance.korisnik,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
