import 'package:json_annotation/json_annotation.dart';

part 'tip_clanarine.g.dart';

@JsonSerializable()
class TipClanarine {
  int? tipClanarineId;
  int? vrijemeTrajanja;
  int? cijena;

  TipClanarine({
    this.tipClanarineId,
    this.vrijemeTrajanja,
    this.cijena,
  });

  factory TipClanarine.fromJson(Map<String, dynamic> json) =>
      _$TipClanarineFromJson(json);

  Map<String, dynamic> toJson() => _$TipClanarineToJson(this);
}
