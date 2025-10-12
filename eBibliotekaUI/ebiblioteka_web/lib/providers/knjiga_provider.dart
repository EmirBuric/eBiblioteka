import 'package:ebiblioteka_web/models/dostupnost_knjige.dart';
import 'package:ebiblioteka_web/models/izvjestaj_knjiga.dart';
import 'package:ebiblioteka_web/models/knjiga.dart';
import 'package:ebiblioteka_web/providers/base_provider.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class KnjigaProvider extends BaseProvider<Knjiga> {
  KnjigaProvider() : super("Knjiga");

  @override
  Knjiga fromJson(data) {
    return Knjiga.fromJson(data);
  }

  Future<void> setKnjigaDana(int id) async {
    String endpoint = "Knjiga/KnjigaDana/$id";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();

    try {
      final response = await http.post(uri, headers: headers);

      if (isValidResponse(response)) {
        return;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> setPreporucenaKnjiga(List<int> ids) async {
    String endpoint = "Knjiga/Preporuka";
    final uri = Uri.parse('${BaseProvider.baseUrl}${endpoint}');

    final headers = createHeaders();
    var jsonRequest = jsonEncode(ids);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (!isValidResponse(response)) {
      throw Exception('Greška prilikom slanja preporučenih knjiga');
    }
  }

  Future<DostupnostKnjige> getDostupnostZaPeriod(
      int knjigaId, DateTime datumOd, DateTime datumDo) async {
    String endpoint =
        "Knjiga/Kalendar/$knjigaId?datumOd=${datumOd.toIso8601String()}&datumDo=${datumDo.toIso8601String()}";
    final uri = Uri.parse('${BaseProvider.baseUrl}$endpoint');

    final headers = createHeaders();

    try {
      final response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        final json = jsonDecode(response.body);
        return DostupnostKnjige.fromJson(json);
      } else {
        throw Exception('Greška prilikom dohvatanja dostupnosti');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }

  Future<IzvjestajKnjiga> getKnjigaIzvjestaj(
      int knjigaId, DateTime datumOd, DateTime datumDo) async {
    String endpoint =
        "Knjiga/Izvjestaj/$knjigaId?datumOd=${datumOd.toIso8601String()}&datumDo=${datumDo.toIso8601String()}";
    final uri = Uri.parse('${BaseProvider.baseUrl}$endpoint');

    final headers = createHeaders();

    try {
      final response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        final json = jsonDecode(response.body);
        return IzvjestajKnjiga.fromJson(json);
      } else {
        throw Exception('Greška prilikom dohvatanja izvještaja');
      }
    } catch (e) {
      throw Exception('Greška prilikom komunikacije sa serverom: $e');
    }
  }
}
