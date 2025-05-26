// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knjiga_autor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KnjigaAutor _$KnjigaAutorFromJson(Map<String, dynamic> json) => KnjigaAutor(
      knjigaAutorId: (json['knjigaAutorId'] as num?)?.toInt(),
      knjigaId: (json['knjigaId'] as num?)?.toInt(),
      autorId: (json['autorId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$KnjigaAutorToJson(KnjigaAutor instance) =>
    <String, dynamic>{
      'knjigaAutorId': instance.knjigaAutorId,
      'knjigaId': instance.knjigaId,
      'autorId': instance.autorId,
    };
