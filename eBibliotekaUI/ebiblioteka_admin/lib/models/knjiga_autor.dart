import 'package:json_annotation/json_annotation.dart';

part 'knjiga_autor.g.dart';

@JsonSerializable()
class KnjigaAutor {
  int? knjigaAutorId;
  int? knjigaId;
  int? autorId;

  KnjigaAutor({this.knjigaAutorId, this.knjigaId, this.autorId});

  factory KnjigaAutor.fromJson(Map<String, dynamic> json) =>
      _$KnjigaAutorFromJson(json);

  Map<String, dynamic> toJson() => _$KnjigaAutorToJson(this);
}
