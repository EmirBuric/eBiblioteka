// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'izvjestaj_knjiga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IzvjestajKnjiga _$IzvjestajKnjigaFromJson(Map<String, dynamic> json) =>
    IzvjestajKnjiga(
      knjigaId: (json['knjigaId'] as num?)?.toInt(),
      naziv: json['naziv'] as String?,
      rezervacijePoMjesecu:
          (json['rezervacijePoMjesecu'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      recenzijePoOcjeni:
          (json['recenzijePoOcjeni'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
      prosjecnaOcjena: (json['prosjecnaOcjena'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$IzvjestajKnjigaToJson(IzvjestajKnjiga instance) =>
    <String, dynamic>{
      'knjigaId': instance.knjigaId,
      'naziv': instance.naziv,
      'rezervacijePoMjesecu': instance.rezervacijePoMjesecu,
      'recenzijePoOcjeni':
          instance.recenzijePoOcjeni?.map((k, e) => MapEntry(k.toString(), e)),
      'prosjecnaOcjena': instance.prosjecnaOcjena,
    };
