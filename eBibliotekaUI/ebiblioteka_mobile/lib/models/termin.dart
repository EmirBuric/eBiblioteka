import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'korisnik.dart';

part 'termin.g.dart';

class TimeOfDayConverter implements JsonConverter<TimeOfDay, String> {
  const TimeOfDayConverter();

  @override
  TimeOfDay fromJson(String json) {
    final parts = json.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  String toJson(TimeOfDay object) {
    return '${object.hour}:${object.minute}';
  }
}

@JsonSerializable()
class Termin {
  int? terminId;
  int? citaonicaId;
  int? korisnikId;
  DateTime? datum;

  @TimeOfDayConverter()
  TimeOfDay? start;

  @TimeOfDayConverter()
  TimeOfDay? kraj;
  bool? jeRezervisan;
  bool? jeProsao;
  Korisnik? korisnik;

  Termin(
      {this.terminId,
      this.citaonicaId,
      this.korisnikId,
      this.datum,
      this.start,
      this.kraj,
      this.jeRezervisan,
      this.jeProsao});

  factory Termin.fromJson(Map<String, dynamic> json) => _$TerminFromJson(json);

  Map<String, dynamic> toJson() => _$TerminToJson(this);
}
